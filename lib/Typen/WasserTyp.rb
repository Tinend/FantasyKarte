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
  MinWasserHelligkeit = 128
  WasserHelligkeitsSchwankung = 128
  MaxWellenHelligkeit = 160
  WellenDunkelSubstaktor = 48
  MaxWellenSteigung = Math::PI / 25
  SonnenVektor = [1, 1, 2 **0.5]
  ZwischenSonneBeobachterVektor = [0.5, 1, 0.5 / 3 ** 0.5 + 0.5 * 2 ** 0.5] # MittelVektor zwischen Beobachter und Sonne
  MaxSpiegelungsCosinus = 0.7
  ReflexionMaxHelligkeit = 128
  SpiegelMaxHelligkeit = 384
  
  def initialize(breite, hoehe, wind:)
    @wind = wind
    @hintergrundArray = Array.new(hoehe * 2) {Array.new(breite) {rand(WasserHelligkeitsSchwankung) + MinWasserHelligkeit}}
    erneuereHintergrundArray()
    definiereWellen()
    super(breite, hoehe)
  end

  def erneuereHintergrundArray()
    hintergrundArrayKopie = Array.new(@hintergrundArray.length) {|i| @hintergrundArray[i].dup}
    @hintergrundArray.each_with_index do |zeile, y|
      zeile.collect!.with_index do |wert, x|
        minX = [0, x - 1].max
        maxX = [@hintergrundArray[0].length - 1, x + 1].min
        minY = [0, y - 1].max
        maxY = [@hintergrundArray.length - 1, y + 1].min
        wert *= (maxX - minX) * (maxY - minY) - 1
        (maxY - minY).times do |lokalY|
          (maxX - minX).times do |lokalX|
            wert += @hintergrundArray[lokalY + minY][lokalX + minX]
          end
        end
        (wert / (2.0 * (maxX - minX) * (maxY - minY) - 1)).round
     end
    end
  end
  
  def definiereWellen()
    @frei = Array.new(@hintergrundArray.length) {Array.new(@hintergrundArray[0].length, 0)}
    reihenfolge = Array.new(@hintergrundArray.length * @hintergrundArray[0].length) {|i| i} 
    reihenfolge.shuffle!
    wellenNummer = 0
    reihenfolge.each_with_index do |nummer, index|
      x = nummer / @hintergrundArray.length
      y = nummer % @hintergrundArray.length
      if @frei[y][x] and rand(0) <= WellenWkeit
        wellenNummer += 1
        erschaffeWelle(x, y, wellenNummer)
      end
    end
  end

  def erstelleWellenPunkt(x, y, wellenNummer)
    x = x.round
    y = y.round
    minX = [0, x - 1].max
    maxX = [@hintergrundArray[0].length - 1, x + 1].min
    minY = [0, y - 1].max
    maxY = [@hintergrundArray.length - 1, y + 1].min
    (maxY - minY).times do |lokalY|
      (maxX - minX).times do |lokalX|
        @hintergrundArray[lokalY + minY][lokalX + minX] = wellenNummer if @hintergrundArray[lokalY + minY][lokalX + minX] == 0
      end
    end
    if @hintergrundArray[y][x] >= MaxWellenHelligkeit
      @hintergrundArray[y][x] -= WellenDunkelSubstaktor
    end
  end
    
  def erschaffeWelle(x, y, wellenNummer)
    erstelleWellenPunkt(x, y, wellenNummer)
    erstelleArm(x, y, 1, wellenNummer)
    erstelleArm(x, y, -1, wellenNummer)
  end
  
  def erstelleArm(x, y, orientierung, wellenNummer)
    until rand(0) < WellenEndeWkeit / @wind.geschwindigkeit(x, y / 2.0)
      vektor = @wind.senkrecht(x, y / 2.0, orientierung)
      vektor = vektor.zip(@wind.vektor(x.round, y.round / 2.0)).map {|element| element[0]}
      x += vektor[0] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5
      y += vektor[1] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5
      return if x.round < 0 or y.round < 0 or y.round >= @hintergrundArray.length or x.round >= @hintergrundArray[0].length
      return unless @frei[y.round][x.round] == 0 or @frei[y.round][x.round] == wellenNummer
      erstelleWellenPunkt(x, y, wellenNummer)
    end
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
          #grau = @hintergrundArray[y * 2][x]
          grau = [berechneFarbe(zufallsNormalVektor), 255].min
          hintergrund[x, y] = ChunkyPNG::Color.rgb(grau, grau, grau)
        end
      end
    end
  end

  def berechneFarbe(normalVektor)
    normalVektorNorm = normalVektor.reduce(0) {|norm, element| (norm ** 2 + element ** 2) ** 0.5}
    sonnenVektorNorm = SonnenVektor.reduce(0) {|norm, element| (norm ** 2 + element ** 2) ** 0.5}
    zwischenWinkelNorm = ZwischenSonneBeobachterVektor.reduce(0) {|norm, element| (norm ** 2 + element ** 2) ** 0.5}
    acosSonneNormal = (normalVektor[0] * SonnenVektor[0] + normalVektor[1] * SonnenVektor[1] + normalVektor[2] * SonnenVektor[2]) / (normalVektorNorm * sonnenVektorNorm)
    acosZwischenNormal = (normalVektor[0] * ZwischenSonneBeobachterVektor[0] + normalVektor[1] * ZwischenSonneBeobachterVektor[1] + normalVektor[2] * ZwischenSonneBeobachterVektor[2]) / (normalVektorNorm * zwischenWinkelNorm)
    return (Math::sin(Math::acos(acosSonneNormal)) * ReflexionMaxHelligkeit + [acosZwischenNormal - MaxSpiegelungsCosinus, 0].max * SpiegelMaxHelligkeit).to_i
  end

  def zufallsNormalVektor() #zufälliger Normalvektor für Wasseroberfläche
    return [(rand(0) - rand(0)) / MaxWellenSteigung / 2 ** 0.5, (rand(0) - rand(0)) / MaxWellenSteigung / 2 ** 0.5, 1]
  end
end
