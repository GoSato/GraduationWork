require 'benchmark'
require 'matrix'

class SALSA


	def make_List

		@dataSetList = Array.new # dateSet中の全ページのリスト

		@file = []

		i = 0
		x = 0

		File.open(ARGV[0]){|file|
			file.each_line do |line|
				
				first_num,second_num = line.chomp!.split(",")

				@file[x] = [first_num,second_num]

				@dataSetList[i] = first_num
				@dataSetList[i+1] = second_num
				i += 2
				x += 1
			end
		}

		@dataSetList = @dataSetList.uniq

		# 全ページのリストを返す
		return @dataSetList
		
	end

	# 入出リンク数が最大のものをSeedPageに
	def find_SeedPage

		# ページ数カウント用
		counter = Hash.new

		@file.size.times do |i|
				
			first_num = @file[i][0]
			second_num = @file[i][1]
			
			num = [first_num,second_num]

			num.size.times do |j|
				if(counter[num[j]] == nil)
					counter[num[j]] = 1
				else
					counter[num[j]] = counter[num[j]] + 1
				end
			end
		end

		# 入出リンク数が最大のものを取り出す
		max = counter.max { |a, b| a[1] <=> b[1] }

		# リストからシードページを削除
		$pageList.delete(max[0])
		
		return max
	
	end
	
	# seedページから初期セットの作成
	def make_InitialSet(seedPage)
		
		# SeedPage
		list = [seedPage[0]]
		# 初期セットの隣接行列
		@matrix = Hash.new { |h,k| h[k] = {} }
		# ページにつけられる番号
		@number = Hash.new   
		# ページごとの番号
		@num = 0	
		# 一時的に追加するようの変数
		initialSetList = Array.new

		@file.size.times do |i|

			first_num = @file[i][0]
			second_num = @file[i][1]

			list.size.times do |i|
				if list[i].to_s == first_num || list[i].to_s == second_num
					
					if(@number[first_num] == nil)
						@number[first_num] = @num
						@num += 1
						initialSetList.push(first_num)
					end
					
					if(@number[second_num] == nil)
						@number[second_num] = @num
						@num += 1
						initialSetList.push(second_num)
					end

					@matrix[@number[first_num]][@number[second_num]] = 1

					break
				end
			end
			
		end

		# 初期セットのサイズが100以下の時
		for i in initialSetList do
			$pageList.delete(i)
			eval("$cluster#{$num}").push(i)
		end

		#File.write("output1.txt",@cluster)

		@file.size.times do |i|

			first_num = @file[i][0]
			second_num = @file[i][1]
				
			list.size.times do |i|
				if @number.include?("#{first_num}") && @number.keys.include?("#{second_num}")
					if list[i].to_s != first_num && list[i].to_s != second_num
				
						@matrix[@number[first_num]][@number[second_num]] = 1

						break
					end
				end
			end
		end

		return @matrix

	end

	def add_page(page)

		list = [page]

		@file.size.times do |i|

			first_num = @file[i][0]
			second_num = @file[i][1]

			list.size.times do |i|
				if list[i].to_s == first_num || list[i].to_s == second_num
					
					if(@number[first_num] == nil)
						@number[first_num] = @num
						@num += 1
						eval("$cluster#{$num}").push(first_num)
						$pageList.delete(first_num)
					end
					
					if(@number[second_num] == nil)
						@number[second_num] = @num
						@num += 1
						eval("$cluster#{$num}").push(second_num)
						$pageList.delete(second_num)
					end

					#@matrix[@number[first_num]][@number[second_num]] = 1
					#break
				end
			end
		end

	end

	# 初期ベクトル作成
	def make_init
		Array.new(@number.size,1) #[1,1,1,1,1]
	end

	# 隣接行列作成(正規化)
	def make_matrix(list)

		@dim = @number.size
		@a = []
		@outLinks = []
		@inLinks = []

		@dim.times do |i|
			#ランダム遷移行列を各出リンク数で割った値を格納
			@a[i] = [] # p[0],p[1],p[2],p[3]
			@dim.times do |j|
				if(list[i][j] != nil) 
					#値に対して出リンク数で割る
					#例 [0,0,1/2,1/2]
					@a[i][j] = list[i][j] * 1.0 / list[i].count * 1.0
				else
					@a[i][j] = 0	
				end
			end
			@outLinks[i] = list[i].count
		end

		@listTranspose = @a.transpose

		@dim.times do |i|

			inCount = 0

			@dim.times do |j|
				if(@listTranspose[i][j] != 0)
					inCount += 1
				end
			end
			@inLinks[i] = inCount
		end

		#puts @outLinks
		#puts @inLinks
	end

	# 権威行列作成
	def make_ataMatrix

		@ata = Array.new(@dim){Array.new(@dim,0)}

		# @dim.times do |i|
		# 	if @listTranspose[i].inject(:+) != 0 
		# 		@dim.times do |j|
				
		# 				@ata[i][j] = (Vector.elements(@listTranspose[i]).inner_product(Vector.elements(@listTranspose[j])))

		# 		end
		# 	else
		# 		@ata[i].fill(0)

		# 	end
		# end

		@dim.times do |i|
			if @listTranspose[i].inject(:+) != 0 
				@dim.times do |j|
					if @listTranspose[j].inject(:+) != 0 
						@dim.times do |k|
								@ata[i][j] += @listTranspose[i][k] * @listTranspose[j][k]
						end
					end
				end
			end
		end
	end

	# 権威スコア計算
	def calc_authority(curr)
		15.times do #試験的に15回
			prev = curr.clone
			sum = 0
			line = []

			@dim.times do |i|
				line[i] = 0
				@dim.times do |j|
					line[i] += @ata[i][j] * prev[j]
				end
				sum += line[i]
				curr[i] = line[i]

			end
			
			@dim.times do |k|
				curr[k] = (curr[k] / sum)
			end

		end

		return curr
	end

	# ハブスコア計算
	def calc_hub(matrix)
		sum = 0
		line = []
		@dim.times do |i|
			line[i] = 0
			@dim.times do |j|
				line[i] += @a[i][j] * matrix[j]
			end
			sum += line[i]
		end

		@dim.times do |k|
			line[k] = (line[k] / sum)
		end
		return line
	end

	def calc_NewScore(matrix, isAuthority)

		newScore = Array.new

		matrix.size.times do |i|
			if(matrix[i] != 0)
				if(isAuthority)
					newScore[i] = matrix[i] * 1.0 / @inLinks[i] * 1.0
				else
					newScore[i] = matrix[i] * 1.0 / @outLinks[i] * 1.0
				end
			else
				newScore[i] = 0
			end
		end

		return newScore
	end

	def print_matrix
		puts "-----------------"
		puts "list"
		puts @number

		# puts "-----------------"
		# puts "matrix"
		# p @a
	end

	# 下の2つは1つにまとめる
	def sort_aRanking(score)
		@aRank = Hash.new
		score.size.times do |i|
			@aRank[@number.key(i)] = score[i]
		end

		return @aRank.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }		
	end

	def find_maxAuthority(sortScore)

		maxAuthority = sortScore.max { |a, b| a[1] <=> b[1] }
		sortScore.shift

		if(maxAuthority[1] > 0.01)
			return maxAuthority[0]
		else
			return nil
		end
	end

	def sort_hRanking(score)
		@hRank = Hash.new
		score.size.times do |i|
			@hRank[@number.key(i)] = score[i]
		end

		return @hRank.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }		
	end

	def find_maxHub(sortScore)
		
		maxHub = sortScore.max { |a, b| a[1] <=> b[1] }
		sortScore.shift

		if(maxHub[1] > 0.01)
			return maxHub[0]
		else
			return nil
		end
	end

	def print_cluster()

		$num.times do |i|
			p eval("$cluster#{i}")
			puts "clusterSize"
			puts eval("$cluster#{i}").size
		end

		#File.write("cluster.txt",@cluster)
	end
	
end

result = Benchmark.realtime do
	
	# SALSAインスタンス作成
	salsa = SALSA.new

	# 全ページのリスト
	$pageList = salsa.make_List()

	$num = 0

	#while  true
		if($pageList.size != 0)
		
			# 1.Seedページの決定
			seedPage = salsa.find_SeedPage()

			# cluster初期化
			eval("$cluster#{$num} = Array.new") 

			# 2.seedページから初期セット作成
			InitialSet = salsa.make_InitialSet(seedPage)
			
			# 初期ベクトル定義
			init = salsa.make_init()

			# 隣接行列
			salsa.make_matrix(InitialSet)

			# 権威行列
			salsa.make_ataMatrix()
			
			# 3.各SALSAスコア計算
			aScore = salsa.calc_authority(init)
			hScore = salsa.calc_hub(aScore)

			# 4.各SALSAスコア再計算
			aNewScore = salsa.calc_NewScore(aScore,true)
			hNewScore = salsa.calc_NewScore(hScore,false)

			# 各スコアをソード
			aScoreSort = salsa.sort_aRanking(aNewScore)
			hScoreSort = salsa.sort_hRanking(hNewScore)	

			aScoreSortOutput = aScoreSort.clone
			hScoreSortOutput = hScoreSort.clone

			# 各スコア最大値のページを抽出
			# 6.最大スコアのページから距離1のページを追加
			# 7.閾値を下回ったら終了
			while true
				maxAuthorityPage = salsa.find_maxAuthority(aScoreSort)
				if(maxAuthorityPage != nil)
					salsa.add_page(maxAuthorityPage)
				end

				maxHubPage = salsa.find_maxHub(hScoreSort)
				if(maxHubPage != nil)
					salsa.add_page(maxHubPage)
				end

				if(maxAuthorityPage == nil && maxHubPage == nil)
					break
				end
			end

			$num += 1

		else
			break
		end
	#end

	# 出力
	puts "-----------------"
	puts "SeedPage"
	p seedPage

	salsa.print_matrix

	puts "-----------------"
	puts "SALSA_Authority_score"
	p aScore

	puts "-----------------"
	puts "SALSA_NewAuthority_score"
	p aNewScore

	puts "-----------------"
	puts "authority Ranking"
	p aScoreSortOutput

	puts "-----------------"
	puts "SALSA_Hub_score"
	p hScore

	puts "-----------------"
	puts "SALSA_NewHub_score"
	p hNewScore

	puts "-----------------"
	puts "hub Ranking"
	p hScoreSortOutput

	puts "-----------------"
	puts "cluster"
	salsa.print_cluster

	puts "pagelistSize"
	puts $pageList.size

end

puts "-----------------"
puts "処理時間 #{result}s"