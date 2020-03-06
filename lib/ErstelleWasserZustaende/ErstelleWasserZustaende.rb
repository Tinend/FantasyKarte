require "ErstelleWasserZustaende/WasserZustandPunkt"
require "Typen/WasserTyp"

module ErstelleWasserZustaende
  def self.erstelleWasserZustaende(breite:, hoehe:, wind:)
    zustaende = Array.new(hoehe) {|y| Array.new(breite) {|x| WasserZustandPunkt.new(x: 0, y: 0)}}
    zustaende[0][0] = WasserZustandPunkt.erstelleZufaellig(geschwindigkeit: wind.geschwindigkeit(0,0))
    self.updaten(abstand: 1, zustaende: zustaende, breite: breite, hoehe: hoehe, wind: wind, testArray: [[-1, 0], [0, -1]], akzeptanzen: [[true, true], [true, true]])
    0.times do
      self.updaten(abstand: 1, zustaende: zustaende, breite: breite, hoehe: hoehe, wind: wind, testArray: [[0, 0], [0, -1], [0, 1], [1, 0], [-1, 0]], akzeptanzen: [[true, false], [false, true]])
      self.updaten(abstand: 1, zustaende: zustaende, breite: breite, hoehe: hoehe, wind: wind, testArray: [[0,0], [0, -1], [0, 1], [1, 0], [-1, 0]], akzeptanzen: [[false, true], [true, false]])
    end
    return zustaende
    runden = [Math::log(breite, 2).to_i, Math::log(hoehe, 2).to_i].max
    (runden + 1).times do |i|
      abstand = 2 ** (runden - i)
      self.updaten(abstand: abstand, zustaende: zustaende, breite: breite, hoehe: hoehe, wind: wind, testArray: [[-1, -1], [-1, 1], [1, -1], [1, 1]], akzeptanzen: [[false, false], [false, true]])
      1.times do
        self.updaten(abstand: abstand, zustaende: zustaende, breite: breite, hoehe: hoehe, wind: wind, testArray: [[0, 0], [-1, -1], [-1, 1], [1, -1], [1, 1]], akzeptanzen: [[true, false], [false, false]])
        self.updaten(abstand: abstand, zustaende: zustaende, breite: breite, hoehe: hoehe, wind: wind, testArray: [[0,0], [-1, -1], [-1, 1], [1, -1], [1, 1]], akzeptanzen: [[false, false], [false, true]])
      end
      self.updaten(abstand: abstand, zustaende: zustaende, breite: breite, hoehe: hoehe, wind: wind, testArray: [[0, -1], [0, 1], [1, 0], [-1, 0]], akzeptanzen: [[false, true], [true, false]])
      1.times do
        self.updaten(abstand: abstand, zustaende: zustaende, breite: breite, hoehe: hoehe, wind: wind, testArray: [[0, 0], [0, -1], [0, 1], [1, 0], [-1, 0]], akzeptanzen: [[true, false], [false, true]])
        self.updaten(abstand: abstand, zustaende: zustaende, breite: breite, hoehe: hoehe, wind: wind, testArray: [[0,0], [0, -1], [0, 1], [1, 0], [-1, 0]], akzeptanzen: [[false, true], [true, false]])
      end
      #sleep(1)
    end
    zustaende
  end

  def self.berechneWinddistanz(wind:, start:, ziel:)
    return [0, 0] if start == ziel
    differenz = [ziel[0] - start[0], ziel[1] - start[1]]
    abstand = [differenz[0].abs, differenz[1].abs].max
    richtung = differenz.map {|eintrag| eintrag / abstand}
    raise if start[0] + richtung[0] * abstand != ziel[0]
    raise if start[1] + richtung[1] * abstand != ziel[1]
    geschwindigkeit = wind.geschwindigkeit(ziel[0], ziel[1] / 2.0)
    geschwindigkeit = 1 if geschwindigkeit == 0
    summe = wind.vektor(ziel[0], ziel[1] / 2.0).map.with_index {|wert, index| wert / 2 * richtung[index] / geschwindigkeit ** 2}
    abstand.times do |i|
      vektor = wind.vektor(start[0] + i * richtung[0], (start[1] + i * richtung[1]) / 2.0)
      geschwindigkeit = wind.geschwindigkeit(start[0] + i * richtung[0], (start[1] + i * richtung[1]) / 2.0)
      geschwindigkeit = 1 if geschwindigkeit == 0
      summe[0] += vektor[0] * richtung[0] / geschwindigkeit ** 2
      summe[1] += vektor[1] * richtung[1] / geschwindigkeit ** 2
    end
    geschwindigkeit = wind.geschwindigkeit(start[0], start[1] / 2.0)
    geschwindigkeit = 1 if geschwindigkeit == 0
    summe[0] -= wind.vektor(start[0], (start[1]) / 2.0)[0] / 2 * richtung[0] / geschwindigkeit ** 2
    summe[1] -= wind.vektor(start[0], (start[1]) / 2.0)[1] / 2 * richtung[1] / geschwindigkeit ** 2
    summe.map {|wert| wert / abstand}
  end

  def self.updaten(abstand:, zustaende:, breite:, hoehe:, wind:, testArray:, akzeptanzen:)
    ((hoehe + abstand - 1) / abstand).times do |kleinY|
      ((breite + abstand - 1) / abstand).times do |kleinX|
        if akzeptanzen[kleinY % 2][kleinX % 2]
          x = kleinX * abstand
          y = kleinY * abstand
          winde = []
          nachbarZustaende = []
          richtungen = []
          testArray.map do |test|
            testSkaliert = test.map {|wert| wert * abstand}
            if x + testSkaliert[0] >= 0 and x + testSkaliert[0] < breite and y + testSkaliert[1] >= 0 and y + testSkaliert[1] < hoehe
              winde.push(self.berechneWinddistanz(wind: wind, start: [x + testSkaliert[0], y + testSkaliert[1]], ziel: [x, y]))
              nachbarZustaende.push(zustaende[y + testSkaliert[1]][x + testSkaliert[0]])
              richtungen.push(testSkaliert)
            end
          end
          next if winde.length == 0
          geschwindigkeit = wind.geschwindigkeit(x, y / 2.0)
          zustaende[y][x] = WasserZustandPunkt.erstelleUpdate(winde, nachbarZustaende, richtungen, geschwindigkeit: geschwindigkeit)
        end
      end
    end
  end
  
end

