def calc(a,b,c)
	difference = a - b
	difference.each do |i|
		c.delete(i)
	end
end


#------------------------------------
#権威
oldAuth = [4888,8149,610,7376,3837,9122,2894,202,4663,880]
newAuth = [7376,5,2894,9122,16938,11054,4663,8157,20241,9119]

#ハブ
oldHub = [8617,9127,843,9122,35679,8157,8149,40956,32821,59798]
newHub = [8157,8617,9127,9122,843,20371,60430,2894,4665,11054]
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