require 'versetzePunkteArray'

class KaktusSegment
  def initialize(linkePunkte, mittlerePunkte, rechtePunkte, minFarbe, maxFarbe, randFarbe, linienFarbe, ordnungsZahl)
    @linkePunkte = linkePunkte
    @mittlerePunkte = mittlerePunkte
    @rechtePunkte = rechtePunkte
    @minFarbe = minFarbe
    @maxFarbe = maxFarbe
    @randFarbe = randFarbe
    @linienFarbe = linienFarbe
    @ordnungsZahl = ordnungsZahl
  end

  attr_reader :ordnungsZahl
  
  def <=>(x)
    return @ordnungsZahl <=> x.ordnungsZahl
  end

  def malen(png, x, y)
  end
  

  def kreuzProdukt(vektor1, vektor2)
    [vektor1[1] * vektor2[2] - vektor1[2] * vektor2[1], vektor1[2] * vektor2[0] - vektor1[0] * vektor2[2], vektor1[0] * vektor2[1] - vektor1[1] * vektor2[0]]
  end

  def richtungsVektor(vektor)
    laenge = 0
    vektor.each do |v|
      laenge += v ** 2
    end
    laenge = laenge ** 0.5
    Array.new(vektor.length) {|i| vektor[i] / laenge}
  end

  def vektorAddition(vektor1, vektor2)
    Array.new(vektor1.length) {|i| vektor1[i] + vektor2[i]}
  end

  def sichtKoordinatenTransformation(vektor)
    [vektor[0].round, (vektor[1] - vektor[2] / 2).round]
  end
end
