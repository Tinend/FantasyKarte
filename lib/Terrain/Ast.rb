class Ast
  MinHoehe = 0.4
  MaxHoehe = 0.9
  MaxSchritteProHoehe = 10
  SchrittWeite = 0.1
  def initialize(richtung = 1)
    loop do
      @winkel = - Math::PI / 7 * rand(0) * richtung
      until rand(3) == 0
        @winkel -= Math::PI / 12 * rand(0) * richtung
      end
      break if @winkel * richtung > - Math::PI / 2
    end
    @hoehenVariable = 1 - (MinHoehe + (MaxHoehe - MinHoehe) * rand(0))
    @existiert = true
  end

  attr_accessor :winkel, :hoehenVariable, :existiert
  
  def umkehren()
    ast = Ast.new(-1)
    ast.winkel = - @winkel
    ast.hoehenVariable = @hoehenVariable
    ast
  end

  def selbeHoeheAehnlich()
    ast = Ast.new(-1)
    ast.winkel = ast.winkel / 2 - @winkel / 2
    ast.hoehenVariable = @hoehenVariable
    ast
  end

  def selberWinkelAehnlich()
    ast = Ast.new(-1)
    ast.winkel = - @winkel
    ast.hoehenVariable = ast.hoehenVariable / 2 + @hoehenVariable / 2
    ast
  end

  def aehnlich()
    ast = Ast.new(-1)
    ast.winkel = ast.winkel / 2 - @winkel / 2
    ast.hoehenVariable = ast.hoehenVariable / 2 + @hoehenVariable / 2
    ast
  end

  def hoeheBerechnen(stammHoehe, hoehe)
    stammHoehe.to_f / hoehe * (hoehe - @hoehenVariable * hoehe)
  end
  
  def findePunkte(stammHoehe, hoehe, x, y, png, farbe)
    @startPos = [x, y - hoeheBerechnen(stammHoehe, hoehe)]
    @endPos = @startPos.dup
    @nichtMalen = true
    return 0 unless @existiert
    @nichtMalen = false
    schritt = 0
    until png[@endPos[0].round, @endPos[1].round] == farbe
      @endPos[0] += Math::sin(@winkel) * SchrittWeite
      @endPos[1] -= Math::cos(@winkel) * SchrittWeite
      schritt += 1
      #break if schritt >= MaxSchritteProHoehe * stammHoehe
      if schritt >= MaxSchritteProHoehe * stammHoehe
        @nichtMalen = true
        return 0
      end
    end
  end
  
  def male(png, farbe)
    unless @nichtMalen
      png.line(@startPos[0].round, @startPos[1].round, @endPos[0].round, @endPos[1].round, farbe, farbe)
    end
  end
end
