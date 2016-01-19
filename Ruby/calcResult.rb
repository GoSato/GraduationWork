def calc(a,b,c)
	difference = a - b
	difference.each do |i|
		c.delete(i)
	end
end


#------------------------------------
#従来
oldAuth = [8555,7874,9978,7522,8492,6894,6866,7916,3202,3173,2061,5672,6485,8501,9833,1162,2295,7774,2498,8701,7987,9248,1215,8516,1034,2979,6862,9098,6138,6141,4353,957,4417,7905,6805,6782,9942,9944,8007,4235,7981,8427,5926,3286,6252,5539,3171,4364,9934,7794]
oldHub = [958,848,1,462,414,1034,373,957,3173,391,1162,1215,2061,7874,191,565,2498,396,6485,7522,2295,2979,2348,189,529,6866,651,1028,259,143,1243,323,3202,8492,2980,5661,7916,8701,2841,831,3642,5121,5672,2602,7295,1170,23,7408,7506,2563]

#今回
newAuth = [958,462,7874,8534,8492,8555,2498,189,7008,4424,5661,7522,1034,5408,8735,2602,9108,5926,5037,3919,6022,7014,7466,6628,3421,4934,4838,301,9833,9978,4711,8160,1928,6260,8427,7082,1688,3637,9985,9669,9494,6857,5740,3215,3148,3173,6585,6141,1242,9142]
newHub = [396,373,565,191,1,462,958,848,391,957,137,189,640,414,432,56,1215,58,259,143,274,3202,14,301,2295,529,184,1535,1096,7874,1034,2498,1162,730,5672,4189,831,1307,148,803,947,1638,1500,2979,3797,5121,1446,945,1110,2348]
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