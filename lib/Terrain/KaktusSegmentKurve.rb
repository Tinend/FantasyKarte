require 'versetzePunkteArray'
require 'KaktusSegment'

class KaktusSegmentKurve < KaktusSegment
 
  attr_reader :ordnungsZahl

  def initialize(endPunkte, mittelPunkt, radiusGross, winkel, minFarbe, maxFarbe, randFarbe, linienFarbe, ordnungsZahl)
    p mittelPunkt
    @endPunkte = endPunkte
    @winkel = winkel
    @radiusGross = radiusGross
    @radiusKlein = (endPunkte[2][0] - endPunkte[0][0]) / 2.0
    @mittelPunkt = mittelPunkt
    @minFarbe = minFarbe
    @maxFarbe = maxFarbe
    @randFarbe = randFarbe
    @linienFarbe = linienFarbe
    @ordnungsZahl = ordnungsZahl
  end
  
  def <=>(x)
    return @ordnungsZahl <=> x.ordnungsZahl
  end

  def malen(png, x, y)
    kleinBild = ChunkyPNG::Image.new(png.width, png.height, ChunkyPNG::Color::TRANSPARENT)
    randBild = geruestMalen(kleinBild)
    png.compose!(kleinBild)
  end

  def geruestMalen(png)
    randBild = ChunkyPNG::Image.new(png.width, png.height, ChunkyPNG::Color::TRANSPARENT)
    (@radiusGross * 6 + 1).to_i.times do |wg|
      winkelGross = Math::PI / 12 * wg / @radiusGross
      malePunkt(randBild, winkelGross, 0, ChunkyPNG::Color::BLACK)
      malePunkt(randBild, winkelGross, Math::PI, ChunkyPNG::Color::BLACK)
      (@radiusKlein * 6 + 1).to_i.times do |wk|
        winkelKlein = Math::PI / 6 * wk / @radiusKlein
        malePunkt(png, winkelGross, winkelKlein, berechneFarbe(winkelGross, winkelKlein))
      end
    end
    png.compose!(randBild)
  end

  def berechneFarbe(winkelGross, winkelKlein)
    grau = ((@minFarbe + @maxFarbe) / 2.0).round
    ChunkyPNG::Color.rgba(255, grau, grau, 128)
  end
  
  def malePunkt(png, winkelGross, winkelKlein, farbe)
    kreisMittelPunkt = [
      @radiusGross * Math::sin(winkelGross) * Math::sin(@winkel),
      -@radiusGross * Math::cos(winkelGross),
      @radiusGross * Math::sin(winkelGross) * Math::cos(@winkel)
    ]
    sichtVektor = [0, 1, -2]
    zentrumsDifferentialVektor = [Math::cos(winkelGross) * Math::sin(@winkel), Math::sin(winkelGross), Math::cos(winkelGross) * Math::cos(@winkel)]
    nullGradVektor = kreuzProdukt(sichtVektor, zentrumsDifferentialVektor)
    neunzigGradVektor = kreuzProdukt(nullGradVektor, zentrumsDifferentialVektor)
    nullGradVektor = richtungsVektor(nullGradVektor)
    neunzigGradVektor = richtungsVektor(neunzigGradVektor)
    kleinRichtungsVektor = [
      (nullGradVektor[0] * Math::cos(winkelKlein) + neunzigGradVektor[0] * Math::sin(winkelKlein)) * @radiusKlein,
      (nullGradVektor[1] * Math::cos(winkelKlein) + neunzigGradVektor[1] * Math::sin(winkelKlein)) * @radiusKlein,
      (nullGradVektor[2] * Math::cos(winkelKlein) + neunzigGradVektor[2] * Math::sin(winkelKlein)) * @radiusKlein      
    ]
    if kleinRichtungsVektor[1] + 2 * kleinRichtungsVektor[2] < 0
      kleinRichtungsVektor.collect! {|element| -element}
    end
    positionsVektorRelativ = vektorAddition(kreisMittelPunkt, kleinRichtungsVektor)
    positionsVektor = vektorAddition(positionsVektorRelativ, [@mittelPunkt[0], @mittelPunkt[1], 0])
    pos = sichtKoordinatenTransformation(positionsVektor)
    p [pos, positionsVektor, @winkel, winkelGross, winkelKlein] if winkelGross >= Math::PI / 2 - 0.03 and winkelKlein >= Math::PI / 2 - 0.07 and winkelKlein <= Math::PI / 2 + 0.07
    png[pos[0], png.height * 2 / 3 - pos[1]] = berechneFarbe(winkelGross, winkelKlein)
  end
end
