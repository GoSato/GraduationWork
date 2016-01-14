pageSize = 40
originakPageSize = 100


#r = ((0.58 + 1.0) * (originakPageSize * (originakPageSize - 1.0)) / (pageSize * (pageSize + 1))) - 1.0

r = ((1.58 * 100 * 99) / (40 * 39)) -1

puts r