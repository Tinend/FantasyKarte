class Windrichtung
  def initialize()
    @vektor = [0.2,0]
  end

  attr_reader :vektor
  
  def windVektorErhalten(winkel)
    @vektor[0] += Math::sin(winkel)
    @vektor[1] += Math::cos(winkel)
  end

  def richtung()
    [@vektor[0] / (@vektor[0] ** 2 + @vektor[1] ** 2) ** 0.5, @vektor[1] / (@vektor[0] ** 2 + @vektor[1] ** 2) ** 0.5]
  end
  
  def geschwindigkeit()
    (@vektor[0] ** 2 + @vektor[1] ** 2) ** 0.5
  end

  def senkrecht(orientierung)
    [- @vektor[1] * orientierung, @vektor[0] * orientierung]
  end
end
