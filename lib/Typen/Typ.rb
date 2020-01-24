class Typ
  def initialize(breite, hoehe)
    @hoehe = hoehe
    @breite = breite
    @hintergrund = ChunkyPNG::Image.new(@breite, @hoehe, ChunkyPNG::Color::TRANSPARENT)
  end
  
  def macheTerrain(datenFarbe, x, y)
    raise
    [ChunkyPNG::Image.new(0, 0, ChunkyPNG::Color::TRANSPARENT), [0, 0]]
  end

  def kannFaerben?(datenFarbe)
    return true if self.class::MussFaerbenNummern.any? {|mfn| ChunkyPNG::Color.r(datenFarbe) == mfn} or self.class::DarfFaerbenNummern.any? {|dfn| ChunkyPNG::Color.r(datenFarbe) == dfn}
    return false
  end

  def mussFaerben?(datenFarbe)
    self.class::MussFaerbenNummern.any? {|mfn| ChunkyPNG::Color.r(datenFarbe) == mfn}
  end

  def horizontalerAbstand(datenFarbe)
    if datenFarbe % 10 == 0
      dichte = 4
    else
      dichte = ChunkyPNG::Color.r(datenFarbe) % 10 - 1
    end
    dichte * self.class::HorizontalerAbstandFaktor + self.class::HorizontalerAbstandMinimum
  end
  
  def vertikalerAbstand(datenFarbe)
    if datenFarbe % 10 == 0
      dichte = 4
    else
      dichte = ChunkyPNG::Color.r(datenFarbe) % 10 - 1
    end
    dichte * self.class::VertikalerAbstandFaktor + self.class::VertikalerAbstandMinimum
  end

  def verwalteHintergrund(x, y, datenFarbe)
    @hintergrund[x, y] = ChunkyPNG::Color::BLACK
  end

  def erstelleHintergrund(hintergrund)
  end
end
