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
    verlust = 5 * MaxHoehendifferenz 
    return if @windGeschwindigkeit * WuestenErsteller::MaxHoeheErreichen < @hoehe * 2
    skalarprodukt = ((@x - lokalX) * @windRichtung[0] + (@y - lokalY) * @windRichtung[1])
    faktor = skalarprodukt / ((@x - lokalX) ** 2 + (@y - lokalY) ** 2) ** 0.5
    verlust = [verlust, (MinHoehendifferenz * (1 - faktor) / 2 + MaxHoehendifferenz * (1 + faktor) / 2) * ((@x - lokalX) ** 2 + (@y - lokalY) ** 2) ** 0.5].min
    if verlust < 0 or verlust > 4.5 * MaxHoehendifferenz
      p [@windRichtung, @windGeschwindigkeit, faktor, verlust, [@x, @y], [lokalX, lokalY], ((x - lokalX) ** 2 + (y - lokalY) ** 2) ** 0.5, @hoehe]
      p skalarprodukt
      raise
    end
    @hoehe - verlust
  end
end
