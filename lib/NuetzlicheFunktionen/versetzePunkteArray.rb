def versetzePunkteArray(array, x, y)
  Array.new(array.length()) {|i| ChunkyPNG::Point.new(array[i].x + x, array[i].y + y)}
end
