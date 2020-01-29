#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'chunky_png'
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'NuetzlicheFunktionen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Typen'))
require "Wind"
require "WuestenErsteller"

seitenLaenge = 3
wind = Wind.new(seitenLaenge, seitenLaenge)

png = ChunkyPNG::Image.new(seitenLaenge, seitenLaenge, ChunkyPNG::Color::WHITE)
png2 = ChunkyPNG::Image.new(500, 500, ChunkyPNG::Color::WHITE)

wueste = WuestenErsteller.new(png, wind)
frei = Array.new(500) {Array.new(500, true)}
wueste.besetzePunkte(250, 250, 30, frei)
frei.each_with_index do |zeile, y|
  zeile.each_with_index do |bool, x|
    png2[x.round, y.round] = ChunkyPNG::Color::BLACK if bool
  end
end
png2.save('../ausgabe/wuestenBesetzungsTest.png', :interlace => true)
