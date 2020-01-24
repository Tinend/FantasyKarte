#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'chunky_png'
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Typen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Terrain'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'NuetzlicheFunktionen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Grundlagen'))
require "Bewegung"
require "ZufallsBewegung"

hoehe = 200
breite = 200
# Creating an image from scratch, save as an interlaced PNG
#png = ChunkyPNG::Image.new(breite, hoehe, ChunkyPNG::Color::TRANSPARENT)
png = ChunkyPNG::Image.new(breite, hoehe, ChunkyPNG::Color::WHITE)
Schwarz = ChunkyPNG::Color.from_hex('#000000')
Weiss = ChunkyPNG::Color.from_hex('#FFFFFF')
#png.circle(10,10,5,Schwarz,Schwarz)
#png.circle(20,10,5,Schwarz,Schwarz)
#png.circle(30,10,5,Schwarz,Schwarz)
#png.line(100,100,111,182,Weiss,Schwarz)
zb = ZufallsBewegung.new(breite / 2, hoehe / 2, 1000)
until zb.fertig?()
  png.circle(zb.x.to_i, zb.y.to_i, 4, Schwarz, Schwarz)
  zb.bewegeDich()
end
png.save('../ausgabe/linie.png', :interlace => true)
