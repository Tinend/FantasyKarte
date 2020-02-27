class HoehenPunkt
  def initialize(hoehe)
    @hoehe = hoehe
  end

  attr_reader :hoehe

  def farbe(scheinbareHoehe:, scheinbareBreite:)
    scheinbareHoehe * scheinbareBreite * 256
  end
end

