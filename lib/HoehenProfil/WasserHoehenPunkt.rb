require "HoehenProfil/HoehenPunkt"

class WasserHoehenPunkt < HoehenPunkt
  WasserHelligkeit = 128
  SonnenVektor = [-0.5, -0.5, 0.5 ** 0.5]
  BeobachterVektor = [0, -1, 0.5]
  ZwischenVektor = SonnenVektor.zip(BeobachterVektor).map {|elemente| (elemente[0] + elemente[1]) / 2.0}
  HelligkeitBasis = 128.0
  SpiegelHelligkeitsFaktor = 2.0
  
  def farbe(scheinbareHoehe:, scheinbareBreite:, normalVektor:)
    helligkeit = scheinbareHoehe * scheinbareBreite * WasserHelligkeit
    helligkeit += berechneSpiegelungsHelligkeit(normalVektor: normalVektor)
    helligkeit
  end

  def berechneSpiegelungsHelligkeit(normalVektor:)
    skalarProdukt = normalVektor.zip(ZwischenVektor).reduce(0) {|summe, elemente| summe + elemente.reduce(:*)}
    cos = skalarProdukt / normalVektor.reduce(0) {|summe, element| (summe ** 2 + element ** 2) ** 0.5} / ZwischenVektor.reduce(0) {|summe, element| (summe ** 2 + element ** 2) ** 0.5}
    HelligkeitBasis ** cos * SpiegelHelligkeitsFaktor
  end
end

