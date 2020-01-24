class TerrainVerwalter
  def initialize(terrainTyp, hintergrund, mittelgrund, vordergrund, datenBild)
    @datenBild = datenBild
    @terrainTyp = terrainTyp
    @hintergrund = hintergrund
    @mittelgrund = mittelgrund
    @vordergrund = vordergrund
    @besetzt = Array.new(mittelgrund.width) {
      Array.new(mittelgrund.height) {
        false
      }
    }
  end

  attr_reader :terrainTyp
  
  def verwalte(x, y, datenFarbe)
    @terrainTyp.verwalteHintergrund(x, y, datenFarbe)
    verwalteMittelgrund(x, y, datenFarbe)
  end
  
  def verwalteMittelgrund(x, y, datenFarbe)
    frei = true
    (terrainTyp.horizontalerAbstand(datenFarbe) * 2 + 3).to_i.times do |nahx|
      (terrainTyp.vertikalerAbstand(datenFarbe) + 3).to_i.times do |nahy|
        posx = (x + nahx - terrainTyp.horizontalerAbstand(datenFarbe)).round
        posy = (y + nahy - terrainTyp.vertikalerAbstand(datenFarbe)).round
        if posx >= 0 and posx < @besetzt.length and posy >= 0 and posy < @besetzt[0].length
          frei = false if @besetzt[posx][posy] and ((x - posx) / terrainTyp.horizontalerAbstand(datenFarbe).to_f) ** 2 + ((y - posy) / terrainTyp.vertikalerAbstand(datenFarbe).to_f) ** 2 < 1
        end
      end
    end
    if frei and @terrainTyp.definiereTerrain?(datenFarbe)
      bild, koordinatenAnsatz = @terrainTyp.macheTerrain(datenFarbe, x, y)
      if einsetzbar?(x, y, koordinatenAnsatz, bild)
        @besetzt[x][y] = true
        if leichtEinsetzbar?(x, y, koordinatenAnsatz, bild)
          @mittelgrund.compose!(bild, offset_x = x - koordinatenAnsatz[0], offset_y = y - koordinatenAnsatz[1])
        else
          einsetzen!(x, y, koordinatenAnsatz, bild)
        end
      end
    end
  end

  def einsetzbar?(x, y, koordinatenAnsatz, bild)
    (bild.width).times do |xBild|
      (bild.height).times do |yBild|
        posx = x + xBild - koordinatenAnsatz[0]
        posy = y + yBild - koordinatenAnsatz[1]
        if ChunkyPNG::Color.a(bild[xBild, yBild]) != 0
          return false if posx < 0
          return false if posx >= @mittelgrund.width
          return false if posy < 0
          return false if posy >= @mittelgrund.height
          return false unless @terrainTyp.kannFaerben?(@datenBild.get_pixel(posx, posy))
          if @terrainTyp.class::MindestAbstand >= 0
            return false unless nahOk?(posx,posy)
          end
        end
      end
    end
    return true
  end

  def nahOk?(posx, posy)
    minx = [posx - @terrainTyp.class::MindestAbstand, 0].max
    maxx = [posx + @terrainTyp.class::MindestAbstand, @mittelgrund.width - 1].min
    miny = [posy - @terrainTyp.class::MindestAbstand, 0].max
    maxy = [posy + @terrainTyp.class::MindestAbstand, @mittelgrund.height - 1].min
    (maxx - minx + 1).times do |x|
      (maxy - miny + 1).times do |y|
        return false if @mittelgrund[x + minx, y + miny] != ChunkyPNG::Color::WHITE
      end
    end
    return true
  end

  def leichtEinsetzbar?(x, y, koordinatenAnsatz, bild)
    posx = x - koordinatenAnsatz[0]
    posy = y - koordinatenAnsatz[1]
    return false if posx < 0
    return false if posx + bild.width >= @mittelgrund.width
    return false if posy < 0
    return false if posy + bild.height >= @mittelgrund.height
    return true
  end

  def mussFaerben?(datenFarbe)
    @terrainTyp.mussFaerben?(datenFarbe)
  end

  def einsetzen!(x, y, koordinatenAnsatz, bild)
   (bild.width).times do |xBild|
      (bild.height).times do |yBild|
        posx = x + xBild - koordinatenAnsatz[0]
        posy = y + yBild - koordinatenAnsatz[1]
        if ChunkyPNG::Color.a(bild[xBild, yBild]) != 0
          @mittelgrund[posx, posy] = bild.get_pixel(xBild, yBild)
        end
      end
    end
  end

  def erstelleHintergrund()
    @terrainTyp.erstelleHintergrund(@hintergrund)
  end
end
