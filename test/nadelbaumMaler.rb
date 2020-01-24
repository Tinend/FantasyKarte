#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'chunky_png'
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Typen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Terrain'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'NuetzlicheFunktionen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Grundlagen'))
require "Nadelbaum"

hoehe = 300
breite = 300
# Creating an image from scratch, save as an interlaced PNG
png = ChunkyPNG::Image.new(breite, hoehe, ChunkyPNG::Color::WHITE)
10.times do |x|
  10.times do |y|
    baum = Nadelbaum.new(30)
    baumBild = baum.malen()
    png.compose!(baumBild, offset_x = x*30, offset_y = y * 30)
  end
end
png.save('../ausgabe/nadelbaum.png', :interlace => true)
