require "Kaktus"
require "Typ"
require "WuestenErsteller"

class WuestenTyp < Typ
  HorizontalerAbstandFaktor = 1.2
  HorizontalerAbstandMinimum = 3
  VertikalerAbstandFaktor = 1
  VertikalerAbstandMinimum = 2
  MussFaerbenNummern = [81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100]
  DarfFaerbenNummern = [0, 11, 12, 13, 14, 15, 16, 17, 18, 19, 51, 52, 53, 54, 55, 56, 57, 58, 59, 71, 72, 73, 74, 75, 76, 77, 78, 79, 254]
  MindestAbstand = -1

  def initialize(breite, hoehe, wind: @wind)
    super(breite, hoehe)
    @wind = wind
    #@sinusKonstante1 = 15.0 + rand(10)
    #sinusKonstante1 = 24.0
    #sinusKonstante2 = Math::PI * 0.4 * rand(0) + 0.1 * Math::PI
    #sinusKonstante3 = 5.0 + rand(50)
    #sinusKonstante4 = Math::PI * rand(0) * 2
    #sinusKonstante5 = 50.0 + rand(250)    
    #wertKonstante1 = rand(100) + 50.0
  end
  
  def definiereTerrain?(datenFarbe)
    false
  end

  def macheTerrain(datenFarbe, x, y)
  end

  def erstelleHintergrund(hintergrund)
    @wuestenErsteller = WuestenErsteller.new(@hintergrund, wind: @wind)
    hintergrund.height.times do |y|
      hintergrund.width.times do |x|
        if @hintergrund[x, y] != ChunkyPNG::Color::TRANSPARENT
          grau = @wuestenErsteller.berechneHelligkeitAnKoordinate(x: x, kartenY: y)
          hintergrund[x, y] = ChunkyPNG::Color.rgb(grau, grau, grau)
        end
      end
    end
  end

end
