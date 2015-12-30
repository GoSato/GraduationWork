require 'benchmark'
require 'matrix'

class SALSA

	def make_List

		@dataSetList = Array.new # dateSet中の全ページのリスト
		@cluster = Array.new

		i = 0

		File.open(ARGV[0]){|file|
			file.each_line do |line|
				first_num,second_num = line.chomp!.split(",")
				@dataSetList[i] = first_num
				@dataSetList[i+1] = second_num
				i += 2
			end
		}

		@dataSetList = @dataSetList.uniq

		return @dataSetList
		
	end

	# 入出リンク数が最大のものをSeedPageに
	def find_SeedPage

		# ページ数カウント用
		counter = Hash.new

		File.open(ARGV[0]){|file|
			file.each_line do |line|
				first_num,second_num = line.chomp!.split(",")
				
				num = [first_num,second_num]

				num.size.times do |i|
					if(counter[num[i]] == nil)
						counter[num[i]] = 1
					else
						counter[num[i]] = counter[num[i]] + 1
					end
				end
			end
		}

		max = counter.max { |a, b| a[1] <=> b[1] }

		# リストからシードページを削除
		@dataSetList.delete(max[0])
		
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

		initialSetList = Array.new

		File.open(ARGV[0]){|file| 
			file.each_line do |line|
				first_num,second_num = line.chomp!.split(",")
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
		}

		# 初期セットのサイズが100以下の時
		initialSetList.each {|i| 
			@dataSetList.delete(i)
			@cluster.push(i)
		}

		#File.write("output.txt",@cluster)

		File.open(ARGV[0]){|file| 

			file.each_line do |line|
				first_num,second_num = line.chomp!.split(",")
				initialSetList.size.times do |i|
					#if (["#{first_num}","#{second_num}"] - @number.keys).empty?
					if initialSetList[i].to_s != first_num && initialSetList[i].to_s != second_num
						@matrix[@number[first_num]][@number[second_num]] = 1
						break
					end	
				end
			end
		
		}

		return @matrix

	end

	def add_page(page)

		list = [page]

		File.open(ARGV[0]){|file| 
			file.each_line do |line|
				first_num,second_num = line.chomp!.split(",")
				list.size.times do |i|
					if list[i].to_s == first_num || list[i].to_s == second_num
						
						if(@number[first_num] == nil)
							@number[first_num] = @num
							@num += 1
							@cluster.push(first_num)
						end
						
						if(@number[second_num] == nil)
							@number[second_num] = @num
							@num += 1
							@cluster.push(second_num)
						end

						@matrix[@number[first_num]][@number[second_num]] = 1

						break
					end
				end
			end
		}

	end

	# 初期ベクトル作成
	def make_init
		Array.new(@number.size,1) #[1,1,1,1,1]
	end

	# 隣接行列作成(正規化)
	def make_matrix(list)

		@dim = @number.size #5
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
							#@ata[i][j] = (vectorX).inner_product(vectorY)
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

		puts "-----------------"
		puts "matrix"
		p @a
	end

	# 下の2つは1つにまとめる
	def sort_aRanking(score,seed)
		@aRank = Hash.new
		score.size.times do |i|
			@aRank[@number.key(i)] = score[i]
		end

		return @aRank.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }		
	end

	def find_maxAuthority(sortScore)

		maxAuthority = sortScore.max { |a, b| a[1] <=> b[1] }
		sortScore.shift

		puts maxAuthority[1]

		if(maxAuthority[1] > 0.01)
			puts maxAuthority[0]
			return maxAuthority[0]
		else
			puts "nil"
			return nil
		end
	end

	def sort_hRanking(score,seed)
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
		p @cluster
		puts @cluster.size
		File.write("cluster.txt",@cluster)
	end
	
end

result = Benchmark.realtime do
	
	# SALSAインスタンス作成
	x = SALSA.new

	dataSet = x.make_List()

	# 1.Seedページの決定
	seedPage = x.find_SeedPage()

	if(dataSet.size != 0)

		# 2.seedページから初期セット作成
		InitialSet = x.make_InitialSet(seedPage)
		
		# 初期ベクトル定義
		init = x.make_init()

		# 隣接行列
		x.make_matrix(InitialSet)

		# 権威行列
		x.make_ataMatrix()
		
		# 3.各SALSAスコア計算
		aScore = x.calc_authority(init)
		hScore = x.calc_hub(aScore)

		# 4.各SALSAスコア再計算
		aNewScore = x.calc_NewScore(aScore,true)
		hNewScore = x.calc_NewScore(hScore,false)

		# 各スコアをソード
		aScoreSort = x.sort_aRanking(aNewScore,seedPage)
		hScoreSort = x.sort_hRanking(hNewScore,seedPage)	

		# 各スコア最大値のページを抽出
		# 6.最大スコアのページから距離1のページを追加
		# 7.閾値を下回ったら終了
		while true

			maxAuthorityPage = x.find_maxAuthority(aScoreSort)
			
			if(maxAuthorityPage != nil)
				puts "maxAuthorityPage"
				puts maxAuthorityPage
				x.add_page(maxAuthorityPage)
			end

			maxHubPage = x.find_maxHub(hScoreSort)
			if(maxHubPage != nil)
				x.add_page(maxHubPage)
			end

			if(maxAuthorityPage == nil && maxHubPage == nil)
				break
			end
		end

	end

	# 出力
	puts "-----------------"
	puts "SeedPage"
	p seedPage

	x.print_matrix

	puts "-----------------"
	puts "SALSA_Authority_score"
	p aScore

	puts "-----------------"
	puts "SALSA_NewAuthority_score"
	p aNewScore

	puts "-----------------"
	puts "authority Ranking"
	p aScoreSort

	puts "-----------------"
	puts "SALSA_Hub_score"
	p hScore

	puts "-----------------"
	puts "SALSA_NewHub_score"
	p hNewScore

	puts "-----------------"
	puts "hub Ranking"
	p hScoreSort

	puts "-----------------"
	puts "cluster"
	x.print_cluster

end

puts "-----------------"
puts "処理時間 #{result}s"