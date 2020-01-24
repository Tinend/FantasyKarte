#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'chunky_png'
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Typen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Terrain'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'NuetzlicheFunktionen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Grundlagen'))
require "Wasser"

hoehe = 300
breite = 300
# Creating an image from scratch, save as an interlaced PNG
png = ChunkyPNG::Image.new(breite, hoehe, ChunkyPNG::Color::WHITE)
x = 0
10.times do |y|
  wasser = Wasser.new(10, 7)
  wasserBild = wasser.malen()
  png.compose!(wasserBild, offset_x = x*30, offset_y = y * 30)
end
png.save('../ausgabe/wasser.png', :interlace => true)
