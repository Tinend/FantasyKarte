require 'versetzePunkteArray'
require 'KaktusSegment'

class KaktusSegmentSpitze < KaktusSegment
 
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
          if y == 0
            grau = @randFarbe.round
          elsif png[x, y - 1] == ChunkyPNG::Color::TRANSPARENT
            grau = @randFarbe.round
          else
            grau = farbe(x, png.height * 2 / 3 - y - 1)
          end
          png[x,y] = ChunkyPNG::Color.rgb(grau, grau, grau)
        end
      end
    end
  end

  def istImBereich?(x,y)
    linkePunkte = [sichtKoordinatenTransformation(@linkePunkte[0]), sichtKoordinatenTransformation(@linkePunkte[1])]
    mittlerePunkte = [sichtKoordinatenTransformation(@mittlerePunkte[0]), sichtKoordinatenTransformation(@mittlerePunkte[1])]
    rechtePunkte = [sichtKoordinatenTransformation(@rechtePunkte[0]), sichtKoordinatenTransformation(@rechtePunkte[1])]
    maxYUntenVerschiebung = linkePunkte[0][1] - mittlerePunkte[0][1]
    radius = (rechtePunkte[0][0] - linkePunkte[0][0]) / 2.0
    if radius ** 2 > (rechtePunkte[0][0] / 2.0 + linkePunkte[0][0] / 2.0 - x) ** 2
      yUntenVerschiebung = (radius ** 2 - (rechtePunkte[0][0] / 2.0 + linkePunkte[0][0] / 2.0 - x) ** 2) ** 0.5 * maxYUntenVerschiebung / radius
    else
      yUntenVerschiebung = 0
    end
    maxYObenVerschiebung = mittlerePunkte[-1][1] - linkePunkte[0][1]
    if radius ** 2 > (rechtePunkte[0][0] / 2.0 + linkePunkte[0][0] / 2.0 - x) ** 2
      yObenVerschiebung = (radius ** 2 - (rechtePunkte[0][0] / 2.0 + linkePunkte[0][0] / 2.0 - x) ** 2) ** 0.5 * maxYObenVerschiebung / radius
    else
      yObenVerschiebung = 0
    end
    x >= linkePunkte[0][0].round and x <= rechtePunkte[0][0].round and y <= (linkePunkte[0][1] + yObenVerschiebung).round and y >= (linkePunkte[0][1] - yUntenVerschiebung).round
  end
  
  def farbe(x,y)
    linkePunkte = [sichtKoordinatenTransformation(@linkePunkte[0]), sichtKoordinatenTransformation(@linkePunkte[1])]
    mittlerePunkte = [sichtKoordinatenTransformation(@mittlerePunkte[0]), sichtKoordinatenTransformation(@mittlerePunkte[1])]
    rechtePunkte = [sichtKoordinatenTransformation(@rechtePunkte[0]), sichtKoordinatenTransformation(@rechtePunkte[1])]
    maxYUntenVerschiebung = linkePunkte[0][1] - mittlerePunkte[0][1]
    radius = (rechtePunkte[0][0] - linkePunkte[0][0]) / 2.0
    if radius ** 2 > (rechtePunkte[0][0] / 2.0 + linkePunkte[0][0] / 2.0 - x) ** 2
      yUntenVerschiebung = (radius ** 2 - (rechtePunkte[0][0] / 2.0 + linkePunkte[0][0] / 2.0 - x) ** 2) ** 0.5 * maxYUntenVerschiebung / radius
    else
      yUntenVerschiebung = 0
    end
    maxYObenVerschiebung = mittlerePunkte[-1][1] - linkePunkte[0][1]
    if radius ** 2 > (rechtePunkte[0][0] / 2.0 + linkePunkte[0][0] / 2.0 - x) ** 2
      yObenVerschiebung = (radius ** 2 - (rechtePunkte[0][0] / 2.0 + linkePunkte[0][0] / 2.0 - x) ** 2) ** 0.5 * maxYObenVerschiebung / radius
    else
      yObenVerschiebung = 0
    end
    if (x - linkePunkte[0][0] / 2.0 - rechtePunkte[0][0] / 2.0) ** 2 + (y - linkePunkte[0][1]) ** 2 * maxYUntenVerschiebung / radius >= (radius - 1) ** 2 and y >= linkePunkte[0][1]
      return @randFarbe.round
    elsif x == linkePunkte[0][0].round or x == rechtePunkte[0][0].round
      return @randFarbe.round
    else
      minFarbe = (@minFarbe * (linkePunkte[0][1] + yUntenVerschiebung - y + 0.5) + @maxFarbe * (maxYUntenVerschiebung + maxYObenVerschiebung + y - linkePunkte[0][1] - yUntenVerschiebung - 0.5)) / (maxYUntenVerschiebung + maxYObenVerschiebung)
      minFarbe = (@minFarbe * (maxYUntenVerschiebung + maxYObenVerschiebung + linkePunkte[0][1] - yUntenVerschiebung - y - 0.5) + @maxFarbe * (y - linkePunkte[0][1] + yUntenVerschiebung + 0.5)) / (maxYUntenVerschiebung + maxYObenVerschiebung)
      return (((x.to_f - linkePunkte[0][0]) * @maxFarbe + (rechtePunkte[0][0] - x.to_f) * minFarbe) / (rechtePunkte[0][0] - linkePunkte[0][0])).round
    end
  end
end
