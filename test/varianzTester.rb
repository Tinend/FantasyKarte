$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'NuetzlicheFunktionen'))
require "schaetzeErwartungswert"
require "schaetzeVarianz"

p ["Erwartungswert", [0, 1, 2, 4]]
puts schaetzeErwartungswert([0, 1, 2, 4])
p ["Varianz", [0, 1, 2, 4]]
puts schaetzeVarianz([0, 1, 2, 4])
p ["Erwartungswert", [10, 9, 13, 15, 16], "soll:", 12.6]
puts schaetzeErwartungswert([10, 9, 13, 15, 16])
p ["Varianz", [10, 9, 13, 15, 16], "soll:", 7.44]
puts schaetzeVarianz([10, 9, 13, 15, 16])
