def calcfinalscore
	result = Benchmark.realtime do

		puts "-----------------"
		puts "calFinalScore"

		queryPage = [3,9,7]
		#queryPage = [554,1547,1546,1023,1339,1636,2499,3169,3342,3343,3344,3345,3346,2392,3382]

		# クラスター毎にクエリページをいくつ含むか
		counter = []
		# クラスターごとの重みを格納
		w = []

		@finalAuthorityScore = Hash.new
		@finalHubScore = Hash.new

		$num.times do |clusterNum|
	
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
			w[clusterNum] = counter[clusterNum] * 1.0 / (queryPage.size * eval("@aScoreSortOutput#{clusterNum}").size * 1.0)
	
		end

		# 重みの平均の算出
		average = w.inject(:+) / w.size

		puts "-----------------"
		puts "average"
		puts average

		w.size.times do |i|
			if w[i] > 0
				eval("@aScoreSortOutput#{i}").each do |j|
					newSocre = j[1].to_f * w[i]
					@finalAuthorityScore[j[0]] = newSocre
				end

				eval("@hScoreSortOutput#{i}").each do |j|
					newSocre = j[1].to_f * w[i]
					@finalHubScore[j[0]] = newSocre
				end
			end
		end

		puts "-----------------"
		puts "finalAuthorityScore"
		#p @finalAuthorityScore
		p @finalAuthorityScore.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }	

		puts "-----------------"
		puts "finalHubScore"
		#p @finalHubScore
		p @finalHubScore.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }	

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