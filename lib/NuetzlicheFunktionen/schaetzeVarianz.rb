require "schaetzeErwartungswert"

def schaetzeVarianz(array, erwartungswert)
  #erwartungswert = schaetzeErwartungswert(array)
  array.map{|e| (e - erwartungswert)**2}.reduce(:+) / array.length.to_f
end
