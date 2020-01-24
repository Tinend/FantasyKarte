class Bewegung
  def initialize(x, y, maxt)
    @t = 0
    @x = x
    @y = y
    @maxt = maxt
  end

  attr_reader :x, :y
  
  def fertig?()
    return @maxt <= @t
  end

  def bewegeDich()
    @t += 1
  end
end
