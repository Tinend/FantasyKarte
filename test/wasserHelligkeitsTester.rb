#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'chunky_png'
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Typen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Terrain'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'NuetzlicheFunktionen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Grundlagen'))
require "Wind"
require "WasserTyp"

seitenLaenge = 100
schrittWeite = 20.0
wind = Wind.new(12, 12, geschwindigkeit: 1)

png = ChunkyPNG::Image.new(seitenLaenge, seitenLaenge, ChunkyPNG::Color::WHITE)

wasser = WasserTyp.new(12, 12, wind: wind)
seitenLaenge.times do |y|
  seitenLaenge.times do |x|
    grau = [[(wasser.berechneSichtbarkeit([(x - seitenLaenge / 2) / schrittWeite, (y - seitenLaenge / 2) / schrittWeite,1]) * wasser.berechneFarbe([(x - seitenLaenge / 2) / schrittWeite, (y - seitenLaenge / 2) / schrittWeite, 1])).round, 0].max, 255].min
    png[x, y] = ChunkyPNG::Color.rgb(grau, grau, grau)
  end
  puts "#{y + 1} von #{seitenLaenge}"
end
png.save('../ausgabe/test3Wasser.png', :interlace => true)
