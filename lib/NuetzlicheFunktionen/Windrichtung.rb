class Windrichtung
  def initialize(grundGeschwindigkeit:)
    @grundGeschwindigkeit = grundGeschwindigkeit
    @vektor = [0.2 * @grundGeschwindigkeit,0]
    #@vektor = [0,0]
  end

  attr_reader :vektor
  
  def windVektorErhalten(winkel)
    @vektor[0] += Math::sin(winkel) * @grundGeschwindigkeit
    @vektor[1] += Math::cos(winkel) * @grundGeschwindigkeit
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

  def richtung()
     @vektor.map {|element| element / geschwindigkeit}
  end
end
