require "Windrichtung"
require "ZweiDWienerProzess"
require "definiereNeigungen"
class Wind
  WindWienerAbstand = 3
  WindWinkelDivisor = 500
  WindZahl = 5
  #FallKonstante = 0.6
  FallKonstante = 0.8
  def initialize(breite, hoehe, geschwindigkeit: 1)
    @wind = Array.new(hoehe * 2) {Array.new(breite) {Windrichtung.new(grundGeschwindigkeit: geschwindigkeit)}}
    zweiDWienerProzess = ZweiDWienerProzess.new()
    WindZahl.times do |i|
      zufallsWinkel = rand(0) * Math::PI
      #wiener = zweiDWienerProzess.erstelleZweiDWienerProzess(breite, hoehe, WindWienerAbstand)
      wiener = definiereNeigungen(breite, hoehe * 2 - 1, FallKonstante)
      @wind.zip(wiener).each do |ww|
        ww[0].zip(ww[1]).each do |windRichtung|
          #windRichtung[0].windRichtungErhalten(windRichtung[1] / WindWinkelDivisor)
          windRichtung[0].windVektorErhalten(windRichtung[1] * 4.5 + zufallsWinkel)
        end
      end
      puts "#{i + 1} / #{WindZahl}"
    end
    max = 0
    @wind.each do |zeile|
      zeile.each do |w|
        max = [w.geschwindigkeit, max].max
      end
    end
    puts max
  end

  attr_reader :wind

  def geschwindigkeit(x, y)
    v = vektor(x, y)
    (v[0] ** 2 + v[1] ** 2) ** 0.5
  end

  def senkrecht(x, y, orientierung)
    y = (y * 2).to_i
    array = [wind[y][x].senkrecht(orientierung)] * 4
    array += [wind[y][x - 1].senkrecht(orientierung)] if x > 0
    array += [wind[y][x + 1].senkrecht(orientierung)] if wind.length > 0 and x < wind[0].length - 1
    array += [wind[y - 1][x].senkrecht(orientierung)] if y > 0
    array += [wind[y + 1][x].senkrecht(orientierung)] if y < wind.length - 1
    array.reduce([0, 0]) {|e, f| e.zip(f).map { |a, b| a + b / array.length}}
  end
  
  def vektor(x, y)
    y = (y * 2).to_i
    array = [wind[y][x].vektor] * 4
    array += [wind[y][x - 1].vektor] if x > 0
    array += [wind[y][x + 1].vektor] if wind.length > 0 and x < wind[0].length - 1
    array += [wind[y - 1][x].vektor] if y > 0
    array += [wind[y + 1][x].vektor] if y < wind.length - 1
    array.reduce([0, 0]) {|e, f| e.zip(f).map { |a, b| a + b / array.length}}
  end
  
  def richtung(x, y)
    y = (y * 2).to_i
    array = [wind[y][x].vektor] * 4
    array += [wind[y][x - 1].vektor] if x > 0
    array += [wind[y][x + 1].vektor] if wind.length > 0 and x < wind[0].length - 1
    array += [wind[y - 1][x].vektor] if y > 0
    array += [wind[y + 1][x].vektor] if y < wind.length - 1
    gs = geschwindigkeit(x, y / 2.0)
    array.reduce([0, 0]) {|e, f| e.zip(f).map { |a, b| a + b / array.length / gs}}
  end
end
