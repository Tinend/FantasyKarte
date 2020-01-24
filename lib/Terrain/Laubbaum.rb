require 'versetzePunkteArray'
require 'Ast'
require 'Baum'

class Laubbaum < Baum
  MittelpunktXVerschiebung = 20
  MittelpunktYVerschiebung = 20
  
  def initialize(hoehe)
    super(hoehe)
    @blattFarbe = 16 + rand(80)
    @stammFarbe = rand(32) + 8
    @biegungen = rand(8) + 1
    @biegungen = 1 if @biegungen < 3
    @linkerAst = Ast.new()
    if rand(4) == 0
      @rechterAst = @linkerAst.umkehren()
    elsif rand(3) == 0
      @rechterAst = @linkerAst.selbeHoeheAehnlich()
    elsif rand(2) == 0
      @rechterAst = @linkerAst.selberWinkelAehnlich()
    else
      @rechterAst = @linkerAst.aehnlich()
    end
    if rand(2) == 0
      ast = @linkerAst
      @linkerAst = @rechterAst
      @rechterAst = ast
      @linkerAst.winkel *= -1
      @rechterAst.winkel *= -1
    end
    @linkerAst.existiert = false if rand(300) == 0
    @rechterAst.existiert = false if rand(300) == 0
    if @biegungen == 1
      loop do
        @hoehe = hoehe - rand(0) * hoehe / 3
        @stammHoehe = @hoehe / 9 + rand(0) * @hoehe / 3
        @kronenHoehe = @hoehe - @stammHoehe
        untenVerschieben = rand(0) * @hoehe / 1 - rand(0) * @hoehe / 20
        kronenObenX = rand(0) * @hoehe / MittelpunktXVerschiebung * 2 - rand(0) * @hoehe / MittelpunktXVerschiebung * 2
        kronenLinksY = rand(0) * @hoehe / MittelpunktYVerschiebung * 2 - rand(0) * @hoehe / MittelpunktYVerschiebung * 2
        breite = @kronenHoehe + rand(0) * @kronenHoehe / 3 - rand(0) * @kronenHoehe / 3
        @punkteArray = [[
                          ChunkyPNG::Point.new(0, - @stammHoehe.round),
                          ChunkyPNG::Point.new((-breite / 2 + rand(0) * breite / 9 - rand(0) * breite / 9).round, (- @stammHoehe - kronenLinksY + rand(0) * @kronenHoehe / 9 - rand(0) * @kronenHoehe / 9 + untenVerschieben).round),
                          ChunkyPNG::Point.new((-breite / 2 + rand(0) * breite / 9  - rand(0) * breite / 9).round, (- @stammHoehe - @kronenHoehe - kronenLinksY + rand(0) * @kronenHoehe / 9 - rand(0) * @kronenHoehe / 9).round),
                          ChunkyPNG::Point.new((breite / 2 + rand(0) * breite / 9 - rand(0) * breite / 9).round, (- @stammHoehe - @kronenHoehe + kronenLinksY + rand(0) * @kronenHoehe / 9 - rand(0) * @kronenHoehe / 9).round),
                          ChunkyPNG::Point.new((breite / 2 + rand(0) * breite / 9 - rand(0) * breite / 9).round, (- @stammHoehe + kronenLinksY + rand(0) * @kronenHoehe / 9 - rand(0) * @kronenHoehe / 9 + untenVerschieben).round),
                          ChunkyPNG::Point.new(0, - @stammHoehe.round)
                        ]]
        fertig = true
        @punkteArray[0].each do |punkt|
          fertig = false if punkt.x < - hoehe / 2 or punkt.x >= hoehe / 2
          fertig = false if punkt.y > 0 or punkt.x <= - hoehe
        end
        break if fertig
      end
    else
      @hoehe = hoehe - rand(0) * hoehe / 6 - hoehe / 10.0
      @stammHoehe = @hoehe / 9 + rand(0) * @hoehe / 2.7
      @kronenHoehe = @hoehe - @stammHoehe
      if rand(10) < 5
        @spitz = true
      else
        @spitz = false
      end
      loop do
        mittelpunktYVerschiebung = rand(0) * @kronenHoehe / 8
        @kleinerKronenMittelpunkt = [0 + rand(0) * @hoehe / MittelpunktXVerschiebung - rand(0) * @hoehe / MittelpunktXVerschiebung, @stammHoehe + @kronenHoehe / 2 - mittelpunktYVerschiebung - rand(0) * @kronenHoehe / 6 + rand(0) * @kronenHoehe / 6]
        if rand(10) == 0
          @kleinerKronenMittelpunkt[0] = 0
        end
        @grosserKronenMittelpunkt = [@kleinerKronenMittelpunkt[0] + rand(0) * @hoehe / MittelpunktXVerschiebung - rand(0) * @hoehe / MittelpunktXVerschiebung, @stammHoehe + @kronenHoehe / 2 - mittelpunktYVerschiebung - rand(0) * @kronenHoehe / 9 + rand(0) * @kronenHoehe / 5]
        if rand(10) == 0
          @grosserKronenMittelpunkt[0] = @kleinerKronenMittelpunkt[0]
        end
        @kleineHoehe = ((@kleinerKronenMittelpunkt[1] - @stammHoehe) ** 2 + @kleinerKronenMittelpunkt[0] ** 2) ** 0.5 * 2
        @grosseHoehe = ((@hoehe - @grosserKronenMittelpunkt[1]) ** 2 + @grosserKronenMittelpunkt[0] ** 2) ** 0.5 * 2
        kronenBreiteVerkleinerung = rand(0) * @kronenHoehe / 6
        breiteKleiner = rand(0) * @kronenHoehe / 3 - rand(0) * @kronenHoehe / 6
        @kleineBreite = @kleineHoehe + rand(0) * @kronenHoehe / 4 - rand(0) * @kronenHoehe / 4 - breiteKleiner
        @grosseBreite = @grosseHoehe + rand(0) * @kronenHoehe / 4 - rand(0) * @kronenHoehe / 4 - breiteKleiner
        break if @kleineBreite <= @grosseBreite and @kleineHoehe <= @grosseHoehe
      end
      kleineWinkelVerschiebung = Math::atan(@kleinerKronenMittelpunkt[0] / (@kleinerKronenMittelpunkt[1] - @stammHoehe))
      grosseWinkelVerschiebung = Math::atan(@grosserKronenMittelpunkt[0] / (@grosserKronenMittelpunkt[1] - @stammHoehe))
      kleineBiegungsPunkte = Array.new(@biegungen) {1 + rand(0)}
      grosseBiegungsPunkte = Array.new(@biegungen) {|i| kleineBiegungsPunkte[i] + rand(0) / 10 - rand(0) / 10}
      kleineBiegungsSumme = kleineBiegungsPunkte.reduce(:+)
      grosseBiegungsSumme = grosseBiegungsPunkte.reduce(:+)
      punkteWinkelVerschieber = rand(0)
      winkelLinks = 0
      winkelRechts = 0
      (rand(3) + 1).times {winkelLinks += Math::PI * rand(0) / 10}
      (rand(3) + 1).times {winkelRechts += Math::PI * rand(0) / 10}
      winkelUnten = winkelLinks + winkelRechts
      kleinerWinkel = winkelLinks
      grosserWinkel = winkelLinks
      letztesX = 0
      letztesY = - @stammHoehe
      @punkteArray = Array.new(@biegungen) {|i|
        punkte = []
        punkte.push(ChunkyPNG::Point.new(letztesX.round, letztesY.round))
        if @spitz
          winkel = grosserWinkel + grosseBiegungsPunkte[i] * (2 * Math::PI - winkelUnten) / grosseBiegungsSumme * rand(0)
          punkte.push(ChunkyPNG::Point.new((@grosserKronenMittelpunkt[0] - @grosseBreite / 2.0 * Math::sin(winkel)).round, - (@grosserKronenMittelpunkt[1] - @grosseHoehe / 2.0 * Math::cos(winkel)).round))
        else
          zusatzWinkelVerschieber = rand(0)
          winkel1 = grosserWinkel + grosseBiegungsPunkte[i] * (2 * Math::PI - winkelUnten) / grosseBiegungsSumme * zusatzWinkelVerschieber * (1 - punkteWinkelVerschieber)
          winkel2 = grosserWinkel + grosseBiegungsPunkte[i] * (2 * Math::PI - winkelUnten) / grosseBiegungsSumme * (zusatzWinkelVerschieber * (1 - punkteWinkelVerschieber) + punkteWinkelVerschieber)
          punkte.push(ChunkyPNG::Point.new((@grosserKronenMittelpunkt[0] - @grosseBreite / 2.0 * Math::sin(winkel1)).round, - (@grosserKronenMittelpunkt[1] - @grosseHoehe / 2.0 * Math::cos(winkel1)).round))
          punkte.push(ChunkyPNG::Point.new((@grosserKronenMittelpunkt[0] - @grosseBreite / 2.0 * Math::sin(winkel2)).round, - (@grosserKronenMittelpunkt[1] - @grosseHoehe / 2.0 * Math::cos(winkel2)).round))
        end
        kleinerWinkel += kleineBiegungsPunkte[i] * (2 * Math::PI - winkelUnten) / kleineBiegungsSumme
        grosserWinkel += grosseBiegungsPunkte[i] * (2 * Math::PI - winkelUnten) / grosseBiegungsSumme
        if i == @biegungen - 1
          letztesX = 0
          letztesY = - @stammHoehe
        else
          letztesX = @kleinerKronenMittelpunkt[0] - @kleineBreite / 2.0 * Math::sin(kleinerWinkel)
          letztesY = - @kleinerKronenMittelpunkt[1] + @kleineHoehe / 2.0 * Math::cos(kleinerWinkel)
        end
        punkte.push(ChunkyPNG::Point.new(letztesX.round, letztesY.round))
        punkte
      }
    end
  end

  def blattMalen(png, x, y, blattFarbe)
    @punkteArray.each do |punkte|
      png.bezier_curve(versetzePunkteArray(punkte, x, y), stroke_color = blattFarbe)
    end
  end

  def stammMalen(png, x, y, stammFarbe, blattFarbe)
    @linkerAst.findePunkte(@stammHoehe, @hoehe, x, y, png, blattFarbe)
    @rechterAst.findePunkte(@stammHoehe, @hoehe, x, y, png, blattFarbe)
    @linkerAst.male(png, stammFarbe)
    @rechterAst.male(png, stammFarbe)
    png.line(x, y, x, y - @stammHoehe - 1, stammFarbe, stammFarbe)
  end

  def innenMalen(maxx, x, maxy, y)
    return 255 if maxx == 0 or maxy == 0
    minGrau = [@blattFarbe - 32, 0].max
    maxGrau = [@blattFarbe + 256, 255].min
    grau = ((minGrau * (maxx - x).to_f + maxGrau * x) / maxx * [y, maxy - y].min + (minGrau * y.to_f + maxGrau * (maxy - y)) / maxy * [x, maxx - x].min) / ([y, maxy - y].min + [x, maxx - x].min + 1)
    grau += rand(0) * (256 - grau) / 2
    grau = [0, grau].max
    grau = [grau, 255].min
    #grau = 255 if rand(2) == 0
    grau
  end
end
