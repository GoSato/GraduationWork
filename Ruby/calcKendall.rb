pageSize = ARGV[0].to_f
originakPageSize = ARGV[1].to_f

score = ARGV[2].to_f

r = ((pageSize * (pageSize - 1.0) * (1.0 + score)) / (originakPageSize * (originakPageSize - 1.0))) - 1.0
puts r