$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'NuetzlicheFunktionen'))
require "ZweiDWienerProzess"

zweiDWienerProzess = ZweiDWienerProzess.new()
resultat = zweiDWienerProzess.erstelleZweiDWienerProzess(10, 10, 1).map {|zeile| zeile.map {|e| (e * 100 + 2000).round}}
resultat.each do |r|
  p r
end
