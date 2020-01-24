class RandPixel
  def initialize(x, y, distanz)
    @x = x
    @y = y
    @distanz = distanz
  end

  attr_reader :x, :y, :distanz

  def <=>(randPixel)
    @distanz <=> randPixel.distanz
  end
end
