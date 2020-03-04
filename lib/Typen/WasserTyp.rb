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

  def definiereWellen(breite, hoehe)
    @wellenZustand = ErstelleWasserZustaende.erstelleWasserZustaende(breite: breite, hoehe: hoehe * 2, wind: @wind)
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
    raise
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

end
