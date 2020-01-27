require "berechneEntfernung"
require "DuenenPunkt"

class WuestenErsteller

  GlaetteDistanz = 3
  MaxHoehenFaktor = 20
  ZufallsHoehen = 3.0
  
  def initialize(bild, wind)
    @wind = wind
    generiereBild(bild)
    @entfernungen = berechneEntfernung(@bild)
    @duenen = Array.new(@entfernungen.length) {Array.new(@entfernungen[0].length) {rand(0) * ZufallsHoehen}}
    glaette(@duenen)
    4.times do
      erschaffeDuene(((@entfernungen[0].length - @entfernungen[0].length / 5) * rand(0) + @entfernungen[0].length / 10).round, ((@entfernungen.length  - @entfernungen.length / 5) * rand(0) + @entfernungen.length / 10).round)
    end
    glaette(@duenen)
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
    
  def erschaffeDuene(x, y)
    duene = Array.new(@bild.height) {Array.new(@bild.width, 0)}
    maxHoehe = @entfernungen[y][x] ** 0.4 * @wind.geschwindigkeit(x.round, y.round / 2.0) / MaxHoehenFaktor
    maxHoehe *= 3
    alter = rand(0) * (0.5 + rand(0)) / 1.5
    hoehe = maxHoehe + maxHoehe * rand(0)
    laenge = 11 * hoehe + rand(0) * 30 * hoehe
    laenge += rand(0) * 100 * hoehe if rand(2) == 0
    laenge += rand(0) * 120 * hoehe if rand(3) == 0
    laenge += rand(0) * 20 * hoehe if rand(3) == 0
    erstelleDuenenPunkt(x, y, hoehe, duene)
    erstelleArm(x, y, hoehe, maxHoehe, laenge, 1, alter, duene)
    erstelleArm(x, y, hoehe, maxHoehe, laenge, -1, alter, duene)
    glaette(duene)
    @duenen.each_with_index do |zeile, y|
      zeile.collect!.with_index {|punkt, x| (punkt ** 2 + duene[y][x] ** 2) ** 0.5}
    end
  end

  def glaette(duene)
    return if duene.length == 0
    duenenPunkte = []
    duene.length.times do |y|
      duene[0].length.times do |x|
        duenenPunkte.push(DuenenPunkt.new(x: x, y: y, hoehe: duene[y][x], wind: @wind)) if duene[y][x] >= Math::tan(Math::PI / 12)
      end
    end
    duenenPunkte.sort!
    duenenPunkte.reverse!
    duenenPunkte.each_with_index do |duenenPunkt, i|
      #p [i.to_s + " / " + duenenPunkte.length.to_s, duene[duenenPunkt.y][duenenPunkt.x], [duenenPunkt.x, duenenPunkt.y]]
      glaettePunkt(duenenPunkt, duene)
    end
  end

  def glaettePunkt(duenenPunkt, duene)
    punkteListe = [duenenPunkt]
    until punkteListe == []
      punkteListe.sort!
      punkteListe.reverse!
      punkt = punkteListe.shift
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
            verbesserbar.push(DuenenPunkt.new(x: lokalX, y: lokalY, hoehe: neueHoehe, wind: @wind))
          end
        end
      end
      punkteListe += verbesserbar.sort.reverse
    end
  end
  
  def erstelleArm(x, y, hoehe, maxHoehe, laenge, orientierung, alter, duene)
    laenge.round.times do |i|
      vektor = @wind.senkrecht(x, y / 2.0, orientierung)
      #vektor = @wind.wind[y.round][x.round].senkrecht(orientierung)
      #vektor = vektor.zip(@wind.wind[y.round][x.round].vektor).map {|element| element[0] * (1 - i * alter / laenge.to_f) + i * alter / laenge.to_f * element[1]}
      vektor = vektor.zip(@wind.vektor(x.round, y.round / 2.0)).map {|element| element[0] * (1 - i * alter / laenge.to_f) + i * alter / laenge.to_f * element[1]}
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
    duene[y.round][x.round] = [duene[y.round][x.round], hoehe].max
    #vorwaertsErstellen(x, y, hoehe, duene)
    #rueckwaertsErstellen(x, y, hoehe, duene)
  end

  def vorwaertsErstellen(x, y, hoehe, duene)
    return if x.round < 0 or y.round < 0 or y.round >= @duenen.length or x.round >= @duenen[0].length
    100.times do
      richtung = @wind.richtung(x.round, y.round / 2.0)
      xAlt = x
      yAlt = y
      x += richtung[0] * 0.5
      y += richtung[0] * 0.5
      hoehe -= 3 ** -0.5 if xAlt != x or yAlt != y
      return if hoehe < 0
      return if x.round < 0 or y.round < 0 or y.round >= @duenen.length or x.round >= @duenen[0].length
      duene[y.round][x.round] = [duene[y.round][x.round], hoehe].max
    end
    vektor = @wind.senkrecht(x.round, y.round / 2.0, 1)
    vorwaertsErstellen(x + vektor[0] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 3, y + vektor[1] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 3, hoehe, duene)
    vorwaertsErstellen(x - vektor[0] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 3, y - vektor[1] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 3, hoehe, duene)
  end
  
  def rueckwaertsErstellen(x, y, hoehe, duene)
    return if x.round < 0 or y.round < 0 or y.round >= @duenen.length or x.round >= @duenen[0].length
    100.times do
      richtung = @wind.richtung(x.round, y.round / 2.0)
      xAlt = x
      yAlt = y
      x -= richtung[0] * 0.5
      y -= richtung[0] * 0.5
      hoehe -= 0.27 if xAlt != x or yAlt != y
      return if hoehe < 0
      return if x.round < 0 or y.round < 0 or y.round >= @duenen.length or x.round >= @duenen[0].length
      duene[y.round][x.round] = [duenen[y.round][x.round], hoehe].max
    end
    vektor = @wind.senkrecht(x.round, y.round / 2.0, 1)
    rueckwaertsErstellen(x + vektor[0] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 3, y + vektor[1] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 3, hoehe, duene)
    rueckwaertsErstellen(x - vektor[0] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 3, y - vektor[1] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 3, hoehe, duene)
  end
end
