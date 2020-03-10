require "ErstelleWasserZustaende/WasserZustandPunkt"

class Windrichtung
  
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
    return Windrichtung.new(vektor: @vektor.dup, grundGeschwindigkeit: @grundGeschwindigkeit) if naechsterPunkt == [x, y]
    return Windrichtung.new(vektor: @vektor.dup, grundGeschwindigkeit: @grundGeschwindigkeit) if laenge >= WasserZustandPunkt::MaxEntfernung
    wasserVektor = @vektor.dup
    #puts
    #p (WasserZustandPunkt::MaxEntfernung - laenge) ** 0.5 * WasserZustandPunkt::LandNaeheWindStaerke
    #p wasserVektor
    wasserVektor.collect! {|element| element * (laenge / WasserZustandPunkt::MaxEntfernung) ** 2}
    #p wasserVektor
    wasserVektor[0] += (x - naechsterPunkt[0]) / laenge ** 0.4 * (WasserZustandPunkt::MaxEntfernung - laenge) ** 0.6 * WasserZustandPunkt::LandNaeheWindStaerke
    wasserVektor[1] += (y - naechsterPunkt[1]) / laenge ** 0.4 * (WasserZustandPunkt::MaxEntfernung - laenge) ** 0.6 * WasserZustandPunkt::LandNaeheWindStaerke
    #p wasserVektor
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
