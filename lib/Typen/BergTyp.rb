require "Berg"
require "Typ"

class BergTyp < Typ
  HorizontalerAbstandFaktor = 1.5
  HorizontalerAbstandMinimum = 8
  VertikalerAbstandFaktor = 1.4
  VertikalerAbstandMinimum = 6
  MussFaerbenNummern = [41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60]
  DarfFaerbenNummern = [0, 11, 12, 13, 14, 15, 16, 17, 18, 19, 71, 72, 73, 74, 75, 76, 77, 78, 79, 91, 92, 93, 94, 95, 96, 97, 98, 99, 254]
  MindestAbstand = -1

  def macheTerrain(datenFarbe, x, y)
    berg = Berg.new(ChunkyPNG::Color.g(datenFarbe), 20)
    return [berg.malen(), [0, berg.hoehe + 3]]
  end

  def definiereTerrain?(datenFarbe)
    return false if ChunkyPNG::Color.r(datenFarbe) == 50
    rand(1024) <= 255
  end

  def verwalteHintergrund(x, y, datenFarbe)
    grau = ChunkyPNG::Color.g(datenFarbe)
    @hintergrund[x, y] = ChunkyPNG::Color.rgb(grau, grau, grau)
  end

  def erstelleHintergrund(hintergrund)
    # bild = ChunkyPNG::Image.new(@hintergrund.width, @hintergrund.height, ChunkyPNG::Color::WHITE)

    #6.times do |i|
    #  xwert = (1 + rand(0) * 3) * 2 ** (rand(0) * 5)
    #  ywert = (1 + rand(0) * 3) * 2 ** (rand(0) * 5)
    #  xVerschiebung = rand(0) * Math::PI * 2
    #  yVerschiebung = rand(0) * Math::PI * 2
    #  r = (1 + rand(0) * 3) * 2 ** (rand(0) * 5)
    #  winkel = rand(0) * Math::PI * 2
    #   verschiebung = rand(0) * Math::PI * 2
    #   bild.height.times do |y|
    #     bild.width.times do |x|
    #       #grau = ((Math::sin(x.to_f / xwert + xVerschiebung + y.to_f / ywert + yVerschiebung) + 1) * 100 + 55 - ChunkyPNG::Color.b(@hintergrund[x, y]).to_f / 16).round
    #       grau = ((Math::sin(Math::sin(winkel) * x.to_f / r + verschiebung + Math::cos(winkel) * y.to_f / r) + 1) * 100 + 55 - ChunkyPNG::Color.b(@hintergrund[x, y]).to_f / 16).round
    #       bild[x, y] = ChunkyPNG::Color.compose_precise(ChunkyPNG::Color::rgba(grau, grau, grau, 64), bild[x,y])
    #       #bild[x, y] = ChunkyPNG::Color.compose_precise(ChunkyPNG::Color::rgba(255, 32 * i, 0, 100), bild[x,y])
    #       #bild[x, y] = ChunkyPNG::Color::rgba(grau, grau, grau, 255)
    #     end
    #   end
    # end
    hintergrund.height.times do |y|
      hintergrund.width.times do |x|
        if rand(5) != 0
          grau = rand(56) + 200
        else
          grau = rand(200) + 56
        end
        hintergrund[x, y] = ChunkyPNG::Color.rgb(grau, grau, grau) if @hintergrund[x, y] != ChunkyPNG::Color::TRANSPARENT
        #hintergrund[x, y] = bild[x, y] if @hintergrund[x, y] != ChunkyPNG::Color::TRANSPARENT
      end
    end
  end
end
