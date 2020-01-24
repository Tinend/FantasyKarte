require 'versetzePunkteArray'
class Gras
  def initialize(hoehe, neigung, blaetterErwartung)
    @farbe = rand(239)
    @neigung = neigung
    @maxHoehe = hoehe * (3 - rand(0)) / 3
    @mitte = hoehe
    blaetter = 0
    blattWert = 0
    until blattWert >= blaetterErwartung
      blaetter += 1
      blattWert += rand(17) * rand(17)
    end
    blaetter = [1, blaetter].max
    @punkteArray = []
    if rand(3) == 0
      hoehe = @maxHoehe
      winkel = Math::PI / 2
      ((blaetter + 1) / 2).times do |i|
        winkel *= (1 - rand(0) ** 2)
        if i > blaetter / 2 - 1
          @punkteArray.push(halmKreieren(Math::PI / 2, @maxHoehe, @maxHoehe))
        else
          @punkteArray.push(halmKreieren(winkel, @maxHoehe * (winkel / Math::PI + 0.5),  @maxHoehe * (winkel / Math::PI + 0.5)))
          @punkteArray.push(halmKreieren(Math::PI - winkel, @maxHoehe * (winkel / Math::PI + 0.5),  @maxHoehe * (winkel / Math::PI + 0.5)))
        end
      end
    else
      hoehe = @maxHoehe
      winkel = Math::PI / 2
      blaetter.times do |i|
        winkel *= (1 - rand(0) ** 2) ** 0.5
        if rand(2) == 0
          w = winkel
        else
          w = Math::PI - winkel
        end
        @punkteArray.push(halmKreieren(w, @maxHoehe * (winkel / Math::PI + 0.5), @maxHoehe * (winkel / Math::PI + 0.5)))
      end
    end
  end

  def halmKreieren(winkel, abstand, maxhoehe)
    if @neigung < 128
      echtWinkel = (winkel / Math::PI) ** ((128 - @neigung) / 32.0 + 1) * Math::PI
    elsif @neigung > 128
      echtWinkel = (1 - ((1 - winkel / Math::PI) ** ((@neigung - 128) / 32.0 + 1))) * Math::PI
    else
      echtWinkel = winkel
    end
    return [
      ChunkyPNG::Point.new(@mitte + 1, 0),
      #ChunkyPNG::Point.new(@mitte + 1, - @mitte + 1)
      ChunkyPNG::Point.new((@mitte + 1 + @maxHoehe * (@neigung - 128) / 1024).round, - maxhoehe.round),
      ChunkyPNG::Point.new((@mitte + 1 + abstand * Math::cos(echtWinkel)).round, - (abstand * Math::sin(echtWinkel)).round)
    ]
  end
  
  def malen()
    @kleinBild = ChunkyPNG::Image.new(@mitte * 2 + 1, @mitte + 3, ChunkyPNG::Color::TRANSPARENT)
    #kurvenMalen(@kleinBild, 1, @mitte + 1, ChunkyPNG::Color::WHITE)
    kurvenMalen(@kleinBild, 0, @mitte + 1, ChunkyPNG::Color::WHITE)
    #kurvenMalen(@kleinBild, - 1, @mitte + 1, ChunkyPNG::Color::WHITE)

    kurvenMalen(@kleinBild, 1, @mitte + 2, ChunkyPNG::Color::WHITE)
    #kurvenMalen(@kleinBild, - 1, @mitte + 2, ChunkyPNG::Color::WHITE)
    #kurvenMalen(@kleinBild, 1, @mitte + 3, ChunkyPNG::Color::WHITE)

    #kurvenMalen(@kleinBild, 0, @mitte + 3, ChunkyPNG::Color::WHITE)
    #kurvenMalen(@kleinBild, - 1, @mitte + 3, ChunkyPNG::Color::WHITE)
    #kurvenMalen(@kleinBild, 0, @mitte + 2, ChunkyPNG::Color::BLACK)
    kurvenMalen(@kleinBild, 0, @mitte + 2, ChunkyPNG::Color.rgb(@farbe, @farbe, @farbe))
    return @kleinBild
  end
  
  def kurvenMalen(png, x, y, farbe)
    @punkteArray.each do |punkte|
      png.bezier_curve(versetzePunkteArray(punkte, x, y), stroke_color = farbe)
    end
  end
  
end
