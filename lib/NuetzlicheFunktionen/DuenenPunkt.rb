class DuenenPunkt
  MinHoehendifferenz = Math::tan(Math::PI / 12)
  MaxHoehendifferenz = Math::tan(Math::PI / 6)
  
  def initialize(x:, y:, hoehe:, windGeschwindigkeiten:, windRichtungen:)
    @x = x
    @y = y
    @hoehe = hoehe
    @windGeschwindigkeiten = windGeschwindigkeiten
    @windRichtungen = windRichtungen
    @maxGeschwindigkeit = @windGeschwindigkeiten.max
  end

  attr_reader :x, :y
  attr_accessor :hoehe
  
  def <=>(punkt)
    - (punkt <=> @hoehe)
  end

  def berechneHoehe(lokalX, lokalY)
    verlust = 5 * MaxHoehendifferenz 
    @windGeschwindigkeiten.length.times do |i|
      next if @windGeschwindigkeiten[i] != @maxGeschwindigkeit and @windGeschwindigkeiten[i] * WuestenErsteller::MaxHoehenFaktor2 < @hoehe * 2
      if @windGeschwindigkeiten[i] != nil
        skalarprodukt = ((@x - lokalX) * @windRichtungen[i][0] + (@y - lokalY) * @windRichtungen[i][1])
        faktor = skalarprodukt / ((@x - lokalX) ** 2 + (@y - lokalY) ** 2) ** 0.5
      else
        faktor = 1
      end
      verlust = [verlust, (MinHoehendifferenz * (1 - faktor) / 2 + MaxHoehendifferenz * (1 + faktor) / 2) * ((@x - lokalX) ** 2 + (@y - lokalY) ** 2) ** 0.5].min
      if verlust < 0 or verlust > 4.5 * MaxHoehendifferenz
        p [@windRichtungen, @windGeschwindigkeiten, faktor, verlust, [@x, @y], [lokalX, lokalY], ((x - lokalX) ** 2 + (y - lokalY) ** 2) ** 0.5, @hoehe]
        p skalarprodukt
        raise
      end
    end
    @hoehe - verlust
  end
end
