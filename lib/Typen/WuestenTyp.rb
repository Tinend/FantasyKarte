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

  def initialize(breite, hoehe, primaerWind: @primaerWind, sekundaerWind: @sekundaerWind)
    super(breite, hoehe)
    @primaerWind = primaerWind
    @sekundaerWind = sekundaerWind
    #@sinusKonstante1 = 15.0 + rand(10)
    @sinusKonstante1 = 24.0
    @sinusKonstante2 = Math::PI * 0.4 * rand(0) + 0.1 * Math::PI
    @sinusKonstante3 = 5.0 + rand(50)
    @sinusKonstante4 = Math::PI * rand(0) * 2
    @sinusKonstante5 = 50.0 + rand(250)    
    @wertKonstante1 = rand(100) + 50.0
  end
  
  def definiereTerrain?(datenFarbe)
    false
  end

  def macheTerrain(datenFarbe, x, y)
  end

  def erstelleHintergrund(hintergrund)
    @wuestenErsteller = WuestenErsteller.new(@hintergrund, primaerWind: @primaerWind, sekundaerWind: @sekundaerWind)
    hintergrund.height.times do |y|
      hintergrund.width.times do |x|
        if @hintergrund[x, y] != ChunkyPNG::Color::TRANSPARENT
          grau = @wuestenErsteller.berechneHelligkeitAnKoordinate(x: x, kartenY: y)
          hintergrund[x, y] = ChunkyPNG::Color.rgb(grau, grau, grau)
        end
      end
    end
  end

  def berechneDuenenFarbe(x, y)
    raise
    winkel = (y / @sinusKonstante1 + @sinusKonstante2 * Math::cos(x / @sinusKonstante3 + @sinusKonstante4 * Math::cos(y / @sinusKonstante5))) + 1000 * Math::PI
    wert = Math::sin(x / @wertKonstante1) + 0.3
    wert = [[0.0, wert].max, 1.0].min
    duenenSinus = quadratSinus(winkel, wert)
    ((duenenSinus + 1) * 50).round
  end

  def quadratSinus(winkel, wert)
    raise
    if (winkel / (Math::PI / 2)).to_i % 2 == 0
      return 1 - Math::sin(winkel % Math::PI * wert + (1 - wert) * Math::PI / 2)
    else
      return Math::sin(winkel % Math::PI * wert + (1 - wert) * Math::PI / 2) - 1
    end
  end
  
  def erstelleStein(hintergrund, x, y)
    raise
    if rand(10) == 0
      stein = [[x, y]]
    elsif rand(5) == 0
      stein = [[x, y], [x - 1, y]]
    elsif rand(4) == 0
      stein = [[x, y], [x, y - 1]]
    elsif rand(10) == 0
      stein = [[x, y], [x - 1, y], [x, y - 1], [x - 1, y - 1], [x, y - 2], [x - 1, y - 2]]
    elsif rand(9) == 0
      stein = [[x, y], [x - 1, y], [x - 2, y], [x, y - 1], [x - 1, y], [x - 2, y - 1]]
    else
      stein = [[x, y], [x - 1, y], [x, y - 1], [x - 1, y]]
    end
    stein.delete_if {|pos| pos[0] < 0 or pos[1] < 0 or pos[0] >= @hintergrund.width or pos[1] >= @hintergrund.height}
    stein.delete_if {|pos| @hintergrund[pos[0], pos[1]] == ChunkyPNG::Color::TRANSPARENT}
    stein.each do |pos|
      grau = 100 - berechneDuenenFarbe(pos[0], pos[1])
      hintergrund[pos[0], pos[1]] = ChunkyPNG::Color.rgb(grau, grau, grau)
    end
  end
end
