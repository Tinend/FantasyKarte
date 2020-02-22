# coding: utf-8
require "Wasser"
require "Typ"

class WasserTyp < Typ

  HorizontalerAbstandFaktor = 1
  HorizontalerAbstandMinimum = 20
  VertikalerAbstandFaktor = 2
  VertikalerAbstandMinimum = 10
  MussFaerbenNummern = [21,22,23,24,25,26,27,28,29]
  DarfFaerbenNummern = [0, 254]
  MindestAbstand = 2
  WellenEndeWkeit = 0.2
  WellenWkeit = 0.03
  MaxWellenSteigung = Math::PI / 25
  SonnenVektor = [1, 1, 2 **0.5]
  ZwischenSonneBeobachterVektor = [0.5, 1, 0.5 / 3 ** 0.5 + 0.5 * 2 ** 0.5] # MittelVektor zwischen Beobachter und Sonne
  SichtVektor = [0, 3 ** 0.5, 1] # Vektor, der in Richtung Beobachter zeigt
  MaxSpiegelungsCosinus = 0.92
  MinimalHelligkeit = -96
  ReflexionMaxHelligkeit = 128
  #SpiegelMaxHelligkeit = 12800
  SpiegelMaxHelligkeit = 0
  WellenPunkteApproximation = 20
  WellenMaximalSteigung = 15
  #WellenLaenge = 0.8
  WellenLaenge = 3
  FarbBerechnungsVerschiebungen = [[0,0], [0.5, 0], [-0.5, 0], [0, 0.5], [0, -0.5]]
  NotfallWellenFarbePunkte = [[1, 0], [-1, 0], [0, 1], [0, -1]]
  YVerschiebungsToleranz = 0.01
  
  def initialize(breite, hoehe, wind:)
    @wind = wind
    definiereWellen(breite, hoehe)
    super(breite, hoehe)
  end

  def definiereHintergrundArray(hoehe, breite)
    @hintergrundArray = Array.new(hoehe * 2) do |y|
      Array.new(breite) do |x|
        grau = 0
        3.times do |i|
          grau += berechneFarbe(@normalVektorArray[y][(x - 1 + i) % @normalVektorArray[0].length])
        end
        3.times do |i|
          grau += berechneFarbe(@normalVektorArray[(y - 1 + i) % @normalVektorArray.length][x])
        end
        grau / 6
      end
    end
  end

  def windSchrittX(x, y)
    Math::PI * 2 * @wind.vektor(x, y / 2.0)[0] / @wind.geschwindigkeit(x, y / 2.0) ** 2 / WellenLaenge / WellenMaximalSteigung
  end
  
  def windSchrittY(x, y)
    Math::PI * 2 * @wind.vektor(x, y / 2.0)[1] / @wind.geschwindigkeit(x, y / 2.0) ** 2 / WellenLaenge / WellenMaximalSteigung
  end
  
  def definiereWellen(breite, hoehe)
    startWert = rand(0) * Math::PI * 2
    xWert = startWert
    yWert = startWert
    xArray = Array.new(breite) do |x|
      if x > 0
        xWert += windSchrittX(x - 1, 0)
      end
      xWert
    end
    yArray = Array.new(hoehe * 2) do |y|
      if y > 0
        yWert += windSchrittY(0, y - 1)
      end
      yWert
    end
    wertAlt = startWert
    @wellenZustand = Array.new(hoehe * 2) do |y| 
      Array.new(breite) do |x|
        if x > 0 and y > 0
          deltaX = @wind.richtung(x, y / 2.0)[0] - @wind.richtung(x, y / 2.0 - 0.5)[0]
          deltaY = @wind.richtung(x, y / 2.0)[1] - @wind.richtung(x - 1, y / 2.0)[1]
          wert = (xArray[x] + windSchrittY(x, y - 1) + yArray[y] + windSchrittX(x - 1, y)) / 2
          xArray[x] = wert
          yArray[y] = wert
        elsif x == 0
          wert = yArray[y]
          wertAlt = xArray[0]
          xArray[0] = wert
        elsif y == 0
          wert = xArray[x]
          yArray[0] = wert
        end
        wert
      end
    end
    @hintergrundArray = Array.new(hoehe * 2) do |y|
      Array.new(breite) do |x|
        berechneFarbeVonWellenPunkt(x, y)
      end
    end
  end
  
  def berechneFarbeVonWellenPunkt(anfangsX, anfangsY, weiter: true)
    zustand = @wellenZustand[anfangsY][anfangsX]
    gesamtGewicht = 0
    gesamtFarbe = 0
    p [anfangsX, anfangsY]
    FarbBerechnungsVerschiebungen.each do |verschiebung|
      x = anfangsX + verschiebung[0]
      y = anfangsY + verschiebung[1]
      y = [[@wellenZustand.length - 1, y].min, 0].max
      zustand = @wellenZustand[y.round][x.round]
      until y <= -0.5 or y >= @wellenZustand.length - 0.5 or (anfangsY - y + 2 * wellenHoehe(x, y, zustand)).abs <= YVerschiebungsToleranz
        p [x, anfangsY, y, wellenHoehe(x, y, zustand), ySteigungBerechnen(x, y, zustand), (anfangsY - y + 2 * wellenHoehe(x, y, zustand)) / (1 - 2 * ySteigungBerechnen(x, y, zustand))]
        y += (anfangsY - y + 2 * wellenHoehe(x, y, zustand)) / (1 - 2 * ySteigungBerechnen(x, y, zustand)) / 10
        y = [[@wellenZustand.length - 0.5, y].min, -0.5].max
        zustand = @wellenZustand[y.round][x.round]
      end
      x = [[@wellenZustand[0].length - 1, x].min, 0].max
      normalVektor = normalVektorBerechnen(@wind.geschwindigkeit(x, y / 2.0), @wind.richtung(x, y / 2.0), zustand)
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
  
  def ySteigungBerechnen(x, y, zustand)
    @wind.richtung(x, y / 2.0)[1] * Math::cos(zustand) * Math::PI / WellenMaximalSteigung
  end
  
  def wellenHoehe(x, y, zustand)
    Math::sin(zustand) * @wind.geschwindigkeit(x, y / 2.0) * WellenLaenge
  end
  
  def normalVektorBerechnen(windGeschwindigkeit, windrichtung, zustand)
    steigung = Math::cos(zustand) * Math::PI / WellenLaenge / WellenMaximalSteigung
    wellenNormalVektor = windrichtung.dup
    wellenNormalVektor.push((windGeschwindigkeit / steigung).abs)
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
    hintergrund.height.times do |y|
      hintergrund.width.times do |x|
        if @hintergrund[x, y] != ChunkyPNG::Color::TRANSPARENT
          grau = [[((@hintergrundArray[y * 2][x] + @hintergrundArray[y * 2 + 1][x]) / 2).round, 255].min, 0].max
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

  def zufallsNormalVektor() #zufälliger Normalvektor für Wasseroberfläche
    raise
    return [(rand(0) - rand(0)) / MaxWellenSteigung / 2 ** 0.5, (rand(0) - rand(0)) / MaxWellenSteigung / 2 ** 0.5, 1]
  end
end
