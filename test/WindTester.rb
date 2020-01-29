#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'chunky_png'
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'NuetzlicheFunktionen'))
require "Wind"

seitenLaenge = 900
wind = Wind.new(seitenLaenge, seitenLaenge)

png = ChunkyPNG::Image.new(seitenLaenge, seitenLaenge * 2, ChunkyPNG::Color::WHITE)
png2 = ChunkyPNG::Image.new(seitenLaenge, seitenLaenge * 2, ChunkyPNG::Color::WHITE)
wind.wind.each_with_index do |zeile, y|
  zeile.each_with_index do |windrichtung, x|
    r = [[(windrichtung.vektor[0] * 32).round + 128, 0].max, 255].min
    g = [[(windrichtung.vektor[1] * 32).round + 128, 0].max, 255].min
    png[x.round, y.round] = ChunkyPNG::Color.rgb(r, g, 0)
    if rand(5) == 0
      grau = rand(256)
      farbe = ChunkyPNG::Color.rgb(grau, grau, grau)
      9.times do |i|
        posx = x + i * windrichtung.vektor[0] * 0.3
        posy = y + i * windrichtung.vektor[1] * 0.3
        if posx >= 0 and posy >= 0 and posx.round < seitenLaenge and posy.round < seitenLaenge * 2
          png2[posx.round, posy.round] = farbe
        end
      end
    end
  end
  puts "#{y + 1} von #{seitenLaenge * 2}"
end
png.save('../ausgabe/wind.png', :interlace => true)
png2.save('../ausgabe/wind2.png', :interlace => true)
