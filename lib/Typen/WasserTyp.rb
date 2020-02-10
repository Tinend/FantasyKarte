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
  MaxSpiegelungsCosinus = 0.875
  ReflexionMaxHelligkeit = 64
  SpiegelMaxHelligkeit = 12800
  WellenPunkteApproximation = 20
  WellenMaximalSteigung = 15
  WellenLaenge = 0.5
  
  def initialize(breite, hoehe, wind:)
    @wind = wind
    p [@wind.vektor(10, 10), 1 / @wind.geschwindigkeit(10, 10) ** 2 / WellenLaenge / WellenMaximalSteigung]
    #@normalVektorArray = Array.new(hoehe * 2) {Array.new(breite) {zufallsNormalVektor()}}
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
          #wert = xArray[x] + windSchrittY(x, y - 1)
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
  
  def berechneFarbeVonWellenPunkt(x, y)
    zustand = @wellenZustand[y][x]
    if x == 0
      p [x, y, zustand, wellenHoehe(x, y, zustand), [@wind.richtung(x, y / 2.0)[1], Math::cos(zustand), Math::PI / WellenLaenge / WellenMaximalSteigung], (1 - ySteigungBerechnen(x, y, zustand)), wellenHoehe(x, y, zustand) / (1 - ySteigungBerechnen(x, y, zustand))]
    end
    #return wellenHoehe(x, y, zustand) * 40 + 128
    y += wellenHoehe(x, y, zustand) / (1 - ySteigungBerechnen(x, y, zustand))
    y = [[@wellenZustand.length - 1, y].min, 0].max
    normalVektor = normalVektorBerechnen(@wind.geschwindigkeit(x, y / 2.0), @wind.richtung(x, y / 2.0), zustand)
    if x == 0
      p [x, y, zustand, wellenHoehe(x, y, zustand) + 128, berechneFarbe(normalVektor), berechneSichtbarkeit(normalVektor)]
    end
    berechneFarbe(normalVektor) * berechneSichtbarkeit(normalVektor)
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
    p [normalVektor, SichtVektor, skalarProdukt]
    return 0 if skalarProdukt <= 0
    return skalarProdukt / sichtVektorNorm / normalVektorNorm
  end
    
  def berechneFarbe(normalVektor)
    normalVektorNorm = normalVektor.reduce(0) {|norm, element| (norm ** 2 + element ** 2) ** 0.5}
    sonnenVektorNorm = SonnenVektor.reduce(0) {|norm, element| (norm ** 2 + element ** 2) ** 0.5}
    zwischenWinkelNorm = ZwischenSonneBeobachterVektor.reduce(0) {|norm, element| (norm ** 2 + element ** 2) ** 0.5}
    acosSonneNormal = (normalVektor[0] * SonnenVektor[0] + normalVektor[1] * SonnenVektor[1] + normalVektor[2] * SonnenVektor[2]) / (normalVektorNorm * sonnenVektorNorm)
    acosZwischenNormal = (normalVektor[0] * ZwischenSonneBeobachterVektor[0] + normalVektor[1] * ZwischenSonneBeobachterVektor[1] + normalVektor[2] * ZwischenSonneBeobachterVektor[2]) / (normalVektorNorm * zwischenWinkelNorm)
    return acosSonneNormal * ReflexionMaxHelligkeit + ReflexionMaxHelligkeit + [acosZwischenNormal - MaxSpiegelungsCosinus, 0].max ** 2 * SpiegelMaxHelligkeit
  end

  def zufallsNormalVektor() #zufälliger Normalvektor für Wasseroberfläche
    raise
    return [(rand(0) - rand(0)) / MaxWellenSteigung / 2 ** 0.5, (rand(0) - rand(0)) / MaxWellenSteigung / 2 ** 0.5, 1]
  end
end
