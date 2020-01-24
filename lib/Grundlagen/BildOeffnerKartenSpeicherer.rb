class BildOeffnerKartenSpeicherer
  def initialize(eingabeFile, ausgabeFile)
    if eingabeFile[-4..-1] != ".png"
      @eingabeFile = eingabeFile + ".png"
    else
      @eingabeFile = eingabeFile
    end
    if ausgabeFile[-4..-1] != ".png"
      @ausgabeFile = ausgabeFile + ".png"
    else
      @ausgabeFile = ausgabeFile
    end
    @bild = ChunkyPNG::Canvas.from_file(@eingabeFile)
  end

  attr_reader :bild
  
  def speichere(png)
    png.save(@ausgabeFile, :interlace => true)
  end
end
