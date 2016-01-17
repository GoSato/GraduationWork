def calc(a,b,c)
	difference = a - b
	difference.each do |i|
		c.delete(i)
	end
end


#------------------------------------
#権威
oldAuth = [5,474349,4562,246369,835128,115587,581741,39733,300279,579655,167433,878814,1476,843,892414,294362,369007,608321,219773,33218,824158,4663,646184,535142,120614,411022,136689,321407,151044,103434]
newAuth = [474349,285454,104678,707901,888016,766734,643538,186720,107231,421867,103329,837589,916214,95872,829593,39733,300279,630081,579655,581741,242657,821730,297375,658312,711562,4562,246369,835128,115587,624238]

#ハブ
oldHub = [5,608321,581741,285454,219773,535142,39733,294362,892414,120614,33218,4663,167433,694620,300279,579655,376952,365382,204640,697387,103434,559617,369007,870411,662225,550679,115587,4562,835128,246369]
newHub = [816962,39733,766734,646497,470342,628041,829593,600374,617672,553430,247722,78410,66393,234505,603166,643106,883136,433888,353110,170762,10533,2417,300279,413923,106188,837589,556242,495843,707901,630081]
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