class Windrichtung

  MaxEntfernung = 500
  
  def initialize(vektor:, grundGeschwindigkeit:)
    @grundGeschwindigkeit = grundGeschwindigkeit
    #@vektor = [0.2 * @grundGeschwindigkeit,0]
    @vektor = vektor
  end

  def self.standardErzeugen(grundGeschwindigkeit:)
    Windrichtung.new(vektor: [0, 0], grundGeschwindigkeit: grundGeschwindigkeit)
  end

  def erzeugeWasserWindRichtung(x:, y:, naechsterPunkt:)
    laenge = ((x - naechsterPunkt[0]) ** 2 + (y - naechsterPunkt[1]) ** 2) ** 0.5
    return Windrichtung.new(vektor: @vektor, grundGeschwindigkeit: @grundGeschwindigkeit) if naechsterPunkt == [x, y] or laenge >= MaxEntfernung
    wasserVektor = @vektor.dup
    wasserVektor.collect! {|element| element * laenge / MaxEntfernung}    
    wasserVektor[0] += (x - naechsterPunkt[0]) / laenge * (MaxEntfernung - laenge) ** 0.5 * 10000000
    wasserVektor[1] += (x - naechsterPunkt[1]) / laenge * (MaxEntfernung - laenge) ** 0.5 * 10000000
    Windrichtung.new(vektor: wasserVektor, grundGeschwindigkeit: @grundGeschwindigkeit)
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
