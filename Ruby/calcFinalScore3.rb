def calcfinalscore
	result = Benchmark.realtime do

		$rankingSize = 20

		puts "-----------------"
		puts "calFinalScore"

		
		queryPage = [1,3,2,4,8,9,10,14,28,29]

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
				#w[clusterNum] = counter[clusterNum] * 1.0 / (queryPage.size * eval("@aScoreSortOutput#{clusterNum}").size * 1.0)
				#w[clusterNum] = counter[clusterNum] * 1.0 / eval("@aScoreSortOutput#{clusterNum}").size * 1.0
				w[clusterNum] = counter[clusterNum] * eval("@aScoreSortOutput#{clusterNum}").size * 1.0 / (queryPage.size * 1.0)
			else
				w[clusterNum] = 0
			end
	
		end

		wCopy = w.clone

		wCopy.delete(0)

		wCopy = wCopy.sort {|a, b| b <=> a }

		puts "wCopy"
		p wCopy

		# 中央値の算出
		if wCopy.size % 2 != 0
			i = wCopy.size.to_f / 2 - 0.5
			average = wCopy[i]
		else
			average = (wCopy[wCopy.size / 2] + wCopy[(wCopy.size / 2) - 1]) / 2
		end

		# 重みの平均の算出
		#average = w.inject(:+) / w.size

		# 重みの平均点
		puts "-----------------"
		puts "average"
		puts average

		puts "重み"
		p wCopy

		w.size.times do |i|
			if w[i] > 0
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
		# p @finalAuthorityScore
		$rankingSize.times do |i|
			print @finalAuthorityScore[i][0].to_i
			puts ","
		end

		puts "-----------------"
		puts "finalHubScore"
		#p @finalHubScore
		#p @finalHubScore.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }	
		@finalHubScore = @finalHubScore.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }
		# p @finalHubScore
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