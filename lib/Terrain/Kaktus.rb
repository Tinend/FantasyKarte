require "KaktusSegmentAlt"
require "KaktusSegmentSenkrecht"
require "KaktusSegmentSpitze"
require "KaktusSegmentKurve"

class Kaktus
  def initialize(hoehe)
    @gesamtHoehe = hoehe
    @hoehe = @gesamtHoehe / 3.3 + @gesamtHoehe * rand(0) / 2.7
    @breite = hoehe / 13.0 + rand(0) * hoehe / 10
    @anzahlNebensegmente = 0
    @randFarbe = rand(64)
    @minFarbe = @randFarbe + rand(64)
    @maxFarbe = 255 - rand(96)
    @linienFarbe = rand(64)
    @segmente = []
    @nebenDicke = @breite * rand(0) * 0.8 + @breite * 0.1
    @nebenDickeAbweichung = @nebenDicke * rand(0) / 5
    @nebenSegmentEntfernung = (@nebenDicke + @nebenDickeAbweichung) / 2.0 + rand(0) * @breite
    kreiereHauptsegmente()
    kreiereNebensegmente()
    @segmente.sort!
  end

  def kreiereNebensegmente()
    #anzahlNebensegmente = rand(4)
    anzahlNebensegmente = 1
    anzahlNebensegmente.times do
      kreiereNebensegment()
    end
  end

  def kreiereNebensegment()
    dicke = @nebenDicke + (rand(0) - rand(0)) * @nebenDickeAbweichung
    #winkel = rand(0) * Math::PI * 2 - Math::PI
    winkel = Math::PI * 0.3
    hoehe = rand(0) * (@hoehe - @nebenSegmentEntfernung - dicke / 2.0)
    mittelPunkt = [@breite / 2.0 * Math::sin(winkel) + @gesamtHoehe / 2.0, hoehe + @nebenSegmentEntfernung, @breite / 2.0 * Math::cos(winkel) + @breite / 2]
    mitte = [mittelPunkt[0] + @nebenSegmentEntfernung * Math::sin(winkel), mittelPunkt[1], mittelPunkt[2] + @nebenSegmentEntfernung * Math::cos(winkel)]
    endPunkte = [
      [mitte[0] - dicke / 2, mitte[1], mitte[2]],
      [mitte[0], mitte[1], dicke / 2 + mitte[2]],
      [mitte[0] + dicke / 2, mitte[1], mitte[2]]
    ]


    
    #mitte = [@breite / 2.0 * Math::sin(winkel) + @linkePunkte[0][0] + 1, @breite / 4.0 * Math::cos(winkel) + hoehe + @linkePunkte[0][1] + dicke / 2.0]
    #linkePunkte = [
    #  [mitte[0] - Math::cos(winkel) * dicke / 2.0, mitte[1] + Math::sin(winkel) * dicke / 2.0],
    #  [mitte[0] - dicke / 4.0 + @nebenSegmentEntfernung * Math::sin(winkel), mitte[1] + Math::sin(winkel) * dicke / 2.0],
    #  [mitte[0] - dicke / 2.0 + @nebenSegmentEntfernung * Math::sin(winkel), mitte[1] + @nebenSegmentEntfernung]
    #]
    #mittlerePunkte = [
    #  [mitte[0] - Math::cos(winkel - Math::PI / 2) * dicke / 2.0, mitte[1] + Math::sin(winkel - Math::PI / 2) * dicke / 2.0],
    #  [mitte[0] + @nebenSegmentEntfernung * Math::sin(winkel), mitte[1] + Math::sin(winkel - Math::PI / 2) * dicke / 2.0 - dicke / 4.0],
    #  [mitte[0] + @nebenSegmentEntfernung * Math::sin(winkel), mitte[1] + @nebenSegmentEntfernung - dicke / 2.0]
    #]
    #rechtePunkte = [
    #  [mitte[0] - Math::cos(winkel - Math::PI) * dicke / 2.0, mitte[1] + Math::sin(winkel - Math::PI) * dicke / 2.0],
    #  [mitte[0] + dicke / 4.0 + @nebenSegmentEntfernung * Math::sin(winkel), mitte[1] + Math::sin(winkel - Math::PI) * dicke / 2.0],
    #  [mitte[0] + dicke / 2.0 + @nebenSegmentEntfernung * Math::sin(winkel), mitte[1] + @nebenSegmentEntfernung]
    #]

    p [endPunkte]
    p [mittelPunkt, mitte]
    ordnungsZahl = (Math::PI / 2 - winkel.abs) * 1000000
    @segmente.push(KaktusSegmentKurve.new(endPunkte, mittelPunkt, @nebenSegmentEntfernung, winkel, @minFarbe, @maxFarbe, @randFarbe, @linienFarbe, ordnungsZahl))
    #@segmente.push(KaktusSegmentAlt.new(linkePunkte, mittlerePunkte, rechtePunkte, @minFarbe, @maxFarbe, @randFarbe, @linienFarbe, ordnungsZahl))
    kreiereNebenSenkrechte(dicke, endPunkte[0], endPunkte[1], endPunkte[2], winkel + 1)
  end
                   
  def kreiereNebenSenkrechte(dicke, linkerPunkt, mittlererPunkt, rechterPunkt, ordnungsZahl)
    hoehe = rand(0) * (@linkePunkte[1][1] - linkerPunkt[1])
    linkePunkte = [
      linkerPunkt,
      [linkerPunkt[0], linkerPunkt[1] + hoehe, linkerPunkt[2]]
    ]
    mittlerePunkte = [
      mittlererPunkt,
      [mittlererPunkt[0], mittlererPunkt[1] + hoehe, mittlererPunkt[2]]
    ]
    rechtePunkte = [
      rechterPunkt,
      [rechterPunkt[0], rechterPunkt[1] + hoehe, rechterPunkt[2]]
    ]
    #@segmente.push(KaktusSegmentAlt.new(linkePunkte, mittlerePunkte, rechtePunkte, @minFarbe, @maxFarbe, @randFarbe, @linienFarbe, ordnungsZahl))
    @segmente.push(KaktusSegmentSenkrecht.new(linkePunkte, mittlerePunkte, rechtePunkte, @minFarbe, @maxFarbe, @randFarbe, @linienFarbe, ordnungsZahl))
    kreiereSpitze(linkePunkte[1], mittlerePunkte[1], rechtePunkte[1], ordnungsZahl)
  end
  
  def kreiereHauptsegmente()
    @linkePunkte = [[(@gesamtHoehe - @breite) / 2, @gesamtHoehe / 10, 0], [(@gesamtHoehe - @breite) / 2, @gesamtHoehe / 10 + @hoehe, 0]]
    @mittlerePunkte = [[@gesamtHoehe / 2, @gesamtHoehe / 10, @breite / 2], [@gesamtHoehe / 2, @gesamtHoehe / 10 + @hoehe, @breite / 2]]
    @rechtePunkte = [[(@gesamtHoehe + @breite) / 2, @gesamtHoehe / 10, 0], [(@gesamtHoehe + @breite) / 2, @gesamtHoehe / 10 + @hoehe, 0]]
    ordnungsZahl = 0
    @segmente.push(KaktusSegmentSenkrecht.new(@linkePunkte, @mittlerePunkte, @rechtePunkte, @minFarbe, @maxFarbe, @randFarbe, @linienFarbe, ordnungsZahl))
    kreiereSpitze(@linkePunkte[-1], @mittlerePunkte[-1], @rechtePunkte[-1], ordnungsZahl)
  end

  def kreiereSpitze(linkerPunkt, mittlererPunkt, rechterPunkt, ordnungsZahl)
    mitte = [(linkerPunkt[0] + rechterPunkt[0]) / 2, (linkerPunkt[1] + rechterPunkt[1]) / 2, (linkerPunkt[2] + rechterPunkt[2]) / 2]
    vektor = [(mitte[0] - mittlererPunkt[0]) * 1.5, (mitte[1] - mittlererPunkt[1]) * 1.5, (mitte[2] - mittlererPunkt[2]) * 1.5]
    linkePunkte = [linkerPunkt, [linkerPunkt[0] + vektor[0], linkerPunkt[1] + vektor[1], 0], [mittlererPunkt[0] + 2 * vektor[0], mittlererPunkt[1] + 2 * vektor[1], 0]]
    mittlerePunkte = [mittlererPunkt, [mittlererPunkt[0] + vektor[0], mittlererPunkt[1] + vektor[1], mittlererPunkt[2] + vektor[2]], [mittlererPunkt[0] + 2 * vektor[0], mittlererPunkt[1] + 2 * vektor[1], mittlererPunkt[2] + 2 * vektor[2]]]
    rechtePunkte = [rechterPunkt, [rechterPunkt[0] + vektor[0], rechterPunkt[1] + vektor[1], 0], [mittlererPunkt[0] + 2 * vektor[0], mittlererPunkt[1] + 2 * vektor[1], 0]]
    #@segmente.push(KaktusSegmentAlt.new(linkePunkte, mittlerePunkte, rechtePunkte, @minFarbe, @maxFarbe, @randFarbe, @linienFarbe, ordnungsZahl + 1))
    @segmente.push(KaktusSegmentSpitze.new(linkePunkte, mittlerePunkte, rechtePunkte, @minFarbe, @maxFarbe, @randFarbe, @linienFarbe, ordnungsZahl + 1))
  end

  def malen()
    @kleinBild = ChunkyPNG::Image.new(@gesamtHoehe, (@gesamtHoehe * 1.5 + 1).to_i, ChunkyPNG::Color::TRANSPARENT)
    @segmente.each do |segment|
      segment.malen(@kleinBild, 0, @gesamtHoehe)
    end
    return @kleinBild
  end
end
