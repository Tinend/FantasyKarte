# coding: utf-8
require "RandPixel"

def berechneEntfernung(bild)# berechnet für jeden Pixel, wie weit er von Transparenten Pixeln entfernt ist
  richtungen = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]]
  distanz = 0
  randPixel = []
  entfernungen = Array.new(bild.height) {Array.new(bild.width, 0)}
  bild.height.times do |y|
    bild.width.times do |x|
      next if bild[x,y] == ChunkyPNG::Color::TRANSPARENT
      if x == 0 or y == 0 or x == bild.width - 1 or y == bild.height - 1
        entfernungen[y][x] = 1
        randPixel.push(RandPixel.new(x, y, 1))
      elsif (x > 0 and bild[x - 1, y] == ChunkyPNG::Color::TRANSPARENT) or (y > 0 and bild[x, y - 1] == ChunkyPNG::Color::TRANSPARENT) or (x < bild.width - 1 and bild[x + 1, y] == ChunkyPNG::Color::TRANSPARENT) or (y < bild.height - 1 and bild[x, y + 1] == ChunkyPNG::Color::TRANSPARENT)
        entfernungen[y][x] = 1
        randPixel.push(RandPixel.new(x, y, 1))
      elsif (x > 0 and y > 0 and bild[x - 1, y - 1] == ChunkyPNG::Color::TRANSPARENT) or (x < bild.width - 1 and y > 0 and bild[x + 1, y - 1] == ChunkyPNG::Color::TRANSPARENT) or (x < bild.width - 1 and y < bild.height - 1 and bild[x + 1, y + 1] == ChunkyPNG::Color::TRANSPARENT) or (x > 0 and y < bild.height - 1 and bild[x - 1, y + 1] == ChunkyPNG::Color::TRANSPARENT)
        entfernungen[y][x] = 2 ** 0.5
        randPixel.push(RandPixel.new(x, y, 2 ** 0.5))
      end
    end
  end
  until randPixel.length == 0
    if distanz != randPixel[0].distanz
      randPixel.sort!
      distanz = randPixel[0].distanz
    end
    pixel = randPixel.shift()
    next if pixel.distanz > entfernungen[pixel.y][pixel.x] and entfernungen[pixel.y][pixel.x] != 0
    neuPixel = richtungen.map {|r| RandPixel.new(pixel.x + r[0], pixel.y + r[1], pixel.distanz + (r[0] ** 2 + r[1] ** 2) ** 0.5)}
    neuPixel.select! {|np| np.x >= 0 and np.y >= 0 and np.x < bild.width and np.y < bild.height}
    neuPixel.select! {|np| (entfernungen[np.y][np.x] == 0 or entfernungen[np.y][np.x] > np.distanz) and bild[np.x, np.y] != ChunkyPNG::Color::TRANSPARENT}
    randPixel += neuPixel
    neuPixel.each {|np| entfernungen[np.y][np.x] = np.distanz}
  end
  entfernungen
end
