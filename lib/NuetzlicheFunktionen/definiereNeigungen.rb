def definiereNeigungen(breite, hoehe, fallKonstante)
  neigungenAlt = [[]]
  neigungen = Array.new(3) {Array.new(3) {(rand(0) - rand(0))}}
  i = 0
  erwartungswert = 0
  until neigungen.length >= breite and neigungen[0].length >= hoehe
    neigungenAlt = neigungen
    neigungen = Array.new((neigungenAlt.length - 1) * 2) {|x|
      Array.new((neigungenAlt[0].length - 1) * 2) {|y|
        (neigungenAlt[x / 2][y / 2] + neigungenAlt[x / 2 + 1][y / 2] + neigungenAlt[x / 2][y / 2 + 1] + neigungenAlt[x / 2 + 1][y / 2 + 1]) / 4 + (rand(0) - rand(0)) * fallKonstante ** i
      }
    }
    i += 1
  end
  neigungen
end
