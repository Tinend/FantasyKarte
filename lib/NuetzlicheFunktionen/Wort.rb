# coding: utf-8
class Wort
  def initialize(position)
    @x, @y = @position
    @wort = ""
  end

  attr_reader :x, :y
  
  def buchstabeHinzufuegen(buchstabe)
    @wort += buchstabe.chr
  end

  def bildErstellen()
    #ChunkyPNG::Chunk::Text.encode("iTXt", @wort)
    #ChunkyPNG::Chunk::Text.read("iTXt", @wort)
    #ChunkyPNG::Chunk::InternationalText.read("iTXt", @wort)
    ChunkyPNG::Chunk::CompressedText.read("iTXt", @wort)
  end
end
