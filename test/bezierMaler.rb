#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'chunky_png'
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Typen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Terrain'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'NuetzlicheFunktionen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Grundlagen'))
require "Bewegung"
require "ZufallsBewegung"

def plusx(array)
  Array.new(array.length()) {|i| ChunkyPNG::Point.new(array[i].x + 1, array[i].y)}
end
def plusy(array)
  Array.new(array.length()) {|i| ChunkyPNG::Point.new(array[i].x, array[i].y + 1)}
end

hoehe = 200
breite = 200
# Creating an image from scratch, save as an interlaced PNG
png = ChunkyPNG::Image.new(breite, hoehe, ChunkyPNG::Color::WHITE)
Schwarz = ChunkyPNG::Color.from_hex('#000000')
Weiss = ChunkyPNG::Color.from_hex('#FFFFFF')
#punkte = Array.new(5) {ChunkyPNG::Point.new(rand(breite), rand(hoehe))}
punkte = [
  ChunkyPNG::Point.new(100, 100),
  ChunkyPNG::Point.new(70, 100),
  ChunkyPNG::Point.new(70, 30),
  ChunkyPNG::Point.new(130, 30),
  ChunkyPNG::Point.new(130, 100),
  ChunkyPNG::Point.new(100, 100),
]
punkte2 = [
  ChunkyPNG::Point.new(100, 100),
  ChunkyPNG::Point.new(70.3, 100),
  ChunkyPNG::Point.new(70.3, 30),
  ChunkyPNG::Point.new(130.8, 30),
  ChunkyPNG::Point.new(130.8, 100),
  ChunkyPNG::Point.new(100, 100),
]
punktex = plusx(punkte)
punktey = plusy(punktex)
png.bezier_curve(punkte, stroke_color = ChunkyPNG::Color::BLACK)
png.bezier_curve(punkte2, stroke_color = ChunkyPNG::Color.rgb(0, 255, 0))
#png.bezier_curve(punktex, stroke_color = ChunkyPNG::Color::BLACK)
#png.bezier_curve(punktey, stroke_color = ChunkyPNG::Color::BLACK)
png.line(100,100,100,130,Schwarz,Schwarz)
png.line(101,100,101,130,Schwarz,Schwarz)
png.line(102,100,102,130,Schwarz,Schwarz)
png.save('../ausgabe/brezierLinie.png', :interlace => true)
