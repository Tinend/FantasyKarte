require 'Bewegung'

class ZufallsBewegung < Bewegung
  DrehKonstante = 0.5
  GeschwindigkeitsKonstante = 0.3
  
  def initialize(x, y, maxt)
    super(x,y,maxt)
    @richtung = rand(0)*Math::PI * 2
  end

  def bewegeDich()
    @richtung += (rand(0) - rand(0)) * DrehKonstante
    @x += Math::sin(@richtung) * GeschwindigkeitsKonstante
    @y += Math::cos(@richtung) * GeschwindigkeitsKonstante
    super()
  end
end
