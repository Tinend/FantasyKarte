require "ErstelleWasserZustaende/WasserZustandPunkt"
require "Typen/WasserTyp"

module ErstelleWasserZustaende
  def self.erstelleWasserZustaende(breite:, hoehe:, wind:)
    maxAbstand = [Math::log(breite - 1, 2), Math::log(hoehe - 1, 2)].min.to_i
    maxAbstand = [Math::log(breite - 1, 2), Math::log(hoehe - 1, 2)].max.to_i + 1
    abstand = 2 ** maxAbstand
    zustaendeAlt = Array.new((hoehe + abstand - 1) / abstand) do
      Array.new((breite + abstand - 1) / abstand) do
        WasserZustandPunkt.new(zustand: rand(0) * Math::PI * 2, wellenLaenge: WasserTyp::WellenLaenge)
      end
    end
    until abstand == 1
      abstand /= 2
      zustaendeNeu = Array.new((hoehe + abstand - 1) / abstand) do |y|
        Array.new((breite + abstand - 1) / abstand) do |x|
          if x % 2 == 0 and y % 2 == 0
            zustand = zustaendeAlt[y / 2][x / 2].dup
          else
            zustand = WasserZustandPunkt.new(zustand: 100 * abstand, wellenLaenge: 100000000)
          end
          zustand
        end
      end
      zustaendeNeu.each_with_index do |zeile, y|
        zeile.collect!.with_index do |punkt, x|
          if x % 2 == 1 and y % 2 == 1
            alteZustaende = [zustaendeAlt[y / 2][x / 2]]
            neueZustaende = [zustaendeNeu[y - 1][x - 1]]
            koordinaten = [[(x - 1) * abstand, (y - 1) * abstand]]
            if y < zustaendeNeu.length - 1
              alteZustaende.push(zustaendeAlt[y / 2 + 1][x / 2])
              neueZustaende.push(zustaendeNeu[y + 1][x - 1])
              koordinaten.push([(x - 1) * abstand, (y + 1) * abstand])
            end
            if x < zustaendeNeu[0].length - 1
              alteZustaende.push(zustaendeAlt[y / 2][x / 2 + 1])
              neueZustaende.push(zustaendeNeu[y - 1][x + 1])
              koordinaten.push([(x + 1) * abstand, (y - 1) * abstand])
            end
            if y < zustaendeNeu.length - 1 and x < zustaendeNeu[0].length - 1
              alteZustaende.push(zustaendeAlt[y / 2 + 1][x / 2 + 1])
              neueZustaende.push(zustaendeNeu[y + 1][x + 1])
              koordinaten.push([(x + 1) * abstand, (y + 1) * abstand])
            end
            zustand = self.berechneNeuenZustand(alteZustaende: alteZustaende, neueZustaende: neueZustaende, koordinaten: koordinaten, x: (x * abstand).to_i, y: (y * abstand).to_i, wind: wind)
          else
            zustand = punkt
          end
          zustand
        end
      end
      zustaendeAlt = zustaendeNeu
      zustaendeNeu = Array.new((hoehe + abstand - 1) / abstand) do |y|
        Array.new((breite + abstand - 1) / abstand) do |x|
          if x % 2 == 0 and y % 2 == 0
            zustand = zustaendeAlt[y][x].dup
          elsif x % 2 == 1 and y % 2 == 1
            zustand = zustaendeAlt[y][x].dup
          else
            zustand = WasserZustandPunkt.new(zustand: 0, wellenLaenge: 100000000000000000000000)
          end
          zustand
        end
      end
      zustaendeNeu.collect!.with_index do |zeile, y|
        zeile.collect.with_index do |punkt, x|
          if x % 2 == 0 and y % 2 == 0
            zustand = punkt
          elsif x % 2 == 0 or y % 2 == 0
            alteZustaende = []
            neueZustaende = []
            koordinaten = []
            if x > 0
              alteZustaende.push(zustaendeAlt[y][x - 1])
              neueZustaende.push(zustaendeNeu[y][x - 1])
              koordinaten.push([(x) * abstand, (y - 1) * abstand])
            end
            if x < zustaendeNeu[0].length - 1
              alteZustaende.push(zustaendeAlt[y][x + 1])
              neueZustaende.push(zustaendeNeu[y][x + 1])
              koordinaten.push([(x + 1) * abstand, y * abstand])
            end
            if y < zustaendeNeu.length - 1
              alteZustaende.push(zustaendeAlt[y + 1][x])
              neueZustaende.push(zustaendeNeu[y + 1][x])
              koordinaten.push([(x) * abstand, (y + 1) * abstand])
            end
            if y > 0
              alteZustaende.push(zustaendeAlt[y - 1][x])
              neueZustaende.push(zustaendeNeu[y - 1][x])
              koordinaten.push([(x) * abstand, (y - 1) * abstand])
            end
            zustand = self.berechneNeuenZustand(alteZustaende: alteZustaende, neueZustaende: neueZustaende, koordinaten: koordinaten, x: (x * abstand).to_i, y: (y * abstand).to_i, wind: wind)
          else
            zustand = punkt
          end
          zustand
        end
      end
      zustaendeAlt = zustaendeNeu
    end
    zustaendeAlt
  end

  def self.berechneNeuenZustand(alteZustaende:, neueZustaende:, koordinaten:, x:, y:, wind:)
    werte = alteZustaende.map.with_index do |zustand, i|
      #(zustand.zustand + self.berechneAbstand(alteKoordinaten: koordinaten[i], neueKoordinaten: [x, y], wind: wind) / zustand.wellenLaenge / (WasserTyp::MaxWellenSteigung / 2 / Math::PI)) % (2 * Math::PI)
      (zustand.zustand + self.berechneAbstand(alteKoordinaten: koordinaten[i], neueKoordinaten: [x, y], wind: wind) / zustand.wellenLaenge / (WasserTyp::MaxWellenSteigung / 2 / Math::PI))
    end
    #p [werte, x, y]
    #sleep(0.01)
    durchschnitt = werte.reduce(:+) / werte.length
    abweichung = werte.reduce(0) {|resultat, wert| [(durchschnitt - wert).abs, 2 * Math::PI - (durchschnitt - wert).abs].min}
    minDurchschnitt = durchschnitt
    (alteZustaende.length - 1).times do |i|
      andereAbweichung = werte.reduce(0) {|resultat, wert| [((durchschnitt + (i + 1) * 2 * Math::PI / alteZustaende.length) - wert).abs, 2 * Math::PI - ((durchschnitt + (i + 1) * 2 * Math::PI / alteZustaende.length) - wert).abs].min}
      #if andereAbweichung < abweichung
      #  abweichung = andereAbweichung
      #  minDurchschnitt = durchschnitt + (i + 1) * 2 * Math::PI / alteZustaende.length
      #end
    end
    zustand = WasserZustandPunkt.new(zustand: durchschnitt, wellenLaenge: alteZustaende.reduce(0) {|wert, zustand| wert + zustand.wellenLaenge} / alteZustaende.length)
    raise if zustand.wellenLaenge == 0
    alteZustaende.zip(neueZustaende, koordinaten).each do |zustandKoordinate|
      abstand = ((zustandKoordinate[2][0] - x) ** 2 + (zustandKoordinate[2][1] - y) ** 2) ** 0.5
      lokaleAbweichung = [(durchschnitt - zustandKoordinate[0].zustand).abs, 2 * Math::PI - (durchschnitt - zustandKoordinate[0].zustand).abs].min
      #verkleinerung = (Math::PI - lokaleAbweichung) / Math::PI / abstand
      verkleinerung = 0
      zustandKoordinate[1].wellenLaenge *= 1 - verkleinerung
      zustand.wellenLaenge *= 1 - verkleinerung
    end
    zustand
  end

  def self.berechneAbstand(alteKoordinaten:, neueKoordinaten:, wind:)
    return alteKoordinaten[0] - neueKoordinaten[0] #+ alteKoordinaten[1] - neueKoordinaten[1]
    return 0

    
    xAbstand = alteKoordinaten[0] - neueKoordinaten[0]
    yAbstand = alteKoordinaten[1] - neueKoordinaten[1]
    raise if xAbstand.abs != yAbstand.abs and xAbstand != 0 and yAbstand != 0
    distanz = [xAbstand.abs, yAbstand.abs].max
    abstand = 0
    distanz.times do |i|
      x = (alteKoordinaten[0] * (distanz - i) + neueKoordinaten[0] * i) / distanz
      y = (alteKoordinaten[1] * (distanz - i) + neueKoordinaten[1] * i) / distanz
      abstand += (xAbstand / distanz * wind.richtung(x, y / 2.0)[0] + yAbstand / distanz * wind.richtung(x, y / 2.0)[1]) / wind.geschwindigkeit(x, y / 2.0)
    end
    abstand
  end
  
end

