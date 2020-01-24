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
baumHoehe = 30
baumWkeit = 30
# Creating an image from scratch, save as an interlaced PNG
png = ChunkyPNG::Image.new(breite, hoehe, ChunkyPNG::Color::WHITE)
#png = ChunkyPNG::Image.new(breite, hoehe, ChunkyPNG::Color.from_hex('#888888'))
Schwarz = ChunkyPNG::Color.from_hex('#000000')
Weiss = ChunkyPNG::Color.from_hex('#FFFFFF')
(hoehe - baumHoehe).times do |y|
  (breite - baumHoehe).times do |x|
    if rand(baumWkeit) == 0
      baum = Laubbaum.new(baumHoehe)      
      baumBild = baum.malen()
      png.compose!(baumBild, offset_x = x, offset_y = y)     
    end
  end
end
png.save('../ausgabe/laubwald.png', :interlace => true)
