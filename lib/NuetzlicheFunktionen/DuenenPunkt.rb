class DuenenPunkt
  MinHoehendifferenz = Math::tan(Math::PI / 12)
  MaxHoehendifferenz = Math::tan(Math::PI / 6)
  
  def initialize(x:, y:, hoehe:, windGeschwindigkeit:, windRichtung:)
    @x = x
    @y = y
    @hoehe = hoehe
    @windGeschwindigkeit = windGeschwindigkeit
    @windRichtung = windRichtung
  end

  attr_reader :x, :y
  attr_accessor :hoehe
  
  def <=>(punkt)
    - (punkt <=> @hoehe)
  end

  def berechneHoehe(lokalX, lokalY)
    skalarprodukt = ((@x - lokalX) * @windRichtung[0] + (@y - lokalY) * @windRichtung[1])
    faktor = skalarprodukt / ((@x - lokalX) ** 2 + (@y - lokalY) ** 2) ** 0.5
    verlust = (MinHoehendifferenz * (1 - faktor) / 2 + MaxHoehendifferenz * (1 + faktor) / 2) * ((@x - lokalX) ** 2 + (@y - lokalY) ** 2) ** 0.5
    if verlust < 0 or verlust > 4.5 * MaxHoehendifferenz
      p [@wind.richtung(x.round, y.round / 2.0), @wind.vektor(@x.round, @y.round / 2.0), @wind.geschwindigkeit(@x.round, @y.round / 2.0), skalarprodukt, faktor, verlust, [@x, @y], [lokalX, lokalY], ((x - lokalX) ** 2 + (y - lokalY) ** 2) ** 0.5, @hoehe]
      raise
    end
    @hoehe - verlust
  end
end
