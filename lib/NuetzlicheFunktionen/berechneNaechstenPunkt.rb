# coding: utf-8
require "RandPixel"

def berechneNaechstenPunkt(bild)# berechnet für jeden Pixel, welcher transparente Pixel ihm am nächsten ist
  hatTransparenz = false
  bild.length.times do |y|
    bild[0].length.times do |x|
      if bild[y][x]
        hatTransparenz = true
        break
      end
    end
    break if hatTransparenz
  end
  return Array.new(bild.length) {|y| Array.new(bild[0].length) {|x| [x, y]}} unless hatTransparenz
  richtungen = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]]
  distanz = 0
  randPixel = []
  ziele = Array.new(bild.length) {|y| Array.new(bild[0].length) {|x| [x, y]}}
  bild.length.times do |y|
    bild[0].length.times do |x|
      next if bild[y][x]
      richtungen.each do |richtung|
        if x + richtung[0] >= 0 and x + richtung[0] <= bild[0].length - 1 and y + richtung[1] >= 0 and y + richtung[1] <= bild.length - 1 and bild[y + richtung[1]][x + richtung[0]]
          if (x == ziele[y][x][0] and y == ziele[y][x][1]) or ((x - ziele[y][x][0]) ** 2 + (y - ziele[y][x][1]) ** 2) > ((x - ziele[y + richtung[1]][x + richtung[0]][0]) ** 2 + (y - ziele[y + richtung[1]][x + richtung[0]][1]) ** 2)
            ziele[y][x] = [x + richtung[0], y + richtung[0]]
            randPixel.push(RandPixel.new(x, y, richtung[0] ** 2 + richtung[1] ** 2))
          end
        end
      end
    end
  end
  until randPixel.length == 0
    if distanz != randPixel[0].distanz
      randPixel.sort!
      distanz = randPixel[0].distanz
    end
    pixel = randPixel.shift()
    next if pixel.distanz > (ziele[pixel.y][pixel.x][0] - pixel.x) ** 2 + (ziele[pixel.y][pixel.x][1] - pixel.y) ** 2 and ziele[pixel.y][pixel.x] != [pixel.x, pixel.y]
    neuPixel = richtungen.map {|r| RandPixel.new(pixel.x + r[0], pixel.y + r[1], (ziele[pixel.y][pixel.x][0] - pixel.x - r[0]) ** 2 + (ziele[pixel.y][pixel.x][1] - pixel.y - r[1]) ** 2)}
    neuPixel.select! {|np| np.x >= 0 and np.y >= 0 and np.x < bild[0].length and np.y < bild.length}
    neuPixel.select! {|np| (ziele[np.y][np.x] == [np.x, np.y] or ((ziele[np.y][np.x][0] - np.x) ** 2 + (ziele[np.y][np.x][1] - np.y) ** 2 > np.distanz and (ziele[np.y][np.x][0] - np.x) ** 2 + (ziele[np.y][np.x][1] - np.y) ** 2 > (ziele[pixel.y][pixel.x][0] - pixel.x) ** 2 + (ziele[pixel.y][pixel.x][1] - pixel.y))) and not bild[np.y][np.x]}
    randPixel += neuPixel
    neuPixel.each {|np| ziele[np.y][np.x] = ziele[pixel.y][pixel.x]}
  end
  ziele
end
    
