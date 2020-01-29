require "berechneEntfernung"
require "DuenenPunkt"

class WuestenErsteller

  GlaetteDistanz = 3
  MaxHoehenDivisor = 2.5
  ZufallsHoehen = 2.0
  FreieFelderMaxHoehe = 5
  DuenenWkeit = 0.003
  
  def initialize(bild, primaerWind:, sekundaerWind:)
    @primaerWind = primaerWind
    @sekundaerWind = sekundaerWind
    generiereBild(bild)
    @entfernungen = berechneEntfernung(@bild)
    @duenen = Array.new(@entfernungen.length) {|y| Array.new(@entfernungen[0].length) {|x| rand(0) * ZufallsHoehen * [1, @entfernungen[y][x] * Math::tan(Math::PI / 12) / 10].min}}
    @frei = Array.new(@entfernungen.length) {Array.new(@entfernungen[0].length, true)}
    glaette(@duenen, umkehren: true)
    erstelleDuenen(wind: @primaerWind)
    @frei = Array.new(@entfernungen.length) {Array.new(@entfernungen[0].length, true)}
    glaette(@duenen, umkehren: true)
    erstelleDuenen(wind: @sekundaerWind)
    glaette(@duenen, umkehren: true, wind: nil)
  end

  def erstelleDuenen(wind:)
    return if @duenen.length == 0
    reihenfolge = Array.new(@duenen.length * @duenen[0].length) {|i| i} 
    reihenfolge.shuffle!
    reihenfolge.each_with_index do |nummer, index|
      x = nummer / @duenen.length
      y = nummer % @duenen.length
      #puts "#{index} / #{reihenfolge.length}"
      if @frei[y][x] and rand(0) <= DuenenWkeit
        erschaffeDuene(x, y, wind: wind)
      end
    end
    #300.times do
    #  erschaffeDuene(((@entfernungen[0].length - @entfernungen[0].length / 5) * rand(0) + @entfernungen[0].length / 10).round, ((@entfernungen.length  - @entfernungen.length / 5) * rand(0) + @entfernungen.length / 10).round)
    #end
    #glaette(@duenen)
    #10.times do |y|
    #  10.times do |x|
    #    erschaffeDuene(((@entfernungen[0].length - 1) / 10 * (x + rand(0))).round, ((@entfernungen.length - 1) / 10 * (y + rand(0))).round)
    #  end
    #end
  end

  attr_reader :duenen

  def generiereBild(bild)
    @bild = ChunkyPNG::Image.new(bild.width, bild.height * 2, ChunkyPNG::Color::WHITE)
    bild.height.times do |y|
      bild.width.times do |x|
        @bild[x, y * 2] = bild[x, y]
        @bild[x, y * 2 + 1] = bild[x, y]
      end
    end
  end
    
  def erschaffeDuene(x, y, wind:)
    duene = Array.new(@bild.height) {Array.new(@bild.width, 0)}
    maxHoehe = @entfernungen[y][x] ** 0.4 * wind.geschwindigkeit(x.round, y.round / 2.0) / MaxHoehenDivisor
    alter = rand(0) * (0.5 + rand(0)) / 1.5
    hoehe = maxHoehe * rand(0)
    laenge = 11 * hoehe + rand(0) * 30 * hoehe
    laenge += rand(0) * 100 * hoehe if rand(2) == 0
    laenge += rand(0) * 120 * hoehe if rand(3) == 0
    laenge += rand(0) * 20 * hoehe if rand(3) == 0
    erstelleDuenenPunkt(x, y, hoehe, duene)
    erstelleArm(x, y, hoehe, maxHoehe, laenge, 1, alter, duene)
    erstelleArm(x, y, hoehe, maxHoehe, laenge, -1, alter, duene)
    glaette(duene, umkehren: false, wind: wind)
    @duenen.each_with_index do |zeile, y|
      zeile.collect!.with_index {|punkt, x| (punkt ** 2 + duene[y][x] ** 2) ** 0.5}
    end
  end

  def glaette(duene, umkehren: false, wind: nil)
    return if duene.length == 0
    duenenPunkte = []
    duene.length.times do |y|
      duene[0].length.times do |x|
        if wind != nil
          duenenPunkte.push(DuenenPunkt.new(x: x, y: y, hoehe: duene[y][x], windGeschwindigkeit: wind.geschwindigkeit(x, y / 2.0), windRichtung: wind.richtung(x, y / 2.0))) if duene[y][x] >= Math::tan(Math::PI / 12)
        else
          duenenPunkte.push(DuenenPunkt.new(x: x, y: y, hoehe: duene[y][x], windGeschwindigkeit: nil, windRichtung: nil)) if duene[y][x] >= Math::tan(Math::PI / 6)
        end
      end
    end
    duenenPunkte.sort!
    duenenPunkte.reverse! if umkehren
    duenenPunkte.each_with_index do |duenenPunkt, i|
      #p [i.to_s + " / " + duenenPunkte.length.to_s, duene[duenenPunkt.y][duenenPunkt.x], [duenenPunkt.x, duenenPunkt.y]]
      glaettePunkt(duenenPunkt, duene, wind: wind)
    end
  end

  def glaettePunkt(duenenPunkt, duene, wind:)
    punkteListe = [duenenPunkt]
    maxHoehe = punkteListe.max.hoehe
    until punkteListe == []
      if punkteListe[-1].hoehe + Math::tan(Math::PI / 12) < maxHoehe
        punkteListe.sort!
        maxHoehe = punkteListe[-1].hoehe
      end
      punkt = punkteListe.pop
      next if punkt.hoehe < duene[punkt.y][punkt.x]
      #p ["P", punkt.x, punkt.y, duene[punkt.y][punkt.x]]
      verbesserbar = []
      minX = [0, punkt.x - GlaetteDistanz].max
      maxX = [duene[0].length - 1, punkt.x + GlaetteDistanz].min
      minY = [0, punkt.y - GlaetteDistanz].max
      maxY = [duene.length - 1, punkt.y + GlaetteDistanz].min
      (maxY - minY + 1).times do |kurzY|
        (maxX - minX + 1).times do |kurzX|
          lokalX = kurzX + minX
          lokalY = kurzY + minY
          next if punkt.x == lokalX and punkt.y == lokalY
          neueHoehe = punkt.berechneHoehe(lokalX, lokalY)
          if duene[lokalY][lokalX] < neueHoehe
            #p [[punkt.x, punkt.y], [lokalX, lokalY], duene[lokalY][lokalX], neueHoehe]
            #gets
            duene[lokalY][lokalX] = neueHoehe
            if wind != nil
              verbesserbar.push(DuenenPunkt.new(x: lokalX, y: lokalY, hoehe: neueHoehe, windGeschwindigkeit: @primaerWind.geschwindigkeit(lokalX, lokalY / 2.0), windRichtung: @primaerWind.richtung(lokalX, lokalY / 2.0)))
            else
              verbesserbar.push(DuenenPunkt.new(x: lokalX, y: lokalY, hoehe: neueHoehe, windGeschwindigkeit: nil, windRichtung: nil))
            end
          end
        end
      end
      punkteListe += verbesserbar
    end
  end
  
  def erstelleArm(x, y, hoehe, maxHoehe, laenge, orientierung, alter, duene)
    laenge.round.times do |i|
      vektor = @primaerWind.senkrecht(x, y / 2.0, orientierung)
      #vektor = @primaerWind.wind[y.round][x.round].senkrecht(orientierung)
      #vektor = vektor.zip(@primaerWind.wind[y.round][x.round].vektor).map {|element| element[0] * (1 - i * alter / laenge.to_f) + i * alter / laenge.to_f * element[1]}
      vektor = vektor.zip(@primaerWind.vektor(x.round, y.round / 2.0)).map {|element| element[0] * (1 - i * alter / laenge.to_f) + i * alter / laenge.to_f * element[1]}
      x += vektor[0] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 8
      y += vektor[1] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 8
      return if x.round < 0 or y.round < 0 or y.round >= @duenen.length or x.round >= @duenen[0].length
      erstelleDuenenPunkt(x, y, berechneHoehe(hoehe, laenge, i), duene)
    end
  end

  def berechneHoehe(hoehe, laenge, i)
    hoehe * (1 - i ** 2 / laenge.to_f ** 2)
  end
  
  def erstelleDuenenPunkt(x, y, hoehe, duene)
    hoeheAlt = hoehe
    hoehe = [hoehe, (hoehe * (@entfernungen[y.round][x.round] * Math::tan(Math::PI / 12)) / 2) ** 0.5].min
    besetzePunkte(x.round, y.round, hoehe)
    duene[y.round][x.round] = [duene[y.round][x.round], hoehe].max
  end

  def besetzePunkte(x, y, hoehe)
    radius = hoehe * (1 / Math::tan(Math::PI / 12) + 1 / Math::tan(Math::PI / 6))
    minY = [0, y - radius.to_i].max
    maxY = [@frei.length - 1, y + radius.to_i].min
    (maxY - minY + 1).times do |plusY|
      if plusY.abs == radius
        distanzX = 0
      else
        distanzX = ((radius ** 2 - (plusY - radius.to_i) ** 2) ** 0.5).to_i
      end
      minX = [0, x - distanzX].max
      maxX = [@frei[0].length - 1, x + distanzX].min
      (maxX - minX + 1).times do |plusX|
        @frei[minY + plusY][minX + plusX] = false
      end
    end
  end

  def findeY(x:, kartenY:)
    y = kartenY * 2
    until y == @duenen.length - 1 or (y - kartenY * 2) * Math::tan(Math::PI / 6) >= @duenen[y][x]
      y += 1
    end
    y -= 1 if (y - kartenY * 2) * Math::tan(Math::PI / 6) >= @duenen[y][x]
    y
  end

  def berechneHelligkeitRechtsRunter(x:, y:)
    scheinbareHoehe = Math::cos(Math::PI / 4 - Math::atan((@duenen[y][x] - @duenen[y + 1][x + 1]) / 2 **0.5))
    scheinbareBreite = Math::cos(Math::atan((@duenen[y][x] - @duenen[y + 1][x + 1]) / 2 **0.5))
    return scheinbareHoehe * scheinbareBreite * 256
  end
  
  def berechneHelligkeitAnKoordinate(x:, kartenY:)
    y = findeY(x: x, kartenY: kartenY)
    farben = []
    farben.push(berechneHelligkeitRechtsRunter(x: x - 1, y: y - 1)) if x > 0 and y > 0
    farben.push(berechneHelligkeitRechtsRunter(x: x - 1, y: y)) if x > 0 and y < @duenen.length - 1
    farben.push(berechneHelligkeitRechtsRunter(x: x, y: y - 1)) if x < @duenen[0].length - 1 and y > 0
    farben.push(berechneHelligkeitRechtsRunter(x: x, y: y)) if x < @duenen[0].length - 1 and y < @duenen.length - 1
    return (farben.reduce(:+) / farben.length).round
  end
end
