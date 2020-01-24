require 'versetzePunkteArray'
require 'KaktusSegment'

class KaktusSegmentSenkrecht < KaktusSegment
 
  attr_reader :ordnungsZahl
  
  def <=>(x)
    return @ordnungsZahl <=> x.ordnungsZahl
  end

  def malen(png, x, y)
    kleinBild = ChunkyPNG::Image.new(png.width, png.height, ChunkyPNG::Color::TRANSPARENT)
    grundMalen(kleinBild)
    png.compose!(kleinBild)
  end

  def grundMalen(png)
    png.height.times do |y|
      png.width.times do |x|
        if istImBereich?(x, png.height * 2 / 3 - y - 1)
          grau = farbe(x, png.height * 2 / 3 - y - 1)
          png[x,y] = ChunkyPNG::Color.rgb(grau, grau, grau)
        end
      end
    end
  end

  def istImBereich?(x,y)
    maxYVerschiebung = sichtKoordinatenTransformation(@mittlerePunkte[0])[1] - sichtKoordinatenTransformation(@linkePunkte[0])[1]
    radius = (sichtKoordinatenTransformation(@rechtePunkte[0])[0] - sichtKoordinatenTransformation(@linkePunkte[0])[0]) / 2.0
    if radius ** 2 > (sichtKoordinatenTransformation(@rechtePunkte[0])[0] / 2.0 + sichtKoordinatenTransformation(@linkePunkte[0])[0] / 2.0 - x) ** 2
      yVerschiebung = (radius ** 2 - (sichtKoordinatenTransformation(@rechtePunkte[0])[0] / 2.0 + sichtKoordinatenTransformation(@linkePunkte[0])[0] / 2.0 - x) ** 2) ** 0.5 * maxYVerschiebung / radius
    else
      yVerschiebung = 0
    end
    x >= sichtKoordinatenTransformation(@linkePunkte[0])[0].round and x <= sichtKoordinatenTransformation(@rechtePunkte[0])[0].round and y >= (sichtKoordinatenTransformation(@linkePunkte[0])[1] + yVerschiebung).round and y <= (sichtKoordinatenTransformation(@linkePunkte[1])[1] + yVerschiebung).round
  end
  
  def farbe(x,y)
    if x == sichtKoordinatenTransformation(@linkePunkte[0])[0].round or x == sichtKoordinatenTransformation(@rechtePunkte[0])[0].round
      return @randFarbe.round
    else
      return (((x.to_f - sichtKoordinatenTransformation(@linkePunkte[0])[0]) * @maxFarbe + (sichtKoordinatenTransformation(@rechtePunkte[0])[0] - x.to_f) * @minFarbe) / (sichtKoordinatenTransformation(@rechtePunkte[0])[0] - sichtKoordinatenTransformation(@linkePunkte[0])[0])).round
    end
  end
end
