require "Gras"
require "Typ"
require "definiereNeigungen"
require "schaetzeErwartungswert"
require "schaetzeVarianz"

class GrasTyp < Typ
  HorizontalerAbstandFaktor = 0
  HorizontalerAbstandMinimum = 0
  VertikalerAbstandFaktor = 0
  VertikalerAbstandMinimum = 0
  MussFaerbenNummern = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80]
  DarfFaerbenNummern = [0, 51, 52, 53, 54, 55, 56, 57, 58, 59, 91, 92, 93, 94, 95, 96, 97, 98, 99, 254]
  MindestAbstand = -1
  
  def initialize(breite, hoehe)
    super(breite, hoehe)
    @neigungen = definiereNeigungen(breite, hoehe, 0.9)
  end
  
  def definiereTerrain?(datenFarbe)
    false
  end

  def erstelleHintergrund(hintergrund)
    erwartungswert = schaetzeErwartungswert(@neigungen.reduce(:+))
    varianz = schaetzeVarianz(@neigungen.reduce(:+), 0)
    p ["X", erwartungswert, 0]
    p [varianz, schaetzeVarianz(@neigungen.reduce(:+), erwartungswert)]
    @hintergrund.height.times do |y|
      @hintergrund.width.times do |x|
        if @hintergrund[x, y] != ChunkyPNG::Color::TRANSPARENT
          posx = x
          posy = y
          if rand(3) != 0
            grau = rand(24) + 232
          elsif rand(2) == 0
            grau = rand(48) + 208
          elsif rand(2) == 0
            grau = rand(96) + 160
          elsif rand(3) != 0
            grau = rand(144) + 112
          else
            grau = rand(192) + 64
          end
          farbe = ChunkyPNG::Color.rgb(grau, grau, grau)
          male = 1
          if rand(5) == 0
            male = 2
          elsif rand(10) == 0
            while rand(1 + male) <= 1
              male += 1
            end
            male = 10 + rand(4)
            grau -= 10
          end
          male.times do |i|
            hintergrund[posx, posy] = farbe if posx >= 0 and posx < @hintergrund.width and posy >= 0 and posy < @hintergrund.height and @hintergrund[posx, posy] != ChunkyPNG::Color::TRANSPARENT
            posy -= 1
            neigungsWert = @neigungen[x][y] + (rand(0) * 2 - 1) * varianz * 3
            if neigungsWert < - 6 * varianz and i > 0
              posx -= 1
              posy += 1
            elsif neigungsWert > 6 * varianz and i > 0
              posx += 1
              posy += 1
            elsif neigungsWert < - 2 * varianz
              posx -= 1
            elsif neigungsWert > 2 * varianz
              posx += 1
            end
          end
        end
      end
    end
  end
end
