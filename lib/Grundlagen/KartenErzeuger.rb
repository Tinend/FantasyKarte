require "BaumTyp"
require "BergTyp"
require "WasserTyp"
require "GrasTyp"
require "WuestenTyp"
require "TerrainVerwalter"
require "Wind"

class KartenErzeuger

  PrimaerWindgeschwindigkeit = 1
  SekundaerWindgeschwindigkeit = 0.3
  
  def initialize(datenBild)
    @datenBild = datenBild
    @hintergrund = ChunkyPNG::Image.new(@datenBild.width, @datenBild.height, ChunkyPNG::Color::WHITE)
    @mittelgrund = ChunkyPNG::Image.new(@datenBild.width, @datenBild.height, ChunkyPNG::Color::TRANSPARENT)
    @vordergrund = ChunkyPNG::Image.new(@datenBild.width, @datenBild.height, ChunkyPNG::Color::TRANSPARENT)
    @schriftgrund = ChunkyPNG::Image.new(@datenBild.width, @datenBild.height, ChunkyPNG::Color::TRANSPARENT)
    @wind = Wind.new(@datenBild.width, @datenBild.height, geschwindigkeit: PrimaerWindgeschwindigkeit)
    @terrainVerwalter = [
      TerrainVerwalter.new(BaumTyp.new(@datenBild.width, @datenBild.height), @hintergrund, @mittelgrund, @vordergrund, @datenBild),
      TerrainVerwalter.new(BergTyp.new(@datenBild.width, @datenBild.height), @hintergrund, @mittelgrund, @vordergrund, @datenBild),
      TerrainVerwalter.new(WasserTyp.new(@datenBild.width, @datenBild.height), @hintergrund, @mittelgrund, @vordergrund, @datenBild),
      TerrainVerwalter.new(GrasTyp.new(@datenBild.width, @datenBild.height), @hintergrund, @mittelgrund, @vordergrund, @datenBild),
      TerrainVerwalter.new(WuestenTyp.new(@datenBild.width, @datenBild.height, wind: @wind), @hintergrund, @mittelgrund, @vordergrund, @datenBild)
    ]
  end

  attr_reader :karte
  
  def erstelleKarte()
    @datenBild.height.times do |y|
      @datenBild.width.times do |x|
        if ChunkyPNG::Color.r(@datenBild.get_pixel(x,y)) == 255
          blau = ChunkyPNG::Color.b(@datenBild.get_pixel(x,y))
          @hintergrund[x, y] = ChunkyPNG::Color.rgb(blau, blau, blau)
        elsif ChunkyPNG::Color.r(@datenBild.get_pixel(x,y)) == 254 or ChunkyPNG::Color.r(@datenBild.get_pixel(x,y)) == 20 or ChunkyPNG::Color.r(@datenBild.get_pixel(x,y)) == 60
          blau = ChunkyPNG::Color.b(@datenBild.get_pixel(x,y))
          @schriftgrund[x, y] = ChunkyPNG::Color.rgb(blau, blau, blau)
        end
      end
    end
    @datenBild.height.times do |y|
      @datenBild.width.times do |x|
        datenFarbe = @datenBild.get_pixel(x,y)
        verwalter = []
        @terrainVerwalter.each do |tv|
          if tv.mussFaerben?(datenFarbe)
            verwalter.push(tv)
          end
        end
        verwalter.each do |tv|
          tv.verwalte(x, y, datenFarbe)
        end
      end
      puts "#{y + 1}/#{@datenBild.height}"
    end

    @terrainVerwalter.each do |tv|
      tv.erstelleHintergrund()
    end
    @karte = @hintergrund.compose(@mittelgrund).compose(@vordergrund).compose(@schriftgrund)
    #@karte = @mittelgrund.compose(@vordergrund).compose(@schriftgrund)
  end
end
