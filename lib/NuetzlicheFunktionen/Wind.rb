require "Windrichtung"
require "ZweiDWienerProzess"
require "definiereNeigungen"
class Wind
  WindWienerAbstand = 3
  WindWinkelDivisor = 500
  WindZahl = 5
  def initialize(breite, hoehe)
    @wind = Array.new(breite) {Array.new(hoehe) {Windrichtung.new()}}
    zweiDWienerProzess = ZweiDWienerProzess.new()
    WindZahl.times do |i|
      zufallsWinkel = rand(0) * Math::PI
      #wiener = zweiDWienerProzess.erstelleZweiDWienerProzess(breite, hoehe, WindWienerAbstand)
      wiener = definiereNeigungen(breite, hoehe, 0.6)
      @wind.zip(wiener).each do |ww|
        ww[0].zip(ww[1]).each do |windRichtung|
          #windRichtung[0].windRichtungErhalten(windRichtung[1] / WindWinkelDivisor)
          windRichtung[0].windVektorErhalten(windRichtung[1] * 4.5 + zufallsWinkel)
        end
      end
      puts "#{i + 1} / #{WindZahl}"
    end
  end

  attr_reader :wind

  def geschwindigkeit(x, y)
    array = [wind[y][x].geschwindigkeit()] * 4
    array += [wind[y][x - 1].geschwindigkeit()] if x > 0
    array += [wind[y][x + 1].geschwindigkeit()] if wind.length > 0 and x < wind[0].length - 1
    array += [wind[y - 1][x].geschwindigkeit()] if y > 0
    array += [wind[y + 1][x].geschwindigkeit()] if y < wind.length - 1
    array.reduce(:+) / array.length
  end

  def senkrecht(x, y, orientierung)
    array = [wind[y][x].senkrecht(orientierung)] * 4
    array += [wind[y][x - 1].senkrecht(orientierung)] if x > 0
    array += [wind[y][x + 1].senkrecht(orientierung)] if wind.length > 0 and x < wind[0].length - 1
    array += [wind[y - 1][x].senkrecht(orientierung)] if y > 0
    array += [wind[y + 1][x].senkrecht(orientierung)] if y < wind.length - 1
    array.reduce {|e, f| e.zip(f).map { |a, b| a + b / array.length}}
  end
  
  def vektor(x, y)
    array = [wind[y][x].vektor] * 4
    array += [wind[y][x - 1].vektor] if x > 0
    array += [wind[y][x + 1].vektor] if wind.length > 0 and x < wind[0].length - 1
    array += [wind[y - 1][x].vektor] if y > 0
    array += [wind[y + 1][x].vektor] if y < wind.length - 1
    array.reduce {|e, f| e.zip(f).map { |a, b| a + b / array.length}}
  end
  
  def richtung(x, y)
    array = [wind[y][x].richtung] * 4
    array += [wind[y][x - 1].richtung] if x > 0
    array += [wind[y][x + 1].richtung] if wind.length > 0 and x < wind[0].length - 1
    array += [wind[y - 1][x].richtung] if y > 0
    array += [wind[y + 1][x].richtung] if y < wind.length - 1
    array.reduce {|e, f| e.zip(f).map { |a, b| a + b / array.length}}
  end
end
