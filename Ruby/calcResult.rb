def calc(a,b,c)
	difference = a - b
	difference.each do |i|
		c.delete(i)
	end
end


#------------------------------------
#従来
oldAuth = [7376,5,2894,9122,16938,11054,4663,8157,20241,9119,1476,4665,60546,7830,4669,4562,9127,9124,9125,9126,9121,9123,9120,20376,20375,20374,20372,20371,20373,4777,4561,4888,4666,4664,4667,4668,4670,843,2086,12745,12746,12747,12743,12742,8117,12748,11583,11563,8538,11312]
oldHub = [8157,8617,9127,9122,843,20371,60430,2894,4665,11054,8149,0,1785,2877,35679,39410,32898,7922,7533,5784,11699,20149,37494,5,4900,19866,19273,5538,60546,7375,60173,35498,36581,344,8561,7625,41950,52736,57073,38729,32875,31996,30789,1713,62198,881,57281,53430,12129,18507]

#今回
newAuth = [5,8157,4888,610,7376,9119,3837,11583,9122,9121,9120,9123,9126,9125,9124,202,2894,4663,16938,5784,4777,880,0,7533,3147,1389,2877,4665,8164,2162,13001,9127,1948,11054,20241,20372,20375,20373,20371,20374,317,11699,1785,18258,20376,33277,8916,843,841,844]
newHub = [8617,9127,11699,5,7922,843,8157,8149,9122,20371,35679,8331,53430,11054,840,1467,10079,2621,13216,4665,12129,25967,53883,2894,9527,881,880,19766,50040,46811,43050,30271,22772,37494,20149,39410,32898,2877,57975,30789,32875,31996,62198,1713,17555,60430,53881,8137,62406,41575]
#------------------------------------

if oldAuth.size != newAuth.size || oldHub.size != newHub.size
	puts "error"
end

calcOldAuth = oldAuth
calcNewAuth = newAuth

calcOldHub = oldHub
calcNewHub = newHub


# 適合率計算
matchAuth = oldAuth & newAuth
matchHub = oldHub & newHub

authPresicion = matchAuth.size.to_f / oldAuth.size.to_f
hubPresicion = matchHub.size.to_f / oldHub.size.to_f


# 順位相関係数計算
calc(oldAuth,newAuth,calcOldAuth)
calc(newAuth,oldAuth,calcNewAuth)

calc(oldHub,newHub,calcOldHub)
calc(newHub,oldHub,calcNewHub)

puts "-----------------"
puts "権威適合率"
puts authPresicion
puts "-----------------"
puts "ハブ適合率"
puts hubPresicion

puts "-----------------"
puts "新・既存の権威ランキング"
calcOldAuth.each do |i|
	puts i.to_i
end

puts "-----------------"
puts "新・前処理済み権威ランキング"
calcNewAuth.each do |i|
	puts i.to_i
end

puts "-----------------"
puts "権威ランキングサイズ"
puts calcOldAuth.size

puts "-----------------"
puts "新・既存のハブランキング"
calcOldHub.each do |i|
	puts i.to_i
end

puts "-----------------"
puts "新・前処理済みハブランキング"
calcNewHub.each do |i|
	puts i.to_i
end

puts "-----------------"
puts "ハブランキングサイズ"
puts calcOldHub.size

puts "-----------------"