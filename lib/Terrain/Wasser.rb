require 'versetzePunkteArray'

class Wasser
  def initialize(breiteVariable, wellenGang)
    @breiteVariable = breiteVariable
    @wellenGang = wellenGang
    @wellen = 1
    until rand(2) == 0
       @wellen += 1
    end
  end

  def malen()
    kleinBild = ChunkyPNG::Image.new(@breiteVariable * (@wellen + 1), @wellenGang + 2, ChunkyPNG::Color::TRANSPARENT)
    @punkteArray = Array.new(@wellen + 1) {|i|
      [
        ChunkyPNG::Point.new(@breiteVariable * i, 1),
        ChunkyPNG::Point.new(@breiteVariable * i, @wellenGang + 1),
        ChunkyPNG::Point.new(@breiteVariable * (i + 1), @wellenGang + 1),
        ChunkyPNG::Point.new(@breiteVariable * (i + 1), 1)
      ]
    }
    @punkteArray.each do |punkte|
      kleinBild.bezier_curve(punkte, ChunkyPNG::Color::BLACK)
    end
    kleinBild.crop((@breiteVariable + 1) / 2, 0, @breiteVariable * @wellen + 2, @wellenGang + 2)
  end

end
