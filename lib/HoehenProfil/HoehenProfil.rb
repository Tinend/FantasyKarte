require "HoehenProfil/HoehenPunkt"

class HoehenProfil
  def initialize(breite, hoehe)
    @hoehenProfil = Array.new(2 * hoehe) {Array.new(breite) {HoehenPunkt.new(0)}}
  end

  attr_reader :hoehenProfil

  def hoehenPunktEinfuegen(x:, y:, hoehenPunkt:)
    @hoehenProfil[y][x] = hoehenPunkt
  end

  def findeY(x:, y:)
    startY = y
    y = @hoehenProfil.length - 1
    until y == 0 or (y - startY) * Math::tan(Math::PI / 6) < @hoehenProfil[y][x].hoehe * 2
      y -= 1
    end
    y += 1 if y < @hoehenProfil.length - 1
    y
  end

  def berechneHelligkeitAnKoordinate(x:, y:)
    y = findeY(x: x, y: y)
    farben = []
    farben.push(berechneHelligkeitRechtsRunter(x: x - 1, y: y - 1, hauptX: x, hauptY: y)) if x > 0 and y > 0
    farben.push(berechneHelligkeitRechtsRunter(x: x - 1, y: y, hauptX: x, hauptY: y)) if x > 0 and y < @hoehenProfil.length - 1
    farben.push(berechneHelligkeitRechtsRunter(x: x, y: y - 1, hauptX: x, hauptY: y)) if x < @hoehenProfil[0].length - 1 and y > 0
    farben.push(berechneHelligkeitRechtsRunter(x: x, y: y, hauptX: x, hauptY: y)) if x < @hoehenProfil[0].length - 1 and y < @hoehenProfil.length - 1
    return (farben.reduce(:+) / farben.length).round
  end
  
  def berechneHelligkeitRechtsRunter(x:, y:, hauptX:, hauptY:)
    scheinbareHoehe = Math::cos(Math::PI / 4 - Math::atan((@hoehenProfil[y][x].hoehe - @hoehenProfil[y + 1][x + 1].hoehe) / 2 ** 0.5))
    scheinbareBreite = Math::cos(Math::atan((@hoehenProfil[y][x].hoehe - @hoehenProfil[y + 1][x + 1].hoehe) / 2 ** 0.5))
    return @hoehenProfil[y][x].farbe(scheinbareHoehe: scheinbareHoehe, scheinbareBreite: scheinbareBreite)
  end
end
