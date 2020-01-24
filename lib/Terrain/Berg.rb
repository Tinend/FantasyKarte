require 'versetzePunkteArray'

class Berg
  def initialize(hoehe, schneeHoehe)
    @hoehe = hoehe
    @schneeHoehe = schneeHoehe
    definierePunkte()
  end

  attr_reader :hoehe

  def definierePunkte()
    @breiten = Array.new(4) {|i|
      if i == 1 or i == 2
        x = (rand(0) + rand(0)) * @schneeHoehe / 3.4
      else
        x = (rand(0) + rand(0)) * @schneeHoehe / 2.2
      end
      x
    }
    y1 = @schneeHoehe * rand(0)
    y2 = @hoehe * (1 + rand(0) / 3 - rand(0) / 3)
    y3 = @schneeHoehe * rand(0)
    yStrafe = y1 + y3 - 2 * y2 + rand(0) * @schneeHoehe
    if yStrafe > 0
      yStrafe1 = yStrafe * rand(0)
      y1 -= y1 * yStrafe1 / (y1 + yStrafe1)
      y3 -= y3 * (yStrafe - yStrafe1) / (y3 + yStrafe - yStrafe1)
    end
    @punkte = [
      ChunkyPNG::Point.new(0, @hoehe.to_i + 3),
      ChunkyPNG::Point.new(@breiten[0..0].reduce(:+), @hoehe.to_i - y1 + 3),
      ChunkyPNG::Point.new(@breiten[0..1].reduce(:+), @hoehe.to_i - y2 + 3),
      ChunkyPNG::Point.new(@breiten[0..2].reduce(:+), @hoehe.to_i - y3 + 3),
      ChunkyPNG::Point.new(@breiten[0..3].reduce(:+), @hoehe.to_i + 3)
    ]
    x = 0
    @schneeLinie = []
    x_alt = 0
    while x_alt.round < @breiten.reduce(:+)
      @schneeLinie.push(ChunkyPNG::Point.new(x.round, @hoehe.to_i - (@schneeHoehe * (1 + rand(0) / 4 - rand(0) / 4)).round))
      x_alt = x
      x += @schneeHoehe * rand(0) / 3
    end
    #spitzeY = [y1, y2, y3].max
    #spitzeX = (3 * @breiten[0] + 2 * @breiten[1] - @breiten[2]) / 3
    #spitze = [spitzeX, spitzeY]
    #@gebirgsLinien = Array.new(([y1, y2, y3].max / @schneeHoehe * 2 * rand(0) + rand(0)).round) {
    #  posy1 = [y1, y2, y3].max * rand(0)
    #  posx1 = zufallsPosX(spitze, posy1)
    #  posy3 = posy1 + spitze[1] * rand(0) / 6
    #  posx3 = zufallsPosX(spitze, posy3) * 0.2 + posx1 * 0.8 * posy3 / posy1
    #  zufallsMitte = rand(0)
    #  posy2 = posy1 * zufallsMitte + posy3 * (1 - zufallsMitte)
    #  posx2 = (posx1 * zufallsMitte + posx3 * (1 - zufallsMitte)) * 0.9 + zufallsPosX(spitze, posy2) * 0.1 + (@hoehe - @schneeHoehe) / @hoehe * (zufallsPosX(spitze, posy2) + zufallsPosX(spitze, posy2)) * 0.1
    #  [
    #    ChunkyPNG::Point.new(posx1, (@hoehe - posy1).round + 3),
    #    ChunkyPNG::Point.new(posx2, (@hoehe - posy2).round + 3),
    #    ChunkyPNG::Point.new(posx3, (@hoehe - posy3).round + 3)
    #  ]
    #}
  end

  def zufallsPosX(spitze, y)
    hoehenFaktor = y / spitze[1]
    spitze[0] * hoehenFaktor + @breiten.reduce(:+) * hoehenFaktor * rand(0)
  end

  def malen()
    @kleinBild = ChunkyPNG::Image.new(@breiten.reduce(:+).to_i + 3, @hoehe.to_i + 3)
    #bildWeiss = kurvenMalen(ChunkyPNG::Color::WHITE)
    bildSchwarz = kurvenMalen(ChunkyPNG::Color::BLACK)
    #@kleinBild.compose!(bildWeiss, offset_x = 0, offset_y = 0)
    #@kleinBild.compose!(bildWeiss, offset_x = 0, offset_y = 1)
    #@kleinBild.compose!(bildWeiss, offset_x = 1, offset_y = 1)
    #@kleinBild.compose!(bildWeiss, offset_x = 2, offset_y = 1)
    #@kleinBild.compose!(bildWeiss, offset_x = 2, offset_y = 0)
    @kleinBild.compose!(bildSchwarz, offset_x = 1, offset_y = 0)
    @kleinBild
  end

  def kurvenMalen(farbe)
    bild = ChunkyPNG::Image.new(@breiten.reduce(:+).to_i + 1, @hoehe.to_i + 1, ChunkyPNG::Color::TRANSPARENT)
    bild.bezier_curve(@punkte, stroke_color = farbe)
    return bild if farbe == ChunkyPNG::Color::WHITE
    schneeBild = ChunkyPNG::Image.new(@breiten.reduce(:+).to_i + 1, @hoehe.to_i + 1, ChunkyPNG::Color::TRANSPARENT)
    @schneeLinie.each_with_index do |sh, i|
      schneeBild.line(@schneeLinie[i - 1].x, @schneeLinie[i - 1].y, sh.x, sh.y, farbe, farbe) if i > 0
    end
    #@gebirgsLinien.each do |gl|
    #  schneeBild.bezier_curve(gl, stroke_color = farbe)
    #end
    #bild.compose!(schneeBild)
    #return bild
    schneeBild.width.times do |x|
      faerben = false
      schnee = true
      schneeBild.height.times do |y|
        schnee = false if schneeBild.get_pixel(x,y) != ChunkyPNG::Color::TRANSPARENT or @schneeHoehe * 3 >= (schneeBild.height - y) * 4
        if bild.get_pixel(x,y) != ChunkyPNG::Color::TRANSPARENT and bild.get_pixel(x,y) / 256 * 256 + 255 != ChunkyPNG::Color::WHITE
          faerben = true
        elsif faerben == true and not schnee
          bild[x, y] = ChunkyPNG::Color.rgb(255, 0, 0)
          #bild[x, y] = ChunkyPNG::Color::WHITE
        end
      end
    end

    bild.height.times do |y|
      minx = 0
      maxx = bild.width - 1
      until minx > maxx or bild[minx, y] != ChunkyPNG::Color::TRANSPARENT
        minx += 1
      end
      until minx > maxx or bild[maxx, y] != ChunkyPNG::Color::TRANSPARENT
        maxx -= 1
      end
      (maxx - minx + 1).times do |i|
        if bild.get_pixel(minx + i, y) == ChunkyPNG::Color.rgb(255, 0, 0)
          grau = 64 + 96 * i / (maxx - minx)
          bild[minx + i, y] = ChunkyPNG::Color.rgb(grau, grau, grau)
        elsif bild.get_pixel(minx + i, y) == ChunkyPNG::Color::TRANSPARENT
          grau = 217 + 38 * i / (maxx - minx)
          bild[minx + i, y] = ChunkyPNG::Color.rgb(grau, grau, grau)
        end
      end
    end
    
    schneeBild.width.times do |x|
      faerben = false
      schneeBild.height.times do |y|
        faerben = true if bild.get_pixel(x,y) != ChunkyPNG::Color::TRANSPARENT and bild.get_pixel(x,y) / 256 * 256 + 255 != ChunkyPNG::Color::WHITE
        if faerben == true
          bild.compose_pixel(x, y, schneeBild.get_pixel(x,y))
        end
      end
    end
    
    bild
  end
  
end
