require 'versetzePunkteArray'
require 'Baum'

class Nadelbaum < Baum
  MittelpunktXVerschiebung = 20
  MittelpunktYVerschiebung = 20
  
  def initialize(hoehe)
    super(hoehe)
    @blattFarbe = rand(64) + 32
    @stammFarbe = rand(64)
    @dichte = rand(0) * rand(0)
    loop do
      @spitzen = 1
      until rand(3) == 0
        @spitzen += 1
      end
      break if @spitzen <= 6
    end
    @hoehe = hoehe - rand(0) * hoehe / 6 - hoehe / 10.0
    @stammHoehe = @hoehe / 14 + rand(0) * @hoehe / 4
    @kronenHoehe = @hoehe - @stammHoehe

    oberBiegung = (rand(2) == 0)
    obererBiegungsMittelpunkt = rand(0)
    obereBiegungsVerschiebung = rand(0) * @kronenHoehe / 10
    
    unterBiegung = (rand(2) == 0)
    untererBiegungsMittelpunkt = rand(0)
    untereBiegungsVerschiebung = rand(0) * @kronenHoehe / 5
    
    @innenSpitze = [rand(0) * @hoehe / 10 - rand(0) * @hoehe / 10, @stammHoehe + @kronenHoehe]
    @aussenSpitze = [@innenSpitze[0] * rand(0) * @hoehe / 20 - rand(0) * @hoehe / 20, @stammHoehe + @kronenHoehe + rand(0) * @kronenHoehe]
    if rand(5) == 0
      @innenSpitze[0] = 0
    end
    @biegung = rand(0)
    @biegung = 0 if rand(3) == 0
    loop do
      aussenVerschiebung = rand(0) * @kronenHoehe * 0.3
      @aussenLinksStart = [rand(0) * @kronenHoehe * 0.1 + @kronenHoehe * 0.2 + aussenVerschiebung, @stammHoehe]
      @aussenRechtsStart = [rand(0) * @kronenHoehe * 0.1 + @kronenHoehe * 0.2 + aussenVerschiebung, @stammHoehe]
      @untenBiegung = rand(0) * (@aussenLinksStart[0] + @aussenRechtsStart[0]) / 8
      innenVerschiebung = rand(0) * @kronenHoehe * 0.2
      @innenLinksStart = [rand(0) * @kronenHoehe * 0.08 + @kronenHoehe * 0.016 + innenVerschiebung, @stammHoehe]
      @innenRechtsStart = [rand(0) * @kronenHoehe * 0.08 + @kronenHoehe * 0.016 + innenVerschiebung, @stammHoehe]
      break if @innenLinksStart[0] < @aussenLinksStart[0] and @innenRechtsStart[0] < @aussenRechtsStart[0]
    end
    innenKnotenPunkte = Array.new(@spitzen) {1 + rand(0)}
    
    innereLinksKnotenPunkte = Array.new(@spitzen) {|i| innenKnotenPunkte[i] + rand(0) / 10 - rand(0) / 10}
    innereLinksKnotenSumme = innereLinksKnotenPunkte.reduce(:+)
    linksInnen = 0

    innereRechtsKnotenPunkte = Array.new(@spitzen) {|i| innenKnotenPunkte[i] + rand(0) / 10 - rand(0) / 10}
    innereRechtsKnotenSumme = innereRechtsKnotenPunkte.reduce(:+)
    rechtsInnen = 0

    aussenKnotenPunkte = Array.new(@spitzen) {1 + rand(0)}

    aeussereLinksKnotenPunkte = Array.new(@spitzen) {|i| aussenKnotenPunkte[i] / 2 + innereLinksKnotenPunkte[i] / 2 + rand(0) / 10 - rand(0) / 10}
    aeussereLinksKnotenSumme = aeussereLinksKnotenPunkte.reduce(:+)
    linksAussen = 0

    aeussereRechtsKnotenPunkte = Array.new(@spitzen) {|i| aussenKnotenPunkte[i] / 3 + innereRechtsKnotenPunkte[i] / 2 + rand(0) / 10 - rand(0) / 10}
    aeussereRechtsKnotenSumme = aeussereRechtsKnotenPunkte.reduce(:+)
    rechtsAussen = 0

    letztesXLinks = 0
    letztesXRechts = 0
    letztesYLinks = - @stammHoehe
    letztesYRechts = - @stammHoehe
    hilfsPunkteArray = Array.new(@spitzen * 2) {|i|
      punkteRechts = []
      punkteLinks = []
      punkteRechts.push(ChunkyPNG::Point.new(letztesXRechts.round, letztesYRechts.round))
      punkteLinks.push(ChunkyPNG::Point.new(letztesXLinks.round, letztesYLinks.round))
      if i % 2 == 1
        linksInnen += innereLinksKnotenPunkte[i / 2]
        rechtsInnen += innereRechtsKnotenPunkte[i / 2]
      end
      
      xLinksAussen = @aussenLinksStart[0] * (1 - linksAussen / aeussereLinksKnotenSumme) * @kronenHoehe / (@aussenSpitze[1] - @stammHoehe)
      yLinksAussen = - (@stammHoehe + linksAussen / aeussereLinksKnotenSumme * @kronenHoehe)
      xRechtsAussen = @aussenRechtsStart[0] * (1 - rechtsAussen / aeussereRechtsKnotenSumme) * @kronenHoehe / (@aussenSpitze[1] - @stammHoehe)
      yRechtsAussen = - (@stammHoehe + rechtsAussen / aeussereRechtsKnotenSumme * @kronenHoehe)

      xLinksInnen = @innenLinksStart[0] * (1 - linksInnen / innereLinksKnotenSumme) * @kronenHoehe / (@innenSpitze[1] - @stammHoehe)
      yLinksInnen = - (@stammHoehe + linksInnen / innereLinksKnotenSumme * @kronenHoehe)
      xRechtsInnen = @innenRechtsStart[0] * (1 - rechtsInnen / innereRechtsKnotenSumme) * @kronenHoehe / (@innenSpitze[1] - @stammHoehe)
      yRechtsInnen = - (@stammHoehe + rechtsInnen / innereRechtsKnotenSumme * @kronenHoehe)
      
      if @untenBiegung and i % 2 == 0
        biegung = rand(0) * @kronenHoehe / 10 + untereBiegungsVerschiebung
        punkteLinks.push(ChunkyPNG::Point.new(-(xLinksAussen * untererBiegungsMittelpunkt + xLinksInnen * (1 - untererBiegungsMittelpunkt)).round, ((yLinksAussen * untererBiegungsMittelpunkt + yLinksInnen * (1 - untererBiegungsMittelpunkt) + biegung).round)))
        punkteRechts.push(ChunkyPNG::Point.new((xRechtsAussen * untererBiegungsMittelpunkt + xRechtsInnen * (1 - untererBiegungsMittelpunkt)).round, ((yRechtsAussen * untererBiegungsMittelpunkt + yRechtsInnen * (1 - untererBiegungsMittelpunkt) + biegung).round)))
      elsif @obenBiegung and @untenBiegung and i % 2 == 1
        biegung = rand(0) * @kronenHoehe / 10 + obereBiegungsVerschiebung
        punkteLinks.push(ChunkyPNG::Point.new(-(xLinksAussen * obererBiegungsMittelpunkt + xLinksInnen * (1 - obererBiegungsMittelpunkt) - biegung).round, ((yLinksAussen * obererBiegungsMittelpunkt + yLinksInnen * (1 - obererBiegungsMittelpunkt) + biegung).round)))
        punkteRechts.push(ChunkyPNG::Point.new((xRechtsAussen * obererBiegungsMittelpunkt + xRechtsInnen * (1 - obererBiegungsMittelpunkt) - biegung).round, ((yRechtsAussen * obererBiegungsMittelpunkt + yRechtsInnen * (1 - obererBiegungsMittelpunkt) + biegung).round)))
      end
      if i % 2 == 0
        letztesXLinks = -xLinksAussen
        letztesYLinks = yLinksAussen
        letztesXRechts = xRechtsAussen
        letztesYRechts = yRechtsAussen
      else
        letztesXLinks = -xLinksInnen
        letztesYLinks = yLinksInnen
        letztesXRechts = xRechtsInnen
        letztesYRechts = yRechtsInnen
      end
      punkteLinks.push(ChunkyPNG::Point.new((letztesXLinks).round, (letztesYLinks).round))
      punkteRechts.push(ChunkyPNG::Point.new((letztesXRechts).round, (letztesYRechts).round))
      if i % 2 == 1
        linksAussen += aeussereLinksKnotenPunkte[i / 2]
        rechtsAussen += aeussereRechtsKnotenPunkte[i / 2]          
      end
      [punkteRechts, punkteLinks]
    }
    @punkteArray = hilfsPunkteArray.reduce(:+)
  end

  def blattMalen(png, x, y, blattFarbe)
    @punkteArray.each do |punkte|
      png.bezier_curve(versetzePunkteArray(punkte, x, y), stroke_color = blattFarbe)
    end
  end
  
  def stammMalen(png, x, y, stammFarbe, blattFarbe)
    png.line(x, y, x, y - @stammHoehe - 1, stammFarbe, stammFarbe)
  end

  def innenMalen(maxx, x, maxy, y)
    minGrau = [@blattFarbe, 0].max
    maxGrau = [@blattFarbe + 128, 255].min
    grau = (minGrau * (maxx - x).to_f + maxGrau * (x + y / 10.0)) / (maxx + y / 10.0)
    #grau += rand(0) * (256 - grau)
    #grau = 255 if rand(0) > @dichte or true
    grau
  end
end
