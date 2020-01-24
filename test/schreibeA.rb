#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'chunky_png'
#require 'chunky_text'
#require 'OilyPNG'
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Typen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Terrain'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'NuetzlicheFunktionen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Grundlagen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require "Wort"

hoehe = 10
breite = 10
# Creating an image from scratch, save as an interlaced PNG
png = ChunkyPNG::Image.new(breite, hoehe, ChunkyPNG::Color::WHITE)
#p ARGV
wort = Wort.new([0,0])
wort.buchstabeHinzufuegen(97)
schrift = wort.bildErstellen()
#comb = ChunkyPNG::Chunk::ImageData.combine_chunks([png, schrift])
p [schrift, schrift.content]
ChunkyPNG::Image.new()
png.save('../ausgabe/wort.png', :interlace => true)
