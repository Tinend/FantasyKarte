# coding: utf-8
require "Terrain/Wasser"
require "Typen/Typ"
require "HoehenProfil/WasserHoehenPunkt"
require "ErstelleWasserZustaende/ErstelleWasserZustaende"

class WasserTyp < Typ

  HorizontalerAbstandFaktor = 1
  HorizontalerAbstandMinimum = 20
  VertikalerAbstandFaktor = 2
  VertikalerAbstandMinimum = 10
  MussFaerbenNummern = [21,22,23,24,25,26,27,28,29]
  DarfFaerbenNummern = [0, 254]
  #MiniwellenHoehe = 0.05
  MiniwellenHoehe = 0.05
  
  def initialize(breite, hoehe, wind:, hoehenProfil:)
    @wind = wind
    @hoehenProfil = hoehenProfil
    super(breite, hoehe)
    definiereWellen(breite, hoehe)
  end

  def normalisiere(vektor)
    raise
    norm = vektor.reduce(0) {|wert, element| (wert ** 2 + element ** 2) ** 0.5}
    vektor.collect {|element| element / norm}
  end
  
  def definiereWellen(breite, hoehe)
    @wellenZustand = ErstelleWasserZustaende.erstelleWasserZustaende(breite: breite, hoehe: hoehe * 2, wind: @wind)
  end
  
  def winkel(v1, v2)
    cos = (v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2]) / (v1.reduce(0) {|norm, zahl| (norm ** 2 + zahl ** 2) ** 0.5} * v2.reduce(0) {|norm, zahl| (norm ** 2 + zahl ** 2) ** 0.5})
    Math::acos(cos)
  end
  
  def berechneFarbeVonWellenPunkt(anfangsX, anfangsY, weiter: true)
    zustand = @wellenZustand[anfangsY][anfangsX]
    gesamtGewicht = 0
    gesamtFarbe = 0
    
    max = 0
    
    FarbBerechnungsVerschiebungen.each do |verschiebung|
      x = anfangsX + verschiebung[0]
      y = anfangsY + verschiebung[1]
      y = [[@wellenZustand.length - 1, y].min, 0].max
      zustand = @wellenZustand[y.round][x.round]
      while y > 0.5 and wellenHoehe(x, y, zustand) < wellenHoehe(x, y, @wellenZustand[y.round - 1][x.round]) + 0.5 and anfangsY - y + 2 * wellenHoehe(x, y, zustand) < - 0.25 and wellenHoehe(x, y, @wellenZustand[y.round - 1][x.round]) <= 0.25
        y -= 1
        zustand = @wellenZustand[y.round][x.round]
      end
      while y < @wellenZustand.length - 1.5 and ((wellenHoehe(x, y, zustand) < wellenHoehe(x, y, @wellenZustand[y.round + 1][x.round]) - 0.5 and anfangsY - y + 2 * wellenHoehe(x, y, zustand) > 0.25 and anfangsY - y + 2 * wellenHoehe(x, y, @wellenZustand[y.round + 1][x.round]) >= -0.25) or winkel(normalVektorBerechnen(@wind.geschwindigkeit(x, y / 2.0), @wind.richtung(x, y / 2.0), zustand), SichtVektor) >= Math::PI / 2)
        y += 1
        zustand = @wellenZustand[y.round][x.round]
      end
      x = [[@wellenZustand[0].length - 1, x].min, 0].max
      normalVektor = normalVektorBerechnen(@wind.geschwindigkeit(x, y / 2.0), @wind.richtung(x, y / 2.0), zustand)
      norm = normalVektor.reduce(0) {|n, wert| (n ** 2 + wert ** 2) ** 0.5}
      normalVektor.collect!.with_index {|wert, index| wert / norm + @normalVektoren[y][x][index] * HintergrundFaktor}
      gewicht = berechneSichtbarkeit(normalVektor)
      farbe = berechneFarbe(normalVektor)
      gesamtFarbe += farbe * gewicht
      gesamtGewicht += gewicht
    end
    if gesamtGewicht <= 0 and weiter
      gesamtFarbe = 0
      punkte = 0
      NotfallWellenFarbePunkte.each do |punkt|
        if anfangsX + punkt[0] < @wellenZustand[0].length and anfangsY + punkt[1] < @wellenZustand.length
          punkte += 1
          gesamtFarbe += berechneFarbeVonWellenPunkt(anfangsX + punkt[0], anfangsY + punkt[1], weiter: false)
        end
      end
      return gesamtFarbe / punkte
    elsif gesamtGewicht <= 0
      return 0
    end    
    gesamtFarbe / gesamtGewicht if gesamtGewicht != 0
  end
    
  def macheTerrain(datenFarbe, x, y)
    wasser = Wasser.new(10, 5)
    return [wasser.malen(), [0, 0]]
  end
  
  def definiereTerrain?(datenFarbe)
    return false
    rand(1024) <= 11
  end
  
  def kannFaerben?(datenFarbe)
    return true if MussFaerbenNummern.any? {|mfn| ChunkyPNG::Color.r(datenFarbe) == mfn} or DarfFaerbenNummern.any? {|dfn| ChunkyPNG::Color.r(datenFarbe) == dfn}
    return false
  end
  
  def erstelleHintergrund(hintergrund)
    @wellenZustand.each_with_index do |zeile, y|
      zeile.each_with_index do |zustand, x|
        if @hintergrund[x, y / 2] != ChunkyPNG::Color::TRANSPARENT
          @hoehenProfil.hoehenPunktEinfuegen(x: x, y: y, hoehenPunkt: WasserHoehenPunkt.new(zustand.hoehe + (rand(0) - rand(0)) * MiniwellenHoehe))
        end
      end
    end
    hintergrund.height.times do |y|
      hintergrund.width.times do |x|
        if @hintergrund[x, y] != ChunkyPNG::Color::TRANSPARENT
          #grau = [[((@hintergrundArray[y * 2][x] + @hintergrundArray[y * 2 + 1][x]) / 2).round, 255].min, 0].max
          grau = @hoehenProfil.berechneHelligkeitAnKoordinate(x: x, y: y)
          #grau = [[(@hoehenProfil.hoehenProfil[y][x].hoehe / 10).to_i + 128, 255].min, 0].max
          #grau = [[(64 + 32 * @wellenZustand[y][x].hoehe).to_i, 255].min, 0].max
          #p [@wellenZustand[y][x].hoehe, @wellenZustand[y][x].y, @wellenZustand[y][x].x, Math::tan(@wellenZustand[y][x].y / @wellenZustand[y][x].x), grau, x, y]
          hintergrund[x, y] = ChunkyPNG::Color.rgb(grau, grau, grau)
        end
      end
    end
  end

  def berechneSichtbarkeit(normalVektor)
    normalVektorNorm = normalVektor.reduce(0) {|norm, element| (norm ** 2 + element ** 2) ** 0.5}
    sichtVektorNorm = SichtVektor.reduce(0) {|norm, element| (norm ** 2 + element ** 2) ** 0.5}
    skalarProdukt = normalVektor[0] * SichtVektor[0] + normalVektor[1] * SichtVektor[1] + normalVektor[2] * SichtVektor[2]
    return 0 if skalarProdukt <= 0
    return skalarProdukt / sichtVektorNorm / normalVektorNorm
  end
    
  def berechneFarbe(normalVektor)
    normalVektorNorm = normalVektor.reduce(0) {|norm, element| (norm ** 2 + element ** 2) ** 0.5}
    sonnenVektorNorm = SonnenVektor.reduce(0) {|norm, element| (norm ** 2 + element ** 2) ** 0.5}
    zwischenWinkelNorm = ZwischenSonneBeobachterVektor.reduce(0) {|norm, element| (norm ** 2 + element ** 2) ** 0.5}
    acosSonneNormal = (normalVektor[0] * SonnenVektor[0] + normalVektor[1] * SonnenVektor[1] + normalVektor[2] * SonnenVektor[2]) / (normalVektorNorm * sonnenVektorNorm)
    acosZwischenNormal = (normalVektor[0] * ZwischenSonneBeobachterVektor[0] + normalVektor[1] * ZwischenSonneBeobachterVektor[1] + normalVektor[2] * ZwischenSonneBeobachterVektor[2]) / (normalVektorNorm * zwischenWinkelNorm)
    return acosSonneNormal * ReflexionMaxHelligkeit + ReflexionMaxHelligkeit + [acosZwischenNormal - MaxSpiegelungsCosinus, 0].max ** 2 * SpiegelMaxHelligkeit + MinimalHelligkeit
  end

end
