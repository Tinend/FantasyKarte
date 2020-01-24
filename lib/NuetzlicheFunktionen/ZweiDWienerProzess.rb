class ZweiDWienerProzess
  def initialize()
  end

  def erstelleZweiDWienerProzess(breite, hoehe, abstand)
    wert = 0
    array = Array.new((breite - 1) * abstand + 1) do
      wert += 1 - rand(2) * 2
      wert
    end
    #array = Array.new(breite * abstand, 0)
    Array.new(hoehe) do |y|
      if y == 0
        next array.select.with_index {|wert, i| i % abstand == 0}.map {|wert| wert}
      end
      abstand.times {array = ueberarbeiteArray(array)}
      puts "#{y + 1} #{hoehe}" if (y + 1) * 10 % hoehe == 0
      array.select.with_index {|wert, i| i % abstand == 0}.map {|wert| wert}
      #array.select.with_index {|wert, i| i % abstand == abstand - 1}.map {|wert| wert}
    end
  end

  def ueberarbeiteArray(array)
    wert = array[0] + 1 - rand(2) * 2
    #wert = 0
    Array.new(array.length) do |i|
      if i == 0
        wert = array[0]
      else
        wert = wert + array[i] - array[i - 1] + 1 - rand(2) * 2
      end
      wert + 1 - rand(2) * 2
    end
  end
end
