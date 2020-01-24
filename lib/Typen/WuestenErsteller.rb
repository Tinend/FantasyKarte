require "berechneEntfernung"

class WuestenErsteller
  def initialize(bild, wind)
    @wind = wind
    @bild = bild
    @entfernungen = berechneEntfernung(bild)
    @duenen = Array.new(@entfernungen.length) {Array.new(@entfernungen[0].length, 0)}
    400.times do
      erschaffeDuene(((@entfernungen[0].length - @entfernungen[0].length / 5) * rand(0) + @entfernungen[0].length / 10).round , ((@entfernungen.length  - @entfernungen.length / 5) * rand(0) + @entfernungen.length / 10).round)
    end
    #10.times do |y|
    #  10.times do |x|
    #    erschaffeDuene(((@entfernungen[0].length - 1) / 10 * (x + rand(0))).round, ((@entfernungen.length - 1) / 10 * (y + rand(0))).round)
    #  end
    #end
  end

  attr_reader :duenen

  def erschaffeDuene(x, y)
    duene = Array.new(@entfernungen.length) {Array.new(@entfernungen[0].length, 0)}
    maxHoehe = @entfernungen[y][x] ** 0.4 * @wind.geschwindigkeit(x.round, y.round) / 5
    p maxHoehe
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
    @duenen.each_with_index do |zeile, y|
      zeile.collect!.with_index {|punkt, x| [punkt, duene[y][x]].max}
    end
  end

  def erstelleArm(x, y, hoehe, maxHoehe, laenge, orientierung, alter, duene)
    hoehe = [hoehe, @entfernungen[y][x] / 0.27].min
    laenge.round.times do |i|
      vektor = @wind.senkrecht(x, y, orientierung)
      #vektor = @wind.wind[y.round][x.round].senkrecht(orientierung)
      #vektor = vektor.zip(@wind.wind[y.round][x.round].vektor).map {|element| element[0] * (1 - i * alter / laenge.to_f) + i * alter / laenge.to_f * element[1]}
      vektor = vektor.zip(@wind.vektor(x.round, y.round)).map {|element| element[0] * (1 - i * alter / laenge.to_f) + i * alter / laenge.to_f * element[1]}
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
    hoehe = (hoehe ** 2 + @duenen[y.round][x.round] ** 2) ** 0.5
    hoehe = [hoehe, @entfernungen[y.round][x.round] / 0.27].min
    #p [hoeheAlt, hoehe]
    duene[y.round][x.round] = [duene[y.round][x.round], hoehe].max
    vorwaertsErstellen(x, y, hoehe, duene)
    rueckwaertsErstellen(x, y, hoehe, duene)
  end

  def vorwaertsErstellen(x, y, hoehe, duene)
    return if x.round < 0 or y.round < 0 or y.round >= @duenen.length or x.round >= @duenen[0].length
    hoehe = [hoehe, @entfernungen[y.round][x.round] * 3 ** 0.5].min
    30.times do
      richtung = @wind.richtung(x.round, y.round)
      xAlt = x
      yAlt = y
      x += richtung[0] * 0.5
      y += richtung[0] * 0.5
      hoehe -= 3 ** -0.5 if xAlt != x or yAlt != y
      return if hoehe < 0
      return if x.round < 0 or y.round < 0 or y.round >= @duenen.length or x.round >= @duenen[0].length
      duene[y.round][x.round] = [duene[y.round][x.round], hoehe].max
    end
    vektor = @wind.senkrecht(x.round, y.round, 1)
    vorwaertsErstellen(x + vektor[0] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 3, y + vektor[1] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 3, hoehe, duene)
    vorwaertsErstellen(x - vektor[0] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 3, y - vektor[1] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 3, hoehe, duene)
  end
  
  def rueckwaertsErstellen(x, y, hoehe, duene)
    return if x.round < 0 or y.round < 0 or y.round >= @duenen.length or x.round >= @duenen[0].length
    hoehe = [hoehe, @entfernungen[y.round][x.round] / 0.27].min
    30.times do
      richtung = @wind.richtung(x.round, y.round)
      xAlt = x
      yAlt = y
      x -= richtung[0] * 0.5
      y -= richtung[0] * 0.5
      hoehe -= 0.27 if xAlt != x or yAlt != y
      return if hoehe < 0
      return if x.round < 0 or y.round < 0 or y.round >= @duenen.length or x.round >= @duenen[0].length
      duene[y.round][x.round] = [duenen[y.round][x.round], hoehe].max
    end
    vektor = @wind.senkrecht(x.round, y.round, 1)
    rueckwaertsErstellen(x + vektor[0] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 3, y + vektor[1] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 3, hoehe, duene)
    rueckwaertsErstellen(x - vektor[0] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 3, y - vektor[1] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 3, hoehe, duene)
  end
end
