class WasserZustandPunkt
  WellenLaenge = 3#8
  WellenMaximalSteigung = 13.0
  LaengeAnpassExponent = 0.7
  MaxEntfernung = 50
  LandNaeheWindStaerke = 0.04#0.02
    
  def self.erstelleUpdate(winde, nachbarZustaende, vektorDistanz, geschwindigkeit:)
    xy = winde.zip(nachbarZustaende, vektorDistanz).map do |windZustand|
      windZustand[1].berechneNeueKoordinaten(windZustand[0], windZustand[2])
    end
    self.berechneDurchschnitt(xy, geschwindigkeit: geschwindigkeit)
  end

  def self.berechneDistanz(wert:, richtung:, geschwindigkeit:)
    richtung.map {|richtungsSkalar| wert * richtungsSkalar / geschwindigkeit ** 2}
  end
  
  def self.berechneDurchschnitt(xy, geschwindigkeit:)
    #anzeige = []
    durchschnitt = xy.reduce(WasserZustandPunkt.new(x: 0, y: 0)) do |wasserZustand, punkt|
      punktLaenge = (punkt.x ** 2 + punkt.y ** 2) ** 0.5
      punktLaenge = 1 if punktLaenge == 0
      wasserZustand.x += punkt.x / xy.length / punktLaenge * geschwindigkeit * WellenLaenge
      wasserZustand.y += punkt.y / xy.length / punktLaenge * geschwindigkeit * WellenLaenge
      #anzeige.push([punkt.x / xy.length / punktLaenge * geschwindigkeit, punkt.y / xy.length / punktLaenge * geschwindigkeit])
      wasserZustand
    end
    #p anzeige
    #return durchschnitt
    durchschnittsLaenge = xy.reduce(0) {|summe, wasserZustandPunkt| summe + wasserZustandPunkt.laenge} / xy.length
    durchschnitt.laengeAnpassen(durchschnittsLaenge)
    #max = xy.max {|punkt1, punkt2| durchschnitt.abstand(punkt1) <=> durchschnitt.abstand(punkt2)}
    #durchschnitt.anpassenAn(max)
    #p [durchschnitt.x, durchschnitt.y]
    durchschnitt
  end

  def self.erstelleZufaellig(geschwindigkeit:)
    winkel = rand(0) * Math::PI
    WasserZustandPunkt.new(x: Math::sin(winkel) * WellenLaenge * geschwindigkeit, y: Math::cos(winkel) * WellenLaenge * geschwindigkeit)
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
    laengeAlt = 1 if laenge == 0
    @x *= (laengeNeu / laengeAlt) ** LaengeAnpassExponent
    @y *= (laengeNeu / laengeAlt) ** LaengeAnpassExponent
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
    p [1.0 / WellenMaximalSteigung, abstand(wasserZustandPunkt), - @x ** 2, @y ** 2]
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
    laengeAlt = 1 if laenge == 0
    @x *= (1 + verschiebung / laengeAlt)
    @y *= (1 + verschiebung / laengeAlt)
  end
end
