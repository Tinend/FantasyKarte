class WasserZustandPunkt
  #WellenLaenge = 4.0
  WellenLaenge = 3.0
  #WellenMaximalSteigung = 15
  WellenMaximalSteigung = 10.0
  
  def self.erstelleUpdate(winde, nachbarZustaende, vektorDistanz)
    xy = winde.zip(nachbarZustaende, vektorDistanz).map do |windZustand|
      windZustand[1].berechneNeueKoordinaten(windZustand[0], windZustand[2])
    end
    self.berechneDurchschnitt(xy)
  end

  def self.berechneDurchschnitt(xy)
    durchschnitt = xy.reduce(WasserZustandPunkt.new(x: 0, y: 0)) do |wasserZustand, punkt|
      punktLaenge = (punkt.x ** 2 + punkt.y ** 2) ** 0.5
      wasserZustand.x += punkt.x / xy.length / punktLaenge
      wasserZustand.y += punkt.y / xy.length / punktLaenge
      wasserZustand
    end
    #return durchschnitt
    durchschnittsLaenge = xy.reduce(0) {|summe, wasserZustandPunkt| summe + wasserZustandPunkt.laenge} / xy.length
    durchschnitt.laengeAnpassen(durchschnittsLaenge)
    max = xy.max {|punkt1, punkt2| durchschnitt.abstand(punkt1) <=> durchschnitt.abstand(punkt2)}
    durchschnitt.anpassenAn(max)
    durchschnitt
  end

  def self.erstelleZufaellig()
    winkel = rand(0) * Math::PI
    WasserZustandPunkt.new(x: Math::sin(winkel) * WellenLaenge, y: Math::cos(winkel) * WellenLaenge)
  end
  
  def initialize(x:, y:)
    raise if x.to_f.nan?
    @x = x
    @y = y
  end

  def laenge
    (@x ** 2 + @y ** 2) ** 0.5
  end

  def laengeAnpassen(laengeNeu)
    laengeAlt = laenge
    @x *= laengeNeu / laengeAlt
    @y *= laengeNeu / laengeAlt
  end
  
  def berechneNeueKoordinaten(wind, vektorDistanz)
    windGeschwindigkeit = (wind[0] ** 2 + wind[1] ** 2) ** 0.5
    windGeschwindigkeit = 1 if windGeschwindigkeit == 0
    windRichtung = wind.map {|vektorEintrag| vektorEintrag / windGeschwindigkeit}
    verschiebung = windRichtung.zip(vektorDistanz).reduce(0) {|summe, wrVd| summe + wrVd.reduce(:*)}
    if laenge == 0
      rotation = 0
    else
      rotation = verschiebung / laenge
    end
    WasserZustandPunkt.new(x: @x * Math::cos(rotation) + @y * Math::sin(rotation), y: - @x * Math::sin(rotation) + @y * Math::cos(rotation))
  end
  
  attr_accessor :x, :y

  def dup
    WasserZustandPunkt.new(x: @x, y: @y)
  end

  def hoehe
    y / WellenMaximalSteigung
  end

  def abstand(wasserZustandPunkt)
    ((@x - wasserZustandPunkt.x) ** 2 + (@y - wasserZustandPunkt.y) ** 2) ** 0.5
  end

  def anpassenAn(wasserZustandPunkt)
    verschiebung = [1.0 / WellenMaximalSteigung - abstand(wasserZustandPunkt), - (@x ** 2 + @y ** 2) ** 0.5 / 10].max
    verschiebung = 0 if verschiebung < 0
    if verschiebung > 0
      verschiebung *= ([1 - laenge / WellenLaenge * 0.5, 0].max) ** 2
    end
    #if rand(10000) == 0
      #p ["V", laenge, verschiebung, 1.0 / WellenMaximalSteigung, abstand(wasserZustandPunkt), - (@x ** 2 + @y ** 2) ** 0.5 / 2, 1 - WellenLaenge / laenge * 0.5]
      #sleep(0.1)
    #end
    laengeAlt = laenge
    @x *= (1 + verschiebung / laengeAlt)
    @y *= (1 + verschiebung / laengeAlt)
  end
end
