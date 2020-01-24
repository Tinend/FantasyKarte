class Baum
  def initialize(hoehe)
    @maxHoehe = hoehe
  end

  def malen()
    @kleinBild = ChunkyPNG::Image.new(@maxHoehe, @maxHoehe, ChunkyPNG::Color::TRANSPARENT)
    #kurvenMalen(@kleinBild, @maxHoehe / 2 - 1, @maxHoehe - 2, ChunkyPNG::Color::WHITE, ChunkyPNG::Color::WHITE)
    #kurvenMalen(@kleinBild, @maxHoehe / 2, @maxHoehe - 2, ChunkyPNG::Color::WHITE, ChunkyPNG::Color::WHITE)
    #kurvenMalen(@kleinBild, @maxHoehe / 2 + 1, @maxHoehe - 2, ChunkyPNG::Color::WHITE, ChunkyPNG::Color::WHITE)
    #kurvenMalen(@kleinBild, @maxHoehe / 2 - 1, @maxHoehe - 1, ChunkyPNG::Color::WHITE, ChunkyPNG::Color::WHITE)
    #kurvenMalen(@kleinBild, @maxHoehe / 2 + 1, @maxHoehe - 1, ChunkyPNG::Color::WHITE, ChunkyPNG::Color::WHITE)
    blattMalen(@kleinBild, @maxHoehe / 2, @maxHoehe - 1, ChunkyPNG::Color.rgb(@blattFarbe, @blattFarbe, @blattFarbe))
    weissMalen(@kleinBild)
    stammMalen(@kleinBild, @maxHoehe / 2, @maxHoehe - 1, ChunkyPNG::Color.rgb(@stammFarbe, @stammFarbe, @stammFarbe), ChunkyPNG::Color.rgb(@blattFarbe, @blattFarbe, @blattFarbe))
    return @kleinBild
  end
  
  def kurvenMalen(png, x, y, farbe)
  end
  
  def weissMalen(png)
    hilfsBild = ChunkyPNG::Image.new(@maxHoehe, @maxHoehe, ChunkyPNG::Color::TRANSPARENT)
    @maxHoehe.times do |x|
      maxy = @maxHoehe - 1
      miny = 0
      until maxy < miny or (ChunkyPNG::Color.a(png.get_pixel(x, miny)) != 0 and not ChunkyPNG::Color.r(png.get_pixel(x, miny)) == 255)
        miny += 1
      end
      #miny += 1
      until maxy < miny or (ChunkyPNG::Color.a(png.get_pixel(x, maxy)) != 0 and not ChunkyPNG::Color.r(png.get_pixel(x, miny)) == 255)
        maxy -= 1
      end
      #maxy -= 1
      (maxy - miny).times do |y|
        hilfsBild[x, y + miny] = ChunkyPNG::Color.rgb(maxy - miny + 1, y, 0)
        #png[x, y + miny] = ChunkyPNG::Color.rgb(maxy - miny + 1, y, 0)
      end
    end
    #return 0
    png.height.times do |y|
      maxx = png.width - 1
      minx = 0
      until maxx < minx or (ChunkyPNG::Color.a(png.get_pixel(minx, y)) != 0)
        minx += 1
      end
      #minx += 1
      until maxx < minx or (ChunkyPNG::Color.a(png.get_pixel(maxx, y)) != 0)
        maxx -= 1
      end
      #maxx -= 1
      (maxx - minx + 1).times do |x|
        if hilfsBild[x + minx, y] != ChunkyPNG::Color::TRANSPARENT #and ChunkyPNG::Color.r(png[x + minx, y]) != @blattFarbe
          pngFarbe = ChunkyPNG::Color.r(png[x + minx, y])
          pngFarbe = 255 if ChunkyPNG::Color.a(png[x + minx, y]) == 0
          grau = innenMalen(maxx - minx + 1, x, ChunkyPNG::Color.r(hilfsBild[x + minx, y]), ChunkyPNG::Color.g(hilfsBild[x + minx, y]))
          farbe = ChunkyPNG::Color.compose_precise(png[x + minx, y], ChunkyPNG::Color.rgb(grau.round, grau.round, grau.round))
          #farbe = ChunkyPNG::Color.compose_precise(png[x + minx, y], ChunkyPNG::Color.rgb(grau.round, 0, 0))
          
          
          #farbe = (innenMalen(maxx - minx + 1, x, ChunkyPNG::Color.r(hilfsBild[x + minx, y]), ChunkyPNG::Color.g(hilfsBild[x + minx, y])) * (pngFarbe - @blattFarbe) + @blattFarbe * (255 - pngFarbe)) / (255 - @blattFarbe)
          #png[x + minx, y] = ChunkyPNG::Color.rgb(farbe.round, farbe.round, farbe.round)
          png[x + minx, y] = farbe
        end
      end
    end
  end
end
