require "Baum"
require "Laubbaum"
require "Nadelbaum"
require "Typ"

class BaumTyp < Typ
  HorizontalerAbstandFaktor = 1.5
  HorizontalerAbstandMinimum = 7
  VertikalerAbstandFaktor = 1.5
  VertikalerAbstandMinimum = 1
  MussFaerbenNummern = [1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
  DarfFaerbenNummern = [0, 10, 51, 52, 53, 54, 55, 56, 57, 58, 59, 71, 72, 73, 74, 75, 76, 77, 78, 79, 91, 92, 93, 94, 95, 96, 97, 98, 99, 254]
  MindestAbstand = -1
  
  def macheTerrain(datenFarbe, x, y)
    if rand(255) + 1 <= ChunkyPNG::Color.g(datenFarbe)
      baum = Laubbaum.new(30)
      return [baum.malen(), [15, 30]]
    else
      baum = Nadelbaum.new(30)
      return [baum.malen(), [15, 30]]
    end
  end

  def definiereTerrain?(datenFarbe)
    rand(1024) <= 255
  end

  def erstelleHintergrund(hintergrund)
  end
end
