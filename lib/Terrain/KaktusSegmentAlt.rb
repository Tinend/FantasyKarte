require 'versetzePunkteArray'

class KaktusSegmentAlt
  def initialize(linkePunkte, mittlerePunkte, rechtePunkte, minFarbe, maxFarbe, randFarbe, linienFarbe, ordnungsZahl)
    @linkePunkte = linkePunkte
    @mittlerePunkte = mittlerePunkte
    @rechtePunkte = rechtePunkte
    @minFarbe = minFarbe
    @maxFarbe = maxFarbe
    @randFarbe = randFarbe
    @linienFarbe = linienFarbe
    @ordnungsZahl = ordnungsZahl
  end

  attr_reader :ordnungsZahl
  
  def <=>(x)
    return @ordnungsZahl <=> x.ordnungsZahl
  end

  def malen(png, x, y)
    kleinBild = ChunkyPNG::Image.new(png.width, png.height, ChunkyPNG::Color::TRANSPARENT)
    randBild = ChunkyPNG::Image.new(png.width, png.height, ChunkyPNG::Color::TRANSPARENT)
    grundMalen(kleinBild, x, y, randBild)
    loecherStopfen(kleinBild, randBild)
    kleinBild.compose!(randBild)
    randMalen(kleinBild, randBild)
    linkePunkte = Array.new(@linkePunkte.length) {|i|
      ChunkyPNG::Point.new((@linkePunkte[i][0] + x).round, (y - @linkePunkte[i][1]).round)
    }
    #kleinBild.bezier_curve(linkePunkte, stroke_color = ChunkyPNG::Color.rgb(@randFarbe, 255, (@mittlerePunkte[0][1] * 8).round))
    #kleinBild.bezier_curve(linkePunkte, stroke_color = ChunkyPNG::Color.rgb(@randFarbe, @randFarbe, @randFarbe))
    rechtePunkte = Array.new(@rechtePunkte.length) {|i|
      ChunkyPNG::Point.new((@rechtePunkte[i][0] + x).round, (y - @rechtePunkte[i][1]).round)
    }
    #kleinBild.bezier_curve(rechtePunkte, stroke_color = ChunkyPNG::Color.rgb(@randFarbe, @randFarbe, @randFarbe))
    #kleinBild.bezier_curve(rechtePunkte, stroke_color = ChunkyPNG::Color.rgb(255, @randFarbe, @randFarbe))
    png.compose!(kleinBild)
  end

  def randKuerzen(randBild)
    kopie = ChunkyPNG::Image.new(randBild.width, randBild.height, ChunkyPNG::Color::TRANSPARENT)
    randBild.height.times do |y|
      randBild.width.times do |x|
        leer = 0
        leer += 1 if x == 0 or randBild[x - 1, y] == ChunkyPNG::Color::TRANSPARENT
        leer += 1 if x == randBild.width - 1 or randBild[x + 1, y] == ChunkyPNG::Color::TRANSPARENT
        leer += 1 if y == 0 or randBild[x, y - 1] == ChunkyPNG::Color::TRANSPARENT
        leer += 1 if y == randBild.height  - 1 or randBild[x, y + 1] == ChunkyPNG::Color::TRANSPARENT
        kopie[x,y] = randBild[x,y] if leer < 3
      end
    end
    kopie
  end
  
  def randMalen(kleinBild, randBild)
    #randBild = randKuerzen(randBild)
    kleinBild.height.times do |y|
      kleinBild.width.times do |x|
        next if randBild[x, y] == ChunkyPNG::Color::BLACK
        next if kleinBild[x, y] == ChunkyPNG::Color::TRANSPARENT
        if x == 0 or x == kleinBild.width - 1 or y == 0 or y == kleinBild.height - 1
          kleinBild[x, y] = ChunkyPNG::Color.rgb(@randFarbe, @randFarbe, @randFarbe)
          #kleinBild[x, y] = ChunkyPNG::Color.rgb(255, @randFarbe, @randFarbe)
          next
        end
        leer = 0
        9.times do |verschiebung|
          leer += 1 if kleinBild[x - 1 + verschiebung % 3, y - 1 + verschiebung / 3] == ChunkyPNG::Color::TRANSPARENT
        end
        if leer > 1
          kleinBild[x, y] = ChunkyPNG::Color.rgb(@randFarbe, @randFarbe, @randFarbe)
          #kleinBild[x, y] = ChunkyPNG::Color.rgb(255, @randFarbe, @randFarbe)
        end
      end
    end
  end
  
  def loecherStopfen(kleinBild, randBild)
    kleinBild.height.times do |y|
      (kleinBild.width - 2).times do |x|
        if ChunkyPNG::Color.a(kleinBild.get_pixel(x, y)) != 0 and ChunkyPNG::Color.a(kleinBild.get_pixel(x + 1, y)) == 0 and ChunkyPNG::Color.a(kleinBild.get_pixel(x + 2, y)) != 0
          grau = (ChunkyPNG::Color.b(kleinBild.get_pixel(x, y)) + ChunkyPNG::Color.b(kleinBild.get_pixel(x + 2, y))) / 2
          kleinBild[x + 1, y] = ChunkyPNG::Color.rgb(grau, grau, grau)
          randBild[x + 1, y] = ChunkyPNG::Color::BLACK
       end
      end
    end
    kleinBild.width.times do |x|
      (kleinBild.height - 2).times do |y|
        if ChunkyPNG::Color.a(kleinBild.get_pixel(x, y)) != 0 and ChunkyPNG::Color.a(kleinBild.get_pixel(x, y + 1)) == 0 and ChunkyPNG::Color.a(kleinBild.get_pixel(x, y + 2)) != 0
          grau = (ChunkyPNG::Color.b(kleinBild.get_pixel(x, y)) + ChunkyPNG::Color.b(kleinBild.get_pixel(x, y + 2))) / 2
          kleinBild[x, y + 1] = ChunkyPNG::Color.rgb(grau, grau, grau)
          randBild[x, y + 1] =ChunkyPNG::Color::BLACK
       end
      end
    end
  end

  def grundMalen(png, x, y, randBild)
    pos = [0, 0]
    radiusHorizontal = ((@linkePunkte[0][0] - @rechtePunkte[0][0]) ** 2 + (@linkePunkte[0][1] - @rechtePunkte[0][1]) ** 2) ** 0.5 / 2
    mittelpunkt = [(@rechtePunkte[0][0] - @linkePunkte[0][0]) / 2, (@rechtePunkte[0][1] - @linkePunkte[0][1]) / 2]
    radiusVertikal = (((@rechtePunkte[0][0] + @linkePunkte[0][0]) / 2 - @mittlerePunkte[0][0]) ** 2 + ((@rechtePunkte[0][1] + @linkePunkte[0][1]) / 2 - @mittlerePunkte[0][1]) ** 2) ** 0.5
    richtungHorizontal = [(@linkePunkte[0][0] - @rechtePunkte[0][0]) / radiusHorizontal / 2, (@linkePunkte[0][1] - @rechtePunkte[0][1]) / radiusHorizontal / 2]
    richtungVertikal = [((@rechtePunkte[0][0] + @linkePunkte[0][0]) / 2 - @mittlerePunkte[0][0]) / radiusVertikal, ((@rechtePunkte[0][1] + @linkePunkte[0][1]) / 2 - @mittlerePunkte[0][1]) / radiusVertikal]
    brezierMalen(png, x, y, pos, randBild, true)
    until [pos[0] + @linkePunkte[0][0], pos[1] + @linkePunkte[0][1]] == @mittlerePunkte[0]
      moeglichePositionen = [
        [pos[0] + 1, pos[1]],
        [pos[0] - 1, pos[1]],
        [pos[0], pos[1] + 1],
        [pos[0], pos[1] - 1]
      ]
      moeglichePositionen.delete_if{|mPos| (mPos[0] - (@mittlerePunkte[0][0] - @linkePunkte[0][0])) ** 2 + (mPos[1] - (@mittlerePunkte[0][1] - @linkePunkte[0][1])) ** 2 > (pos[0] - (@mittlerePunkte[0][0] - @linkePunkte[0][0])) ** 2 + (pos[1] - (@mittlerePunkte[0][1] - @linkePunkte[0][1])) ** 2}
      break if moeglichePositionen == []
      pos = moeglichePositionen[0]
      moeglichePositionen.each do |mPos|
        aPos = (richtungHorizontal[0] * (mittelpunkt[1] - pos[1]) - richtungHorizontal[1] * (mittelpunkt[0] - pos[0])) / (richtungVertikal[0] * richtungHorizontal[1] - richtungVertikal[1] * richtungHorizontal[0])
        bPos = (richtungVertikal[0] * (mittelpunkt[1] - pos[1]) - richtungVertikal[1] * (mittelpunkt[0] - pos[0])) / (richtungHorizontal[0] * richtungVertikal[1] - richtungHorizontal[1] * richtungVertikal[0])
        aMPos = (richtungHorizontal[0] * (mittelpunkt[1] - mPos[1]) - richtungHorizontal[1] * (mittelpunkt[0] - mPos[0])) / (richtungVertikal[0] * richtungHorizontal[1] - richtungVertikal[1] * richtungHorizontal[0])
        bMPos = (richtungVertikal[0] * (mittelpunkt[1] - mPos[1]) - richtungVertikal[1] * (mittelpunkt[0] - mPos[0])) / (richtungHorizontal[0] * richtungVertikal[1] - richtungHorizontal[1] * richtungVertikal[0])
        pos = mPos if (1 - (aPos / radiusVertikal) ** 2 - (bPos / radiusHorizontal) ** 2).abs > (1 - (aMPos / radiusVertikal) ** 2 - (bMPos / radiusHorizontal) ** 2).abs
      end
      brezierMalen(png, x, y, pos, randBild, false)
    end
    until [pos[0] + @linkePunkte[0][0], pos[1] + @linkePunkte[0][1]] == @rechtePunkte[0]
      moeglichePositionen = [
        [pos[0] + 1, pos[1]],
        [pos[0] - 1, pos[1]],
        [pos[0], pos[1] + 1],
        [pos[0], pos[1] - 1]
      ]
      moeglichePositionen.delete_if{|mp| (mp[0] - (@rechtePunkte[0][0] - @linkePunkte[0][0])) ** 2 + (mp[1] - (@rechtePunkte[0][1] - @linkePunkte[0][1])) ** 2 > (pos[0] - (@rechtePunkte[0][0] - @linkePunkte[0][0])) ** 2 + (pos[1] - (@rechtePunkte[0][1] - @linkePunkte[0][1])) ** 2}
      moeglichePositionen.delete_if{|mp| mp[0] ** 2 + mp[1] ** 2 > (@rechtePunkte[0][0] - @linkePunkte[0][0]) ** 2 + (@rechtePunkte[0][1] - @linkePunkte[0][1]) ** 2}
      break if moeglichePositionen == []
      pos = moeglichePositionen[0]
      moeglichePositionen.each do |mPos|
        aPos = (richtungHorizontal[0] * (mittelpunkt[1] - pos[1]) - richtungHorizontal[1] * (mittelpunkt[0] - pos[0])) / (richtungVertikal[0] * richtungHorizontal[1] - richtungVertikal[1] * richtungHorizontal[0])
        bPos = (richtungVertikal[0] * (mittelpunkt[1] - pos[1]) - richtungVertikal[1] * (mittelpunkt[0] - pos[0])) / (richtungHorizontal[0] * richtungVertikal[1] - richtungHorizontal[1] * richtungVertikal[0])
        aMPos = (richtungHorizontal[0] * (mittelpunkt[1] - mPos[1]) - richtungHorizontal[1] * (mittelpunkt[0] - mPos[0])) / (richtungVertikal[0] * richtungHorizontal[1] - richtungVertikal[1] * richtungHorizontal[0])
        bMPos = (richtungVertikal[0] * (mittelpunkt[1] - mPos[1]) - richtungVertikal[1] * (mittelpunkt[0] - mPos[0])) / (richtungHorizontal[0] * richtungVertikal[1] - richtungHorizontal[1] * richtungVertikal[0])
        pos = mPos if (1 - (aPos / radiusVertikal) ** 2 - (bPos / radiusHorizontal) ** 2).abs > (1 - (aMPos / radiusVertikal) ** 2 - (bMPos / radiusHorizontal) ** 2).abs
      end
      brezierMalen(png, x, y, pos, randBild, false)
    end
    brezierMalen(png, x, y, pos, randBild, true)
    pos
  end

  def brezierMalen(png, x, y, pos, randBild, ende = false)
    xRichtung = [(@rechtePunkte[0][0] - @linkePunkte[0][0]) / 2.0, (@rechtePunkte[0][1] - @linkePunkte[0][1]) / 2.0]
    yRichtung = [@mittlerePunkte[0][0] - (@rechtePunkte[0][0] + @linkePunkte[0][0]) / 2.0, @mittlerePunkte[0][1] - (@rechtePunkte[0][1] + @linkePunkte[0][1]) / 2.0]
    xFaktor = (pos[1] * yRichtung[0] - pos[0] * yRichtung[1]) / (xRichtung[1] * yRichtung[0] - xRichtung[0] * yRichtung[1])
    yFaktor = (pos[1] * xRichtung[0] - pos[0] * xRichtung[1]) / (yRichtung[1] * xRichtung[0] - yRichtung[0] * xRichtung[1])
    punkteArray = Array.new(@linkePunkte.length) {|i|
      xRichtungI = [(@rechtePunkte[i][0] - @linkePunkte[i][0]) / 2.0, (@rechtePunkte[i][1] - @linkePunkte[i][1]) / 2.0]
      yRichtungI = [@mittlerePunkte[i][0] - (@rechtePunkte[i][0] + @linkePunkte[i][0]) / 2.0, @mittlerePunkte[i][1] - (@rechtePunkte[i][1] + @linkePunkte[i][1]) / 2.0]
      punkt = ChunkyPNG::Point.new((xFaktor * xRichtungI[0] + yFaktor * yRichtung[0] + x + @linkePunkte[i][0]).round, y - (xFaktor * xRichtung[1] + yFaktor * yRichtung[1] + @linkePunkte[i][1]).round)
      #if (i == 0 or i == @linkePunkte.length - 1) and ende == false
      if i == 0 and ende == false
        randBild[punkt.x, punkt.y] = ChunkyPNG::Color::BLACK
      end
      punkt
    }
    xFaktor = [0, xFaktor].max
    xFaktor = [2, xFaktor].min
    farbe = (@maxFarbe * xFaktor + @minFarbe * (2 - xFaktor)) / 2
    png.bezier_curve(punkteArray, stroke_color = ChunkyPNG::Color.rgb(farbe.round, farbe.round, farbe.round))
    
  end

end
