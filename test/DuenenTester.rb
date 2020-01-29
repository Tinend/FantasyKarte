#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'chunky_png'
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'NuetzlicheFunktionen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Typen'))
require "Wind"
require "WuestenErsteller"

seitenLaenge = 300
wind = Wind.new(seitenLaenge, seitenLaenge)

png = ChunkyPNG::Image.new(seitenLaenge, seitenLaenge, ChunkyPNG::Color::WHITE)
png2 = ChunkyPNG::Image.new(seitenLaenge, seitenLaenge * 2, ChunkyPNG::Color::WHITE)

wueste = WuestenErsteller.new(png, wind)
wueste.duenen.each_with_index do |zeile, y|
  zeile.each_with_index do |hoehe, x|
    grau = [(hoehe * 30).round, 255].min
    png2[x.round, y.round] = ChunkyPNG::Color.rgb(grau, grau, grau)
  end
  puts "#{y + 1} von #{seitenLaenge * 2}"
end
png2.save('../ausgabe/duenen.png', :interlace => true)
