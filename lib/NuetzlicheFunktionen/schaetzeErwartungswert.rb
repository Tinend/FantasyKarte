def schaetzeErwartungswert(array)
  array.reduce(:+) / array.length.to_f
end
