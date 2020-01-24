require 'chunky_png'

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'NuetzlicheFunktionen'))
require "berechneEntfernung"

png = ChunkyPNG::Image.new(10, 10, ChunkyPNG::Color::TRANSPARENT)
10.times do |x|
  10.times do |y|
    if (x ** 2 + y ** 2) ** 0.5 < 7.7
      png[y, x] = ChunkyPNG::Color::BLACK
    end
  end
end
entfernungen = berechneEntfernung(png)
entfernungen.map! {|zeile| zeile.map {|e| (e * 100 + 1000).round}}
entfernungen.each do |zeile|
  p zeile
end
