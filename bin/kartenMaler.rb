#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'chunky_png'
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Typen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Terrain'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'NuetzlicheFunktionen'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'Grundlagen'))
require "Laubbaum"
require "Ast"
require "BaumTyp"
require "BildOeffnerKartenSpeicherer"
require "TerrainVerwalter"
require "KartenErzeuger"

if ARGV.length >= 2
  eingabeFile = "../eingabe/" + ARGV[0]
  ausgabeFile = "../ausgabe/" + ARGV[1]
elsif ARGV.length >= 1
  eingabeFile = "../eingabe/" + ARGV[0]
  ausgabeFile = "../ausgabe/" + ARGV[0]
else
  eingabeFile = "../eingabe/Karte.png"
  ausgabeFile = "../ausgabe/Karte.png"
end
bildOeffnerKartenSpeicherer = BildOeffnerKartenSpeicherer.new(eingabeFile, ausgabeFile)
kartenErzeuger = KartenErzeuger.new(bildOeffnerKartenSpeicherer.bild)
kartenErzeuger.erstelleKarte()
bildOeffnerKartenSpeicherer.speichere(kartenErzeuger.karte)
