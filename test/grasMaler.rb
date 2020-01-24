#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'chunky_png'
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require "Gras"

hoehe = 303
breite = 612
# Creating an image from scratch, save as an interlaced PNG
png = ChunkyPNG::Image.new(breite, hoehe, ChunkyPNG::Color::WHITE)
#png = ChunkyPNG::Image.new(breite, hoehe, ChunkyPNG::Color.from_hex('#888888'))
Schwarz = ChunkyPNG::Color.from_hex('#000000')
Weiss = ChunkyPNG::Color.from_hex('#FFFFFF')
a = png.get_pixel(20,20)
png[20, 20] = ChunkyPNG::Color::BLACK
a = png.get_pixel(20,20)

10.times do |x|
  10.times do |y|
    gras = Gras.new(30, rand(64) + rand(64) + rand(64) + rand(64), rand(17) * rand(17))
    grasBild = gras.malen()
    png.compose!(grasBild, offset_x = x*61, offset_y = y * 30)
  end
end
png.save('../ausgabe/gras.png', :interlace => true)
