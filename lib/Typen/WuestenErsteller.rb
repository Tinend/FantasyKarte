require "berechneEntfernung"
require "DuenenPunkt"
require "HoehenProfil/WuestenHoehenPunkt"

class WuestenErsteller

  GlaetteDistanz = 3
  MaxHoehenFaktor1 = 0.3
  MaxHoehenFaktor2 = 6
  ZufallsHoehen = 0.02
  MinHoehe = 0.0001
  FreieFelderMaxHoehe = 5
  DuenenWkeit = 0.3
  HoehenZielZerfall = 0.8
  HoehenZerfall = 0.92
  DuenenEndWkeit = 0.01
  HoehenDuenenAbstand = 2.5
  MaxHoehenDuenenAbstand = 0.15
  RandBreite = 2.5
  MaxGroesseRandPlatz = 8
  MaxHoeheErreichen = 100
  
  def initialize(bild, wind:, hoehenProfil:)
    @hoehenProfil = hoehenProfil
    @wind = wind
    generiereBild(bild)
    @entfernungen = berechneEntfernung(@bild)
    @duenen = Array.new(@entfernungen.length) {|y| Array.new(@entfernungen[0].length) {|x| rand(0) * ZufallsHoehen * [1, @entfernungen[y][x] * Math::tan(Math::PI / 12) / 10].min}}
    glaette(@duenen, umkehren: true)
    erstelleDuenen(wind: @wind, maxHoehenFaktor: MaxHoehenFaktor1)
    erstelleDuenen(wind: @wind, maxHoehenFaktor: MaxHoehenFaktor2)
    glaette(@duenen, umkehren: true)
    updateHoehenProfil
  end
  
  attr_reader :duenen, :bild

  def updateHoehenProfil()
    @duenen.each_with_index do |zeile, y|
      zeile.each_with_index do |hoehe, x|
        @hoehenProfil.hoehenPunktEinfuegen(x: x, y: y, hoehenPunkt: WuestenHoehenPunkt.new(hoehe)) if @entfernungen[y][x] > 0
      end
    end
  end
  
  def generiereBild(bild)
    @bild = ChunkyPNG::Image.new(bild.width, bild.height * 2, ChunkyPNG::Color::TRANSPARENT)
    bild.height.times do |y|
      bild.width.times do |x|
        @bild[x, y * 2] = bild[x, y]
        @bild[x, y * 2 + 1] = bild[x, y]
      end
    end
  end
    
  def glaette(duene, umkehren: false)
    return if duene.length == 0
    duenenPunkte = []
    duene.length.times do |y|
      duene[0].length.times do |x|
        duenenPunkte.push(DuenenPunkt.new(x: x, y: y, hoehe: duene[y][x], windGeschwindigkeit: @wind.geschwindigkeit(x, y / 2.0), windRichtung: @wind.richtung(x, y / 2.0))) if duene[y][x] >= Math::tan(Math::PI / 12)
      end
    end
    duenenPunkte.sort!
    duenenPunkte.reverse! if umkehren
    duenenPunkte.each_with_index do |duenenPunkt, i|
      glaettePunkt(duenenPunkt, duene)
    end
  end

  def glaettePunkt(duenenPunkt, duene)
    punkteListe = [duenenPunkt]
    maxHoehe = punkteListe.max.hoehe
    until punkteListe == []
      if punkteListe[-1].hoehe + Math::tan(Math::PI / 12) < maxHoehe
        punkteListe.sort!
        maxHoehe = punkteListe[-1].hoehe
      end
      punkt = punkteListe.pop
      next if punkt.hoehe < duene[punkt.y][punkt.x]
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
          #p [lokalY, lokalX, duene.length, duene[0].length, duene[lokalY][lokalX]]
          if duene[lokalY][lokalX] < neueHoehe
            duene[lokalY][lokalX] = neueHoehe
            verbesserbar.push(DuenenPunkt.new(x: lokalX, y: lokalY, hoehe: neueHoehe, windGeschwindigkeit: @wind.geschwindigkeit(lokalX, lokalY / 2.0), windRichtung: @wind.richtung(lokalX, lokalY / 2.0)))
          end
        end
      end
      punkteListe += verbesserbar
    end
  end

  def erstelleDuenen(wind:, maxHoehenFaktor:)
    return if @duenen.length == 0
    @frei = Array.new(@entfernungen.length) do |y|
      Array.new(@entfernungen[0].length) do |x|
        frei = true
        frei = false if @entfernungen[y][x] <= 1.5
        frei
      end
    end
    reihenfolge = Array.new(@duenen.length * @duenen[0].length) {|i| i} 
    reihenfolge.shuffle!
    reihenfolge.each_with_index do |nummer, index|
      x = nummer / @duenen.length
      y = nummer % @duenen.length
      if @frei[y][x] and rand(0) <= DuenenWkeit
        erschaffeDuene(x, y, wind: wind, maxHoehenFaktor: maxHoehenFaktor)
      end
    end
  end

  def erschaffeDuene(x, y, wind:, maxHoehenFaktor:)
    duene = Array.new(@bild.height) {Array.new(@bild.width, 0)}
    maxHoehe = berechneMaxHoehe(x, y, maxHoehenFaktor: maxHoehenFaktor)
    alter = rand(0) * (0.5 + rand(0)) / 1.5
    hoehe = maxHoehe * rand(0)
    hoehenZiel = hoehe
    50.times do
      hoehenZiel = updateHoehenZiel(x, y, hoehenZiel, maxHoehenFaktor: maxHoehenFaktor)
      hoehe = updateHoehe(x, y, hoehe, hoehenZiel, maxHoehenFaktor: maxHoehenFaktor)
    end
    punkte = [[x.round, y.round]]
    erstelleDuenenPunkt(x, y, hoehe, duene)
    punkte += erstelleArm(x, y, hoehe, hoehenZiel, 1, alter, duene, maxHoehenFaktor: maxHoehenFaktor, wind: wind)
    punkte += erstelleArm(x, y, hoehe, 2 * hoehe - hoehenZiel, -1, alter, duene, maxHoehenFaktor: maxHoehenFaktor, wind: wind)
    punkte.each do |punkt|
      besetzePunkte(punkt[0], punkt[1], @duenen[punkt[1]][punkt[0]], maxHoehenFaktor: maxHoehenFaktor)
    end
    glaette(duene, umkehren: false)
    @duenen.each_with_index do |zeile, y|
      zeile.collect!.with_index {|punkt, x| (punkt ** 2 + duene[y][x] ** 2) ** 0.5}
    end
  end

  def updateHoehenZiel(x, y, hoehenZiel, maxHoehenFaktor:)
    hoehenZiel * HoehenZielZerfall + (1 - HoehenZielZerfall) * (1 - 1 * rand(0)) * berechneMaxHoehe(x, y, maxHoehenFaktor: maxHoehenFaktor)
  end

  def updateHoehe(x, y, hoehe, hoehenZiel, maxHoehenFaktor:)
    if berechneMaxHoehe(x, y, maxHoehenFaktor: maxHoehenFaktor) == 0
      hoehenZerfall = 0
    else
      hoehenZerfall = [1 - (1 - HoehenZerfall) / berechneMaxHoehe(x, y, maxHoehenFaktor: maxHoehenFaktor), 0].max
    end
    hoehe * hoehenZerfall + hoehenZiel * (1 - hoehenZerfall)
  end
    
  def berechneMaxHoehe(x, y, maxHoehenFaktor:)
    return 0 if @entfernungen[y][x] <= RandBreite
    (1 - MaxGroesseRandPlatz * maxHoehenFaktor / (MaxGroesseRandPlatz * maxHoehenFaktor - RandBreite + @entfernungen[y][x])) * @wind.geschwindigkeit(x.round, y.round / 2.0) * maxHoehenFaktor
  end
  
  def erstelleArm(x, y, hoehe, hoehenZiel, orientierung, alter, duene, maxHoehenFaktor:, wind:)
    punkte = []
    until hoehe < MinHoehe or hoehe ** 0.5 * rand(0) < DuenenEndWkeit
      vektor = wind.senkrecht(x, y / 2.0, orientierung)
      vektor = vektor.zip(wind.vektor(x.round, y.round / 2.0)).map {|element| element[0]}
      x += vektor[0] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 8
      y += vektor[1] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 8
      return punkte if x.round < 0 or y.round < 0 or y.round >= @duenen.length or x.round >= @duenen[0].length
      return punkte + erstelleDuenenEnde(x, y, hoehe, hoehenZiel, orientierung, alter, duene, maxHoehenFaktor: maxHoehenFaktor, wind: wind) unless @frei[y][x]
      erstelleDuenenPunkt(x, y, hoehe, duene)
      punkte.push([x.round, y.round])
      hoehenZiel = updateHoehenZiel(x.round, y.round, hoehenZiel, maxHoehenFaktor: maxHoehenFaktor)
      hoehe = updateHoehe(x, y, hoehe, hoehenZiel, maxHoehenFaktor: maxHoehenFaktor)
    end
    punkte + erstelleDuenenEnde(x, y, hoehe, hoehenZiel, orientierung, alter, duene, maxHoehenFaktor: maxHoehenFaktor, wind: wind)
  end

  def erstelleDuenenEnde(x, y, hoehe, hoehenZiel, orientierung, alter, duene, maxHoehenFaktor:, wind:)
    punkte = []
    laenge = (4 * rand(0) + 1) / Math::tan(Math::PI / 12) * hoehe * 8
    laenge.to_i.times do |i|
      vektor = wind.senkrecht(x, y / 2.0, orientierung)
      vektor = vektor.zip(wind.vektor(x.round, y.round / 2.0)).map {|element| element[0] * (1 - i * alter / laenge.to_f) + i * alter / laenge.to_f * element[1]}
      x += vektor[0] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 8
      y += vektor[1] / (vektor[0] ** 2 + vektor[1] ** 2) ** 0.5 / 8
      return punkte if x.round < 0 or y.round < 0 or y.round >= @duenen.length or x.round >= @duenen[0].length
      erstelleDuenenPunkt(x, y, [berechneEndDuenenHoehe(hoehe, laenge, i), berechneMaxHoehe(x, y, maxHoehenFaktor: maxHoehenFaktor)].min, duene)
      punkte.push([x.round, y.round])
    end
    punkte
  end
  
  def berechneEndDuenenHoehe(hoehe, laenge, i)
    hoehe * (1 - i ** 2 / laenge.to_f ** 2)
  end
  
  def erstelleDuenenPunkt(x, y, hoehe, duene)
    if x.round < 0 or x.round >= duene[0].length or y.round < 0 or y.round >= duene.length
      p [[x, y], hoehe, duene.length, duene[0].length]
      raise
    end
    hoehe = [hoehe, 0].max
    hoehe = [hoehe, (hoehe * (@entfernungen[y.round][x.round] * Math::tan(Math::PI / 12)) / 2) ** 0.5].min
    duene[y.round][x.round] = [duene[y.round][x.round], hoehe].max
  end

  def besetzePunkte(x, y, hoehe, maxHoehenFaktor:)
    radius = (hoehe * HoehenDuenenAbstand + berechneMaxHoehe(x, y, maxHoehenFaktor: maxHoehenFaktor) * MaxHoehenDuenenAbstand) * (1 / Math::tan(Math::PI / 12) + 1 / Math::tan(Math::PI / 6))
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

  #def berechneHelligkeitRechtsRunter(x:, y:)
  #  scheinbareHoehe = Math::cos(Math::PI / 4 - Math::atan((@duenen[y][x] - @duenen[y + 1][x + 1]) / 2 **0.5))
  #  scheinbareBreite = Math::cos(Math::atan((@duenen[y][x] - @duenen[y + 1][x + 1]) / 2 **0.5))
  #  return scheinbareHoehe * scheinbareBreite * 256
  #end
  
  #def berechneHelligkeitAnKoordinate(x:, kartenY:)
  #  y = findeY(x: x, kartenY: kartenY)
  #  farben = []
  #  farben.push(berechneHelligkeitRechtsRunter(x: x - 1, y: y - 1)) if x > 0 and y > 0
  #  farben.push(berechneHelligkeitRechtsRunter(x: x - 1, y: y)) if x > 0 and y < @duenen.length - 1
  #  farben.push(berechneHelligkeitRechtsRunter(x: x, y: y - 1)) if x < @duenen[0].length - 1 and y > 0
  #  farben.push(berechneHelligkeitRechtsRunter(x: x, y: y)) if x < @duenen[0].length - 1 and y < @duenen.length - 1
  #  return (farben.reduce(:+) / farben.length).round
  #end
end
