require "Gras"
require "Typ"
require "definiereNeigungen"

class GrasTyp < Typ
  HorizontalerAbstandFaktor = 0.3
  HorizontalerAbstandMinimum = 1
  VertikalerAbstandFaktor = 0.3
  VertikalerAbstandMinimum = 0.3
  MussFaerbenNummern = [61, 62, 63, 64, 65, 66, 67, 68, 69, 71, 72, 73, 74, 75, 76, 77, 78, 79]
  DarfFaerbenNummern = [0, 11, 12, 13, 14, 15, 16, 17, 18, 19, 51, 52, 53, 54, 55, 56, 57, 58, 59, 254]
  MindestAbstand = -1
  
  def initialize(breite, hoehe)
    super(breite, hoehe)
    @neigungen = definiereNeigungen(breite, hoehe, 0.9)
    png = ChunkyPNG::Image.new(@neigungen.length, @neigungen[0].length, ChunkyPNG::Color::WHITE)
    @neigungen.each_with_index do |neigungen, x|
      neigungen.each_with_index do |n, y|
        h = n + 128
        h = h.round
        h = [0, h].max
        h = [255, h].min
        png[x,y] = ChunkyPNG::Color.rgb(h, h, h)
      end
    end
    #png.save("../ausgabe/grasTyp.png", :interlace => true)
  end

  def macheTerrain(datenFarbe, x, y)
    neigung = ChunkyPNG::Color.g(datenFarbe)
    neigung = 128 if neigung == 0
    neigung += @neigungen[x][y]
    neigung = [1, neigung].max
    neigung = [255, neigung].min
    gras = Gras.new(ChunkyPNG::Color.r(datenFarbe) % 10  * 2 + 1, neigung, ChunkyPNG::Color.g(datenFarbe))
    bild = gras.malen()
    return [bild, [bild.width / 2, bild.height]]
  end

  def definiereTerrain?(datenFarbe)
    rand(1024) <= 255
  end

  def horizontalerAbstand(datenFarbe)
    super(datenFarbe) + ChunkyPNG::Color.r(datenFarbe) % 10 * 0.5
  end
end
