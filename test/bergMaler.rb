#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'chunky_png'
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Typen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Terrain'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'NuetzlicheFunktionen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Grundlagen'))
require "Berg"

hoehe = 1000
breite = 1000
# Creating an image from scratch, save as an interlaced PNG
png = ChunkyPNG::Image.new(breite, hoehe, ChunkyPNG::Color::WHITE)
10.times do |x|
  10.times do |y|
    berg = Berg.new(rand(90) + 10, 20)
    bergBild = berg.malen()
    png.compose!(bergBild, offset_x = x * 100, offset_y = (y + 1) * 100 - bergBild.height)
  end
end
png.save('../ausgabe/berg.png', :interlace => true)
