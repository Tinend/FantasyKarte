class WasserZustandPunkt
  def initialize(zustand:, wellenLaenge:)
    @zustand = zustand
    @wellenLaenge = wellenLaenge
  end

  attr_reader :zustand
  attr_accessor :wellenLaenge

  def dup
    WasserZustandPunkt.new(zustand: @zustand.to_f, wellenLaenge: @wellenLaenge.to_f)
  end
end
