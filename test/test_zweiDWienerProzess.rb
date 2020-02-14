$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'NuetzlicheFunktionen'))
require "ZweiDWienerProzess"
require 'minitest/autorun'

class ZweiDWienerProzessTest < Minitest::Test
  def setup
    @zweiDWienerProzess = ZweiDWienerProzess.new()
  end

  def test_richtiges_resultat
    resultat = @zweiDWienerProzess.erstelleZweiDWienerProzess(10, 10, 1).map {|zeile| zeile.map {|e| (e * 100 + 2000).round}}
    assert_equal 10, resultat.length
    resultat.each do |zeile|
      p zeile
      assert_equal 10, zeile.length
      zeile.each do |e|
        assert_operator e, :>=, 0
        assert_operator e, :<, 5000
      end
    end
  end
end
