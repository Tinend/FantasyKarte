#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'chunky_png'
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Typen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Terrain'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'NuetzlicheFunktionen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Grundlagen'))
require "Kaktus"

hoehe = 330
breite = 330
# Creating an image from scratch, save as an interlaced PNG
png = ChunkyPNG::Image.new(breite, hoehe, ChunkyPNG::Color::WHITE)

1.times do |x|
  1.times do |y|
    kaktus = Kaktus.new(130)
    kaktusBild = kaktus.malen()
    png.compose!(kaktusBild, offset_x = x*130, offset_y = y * 130)
  end
end
png.save('../ausgabe/kaktus.png', :interlace => true)
