def calcfinalscore
	result = Benchmark.realtime do

		$rankingSize = 50

		puts "-----------------"
		puts "calFinalScore"

		
		queryPage = [1,1570,2295,2498,5926,6485,6585,8427,8492,8999,9985,23,169,286,310,391,414,462,478,651,787,797,887,900,921,957,958,959,982,1184]

		# クラスター毎にクエリページをいくつ含むか
		counter = []
		# クラスターごとの重みを格納
		w = []

		@finalAuthorityScore = Hash.new
		@finalHubScore = Hash.new

		newAutoritySocre = Hash.new
		newHubSocre = Hash.new

		$num.times do |clusterNum|
	
			# クラスタ番号ごとにクエリページがいくつでてくるか計算
			count = 0
			queryPage.each do |num|
				eval("@aScoreSortOutput#{clusterNum}").each do |i|

					if i[0].to_s == num.to_s
						count += 1
						break
					end

				end	
			end
			counter[clusterNum] = count

			# 重みを計算
			if(counter[clusterNum] != 0)
				w[clusterNum] = counter[clusterNum] * 1.0 / (queryPage.size * eval("@aScoreSortOutput#{clusterNum}").size * 1.0)
				#w[clusterNum] = counter[clusterNum] * 1.0 / eval("@aScoreSortOutput#{clusterNum}").size * 1.0
			else
				w[clusterNum] = 0
			end
	
		end

		# 重みの平均の算出
		average = w.inject(:+) / w.size

		# 重みの平均点
		puts "-----------------"
		puts "average"
		puts average

		puts "重み"
		p w


		# w.size.times do |i|
		# 	if w[i] > 0
		# 		eval("@aScoreSortOutput#{i}").each do |j|
		# 			newSocre = j[1].to_f * w[i]
		# 			@finalAuthorityScore[j[0]] = @finalAuthorityScore[j[1]].to_f + newSocre
		# 			puts "@finalAuthorityScore[33]"
		# 			puts @finalAuthorityScore["33"] 
		# 		end

		# 		eval("@hScoreSortOutput#{i}").each do |j|
		# 			newSocre = j[1].to_f * w[i]
		# 			@finalHubScore[j[0]] =  @finalHubScore[j[1]].to_f + newSocre
		# 		end
		# 	end
		# end

		w.size.times do |i|
			if w[i] > average
				eval("@aScoreSortOutput#{i}").each do |j|
					newAutoritySocre[j[0]] =  j[1].to_f * w[i]
					@finalAuthorityScore[j[0]] = @finalAuthorityScore[j[0]].to_f + newAutoritySocre[j[0]].to_f
				end

				eval("@hScoreSortOutput#{i}").each do |j|
					newHubSocre[j[0]] = j[1].to_f * w[i]
					@finalHubScore[j[0]] =  @finalHubScore[j[0]].to_f + newHubSocre[j[0]].to_f
				end
			end
		end

		puts "-----------------"
		puts "finalAuthorityScore"
		#p @finalAuthorityScore
		#p @finalAuthorityScore.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }	
		@finalAuthorityScore = @finalAuthorityScore.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }
		#p @finalAuthorityScore
		$rankingSize.times do |i|
			print @finalAuthorityScore[i][0].to_i
			puts ","
		end

		puts "-----------------"
		puts "finalHubScore"
		#p @finalHubScore
		#p @finalHubScore.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }	
		@finalHubScore = @finalHubScore.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }
		#p @finalHubScore
		$rankingSize.times do |i|
			print @finalHubScore[i][0].to_i
			puts ","
		end

		puts "-----------------"
		puts "clusterSize"
		puts $num
		puts "-----------------"
		
		# $num.times do |i|
		# 	puts "cluster#{i}"
		# 	p eval("@aScoreSortOutput#{i}")
		# 	puts "-----------------"
		# end

	end

	puts "計算処理時間"
	puts result
end