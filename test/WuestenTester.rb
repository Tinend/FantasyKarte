#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'chunky_png'
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'NuetzlicheFunktionen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Typen'))
require "Wind"
require "WuestenErsteller"

seitenLaenge = 300
wind = Wind.new(seitenLaenge, seitenLaenge, geschwindigkeit: 1)

png = ChunkyPNG::Image.new(seitenLaenge, seitenLaenge, ChunkyPNG::Color::WHITE)

wueste = WuestenErsteller.new(png, wind: wind)
seitenLaenge.times do |y|
  seitenLaenge.times do |x|
    grau = wueste.berechneHelligkeitAnKoordinate(x: x, kartenY: y)
    png[x, y] = ChunkyPNG::Color.rgb(grau, grau, grau)
  end
  puts "#{y + 1} von #{seitenLaenge}"
end
png.save('../ausgabe/wueste.png', :interlace => true)
