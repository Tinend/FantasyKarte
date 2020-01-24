#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'chunky_png'
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Typen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Terrain'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'NuetzlicheFunktionen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Grundlagen'))
require "Laubbaum"

hoehe = 300
breite = 300
# Creating an image from scratch, save as an interlaced PNG
png = ChunkyPNG::Image.new(breite, hoehe, ChunkyPNG::Color::WHITE)
#png = ChunkyPNG::Image.new(breite, hoehe, ChunkyPNG::Color.from_hex('#888888'))
Schwarz = ChunkyPNG::Color.from_hex('#000000')
Weiss = ChunkyPNG::Color.from_hex('#FFFFFF')
a = png.get_pixel(20,20)
p [a, ChunkyPNG::Color.r(a)]
png[20, 20] = ChunkyPNG::Color::BLACK
a = png.get_pixel(20,20)
p [a, ChunkyPNG::Color.r(a)]

10.times do |x|
  10.times do |y|
    baum = Laubbaum.new(30)
    baumBild = baum.malen()
    png.compose!(baumBild, offset_x = x*30, offset_y = y * 30)
  end
end
png.save('../ausgabe/laubbaum.png', :interlace => true)
