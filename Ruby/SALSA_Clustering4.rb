require 'benchmark'
require 'matrix'
require_relative './calcFinalScore2.rb'

class SALSA

	def make_List
		#puts "make_List"

		# ファイルの内容を格納
		@file = []
		x = 0

		File.open(ARGV[0]){|file|
			file.each_line do |line|
				
				first_num,second_num = line.chomp!.split(",")
				@file[x] = [first_num,second_num]
				x += 1
			end
		}

		puts "-----最初のファイル------"
		puts "@file"
		p @file
		puts "--------------"
		puts "@file.size"
		puts @file.size

		return @file.size	
	end

	# 入出リンク数が最大のものをSeedPageに
	def find_SeedPage
		#puts "find_SeedPage"

		# ページ数カウント用
		counter = Hash.new

		@file.each do |num|
				
			# i[0]:first_num
			# i[1]:second_num
			
			num.each do |i|
				if(counter[i] == nil)
					counter[i] = 1
				else
					counter[i] = counter[i] + 1
				end
			end
		end

		# 入出リンク数が最大のものを取り出す
		max = counter.max { |a, b| a[1] <=> b[1] }
		
		return max	
	end
	
	# seedページから初期セットの作成
	def make_InitialSet(seedPage)
		#puts "make_InitialSet"
		
		# SeedPageのページ番号
		list = seedPage[0]
		# 初期セットの隣接行列
		@matrix = Hash.new { |h,k| h[k] = {} }
		# ページにつけられる番号
		@number = Hash.new   
		# ページごとの番号
		@num = 0	
		# 一時的に追加するようの変数
		initialSetList = Array.new

		count = -1

		isHit = false

		@linkCount = 0

		@file.reverse_each do |num|

			first_num = num[0]
			second_num = num[1]

			num.each do |i|
				if list.to_s == first_num || list.to_s == second_num
					
					if(@number[first_num] == nil)
						@number[first_num] = @num
						@num += 1
						initialSetList.push(first_num)
						isHit = true
					end
					
					if(@number[second_num] == nil)
						@number[second_num] = @num
						@num += 1
						initialSetList.push(second_num)
						isHit = true
					end

					@matrix[@number[first_num]][@number[second_num]] = 1
					
					break
				end
			end	

			# ここでseedとリンク関係にある行を消去
			if(isHit)
				#@file.delete(num)
				@file.delete_at(count)
				@linkCount += 1
				isHit = false
			else
				count -= 1
			end		
		end

		puts "-------ファイルからシードと関係のあるの消去-------"
		puts "@file"
		p @file
		puts "--------------"
		puts "@file.size"
		puts @file.size

		# 初期セットのサイズが100以下の時
		for i in initialSetList do
			eval("$cluster#{$num}").push(i)
		end

		#File.write("output1.txt",@cluster)

		count = -1

		@file.reverse_each do |num|

			first_num = num[0]
			second_num = num[1]
				
			num.each do |i|
				if @number.include?("#{first_num}") && @number.keys.include?("#{second_num}")
					if i[0].to_s != first_num && i[1].to_s != second_num
				
						@matrix[@number[first_num]][@number[second_num]] = 1
						isHit = true

						break
					end
				end
			end

			if(isHit)
				#@file.delete(num)
				@file.delete_at(count)
				@linkCount += 1
				isHit = false
			else
				count -= 1
			end	
		end

		puts "-------初期セット同士の行を消去-------"
		puts "@file"
		p @file
		puts "--------------"
		puts "@file.size"
		puts @file.size

		@firstDensity = @linkCount.to_f / @number.size.to_f

		return @matrix
	end

	def return_matrix
		return @matrix
	end

	# 初期ベクトル作成
	def make_init
		#puts "make_init"
		Array.new(@number.size,1) #[1,1,1,1,1]
	end

	# 隣接行列作成(正規化)
	def make_matrix(list)
		#puts "make_matrix"

		@dim = @number.size
		@a = []
		@lr = []
		@lc = []

		@outLinks = []
		@inLinks = []

		@dim.times do |i|
			@a[i] = []
			@lr[i] = []
			@dim.times do |j|
				if(list[i][j] != nil) 
					@a[i][j] = list[i][j] * 1.0
					@lr[i][j] = list[i][j] * 1.0 /list[i].count * 1.0
				else
					@a[i][j] = 0	
					@lr[i][j] = 0
				end
			end
			@outLinks[i] = list[i].count
		end

		# 権威スコア計算用の転置行列作成
		@lrt = @lr.transpose

		# 入リンク数をカウント
		@dim.times do |i|

			inCount = 0

			@dim.times do |j|
				if(@lrt[i][j] != 0)
					inCount += 1
				end
			end
			@inLinks[i] = inCount
		end

		# 正規化
		@dim.times do |i|
			@lc[i] = []
			@dim.times do |j|
					if(@inLinks[j] != 0)
						@lc[i][j] = @a[i][j] / @inLinks[j]
					end
					
					if(@lc[i][j] == nil)
						@lc[i][j] = 0
					end
			end
		end

	end

	# 権威行列作成
	def make_ataMatrix

		@ata = Array.new(@dim){Array.new(@dim,0)}

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

	def make_initialAuthorityScore(init)
		
		@initialAuthorityScore = []
		@initialHubScore = init
		sum = 0
		
		@dim.times do |i|
			@initialAuthorityScore[i] = 0
			@dim.times do |j|
				if(@lrt[i][j] != 0)
					@initialAuthorityScore[i] += @lrt[i][j] * @initialHubScore[j]
				end
			end
			sum += @initialAuthorityScore[i]
		end

		@dim.times do |k|
			@initialAuthorityScore[k] = @initialAuthorityScore[k] / sum
		end

		return @initialAuthorityScore

	end

	# 権威スコア計算
	def calc_authority(curr)

		15.times do #試験的に15回
			prev = curr.clone
			sum = 0
			line = []
			@authorityScore = []

			# A = Lc * x(k-1)
			@dim.times do |i|
				line[i] = 0
				@dim.times do |j|
					line[i] += @lc[i][j] * prev[j]
				end
			end

			# LrT * A
			@dim.times do |i|
				@authorityScore[i] = 0
				@dim.times do |j|
					@authorityScore[i] += @lrt[i][j] * line[j]
				end
				sum += @authorityScore[i]
			end
			
			# 正規化
			@dim.times do |k|
				@authorityScore[k] = (@authorityScore[k] / sum)
			end

			curr = @authorityScore

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
				if(@inLinks[j] != 0)
					line[i] += @lc[i][j] * matrix[j]
				end

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

		@density = @linkCount.to_f / @number.size.to_f

		if(maxAuthority != nil)
			#if(maxAuthority[1] > $threshold)
			if(@density  >= @firstDensity)
			#if(@density >= 0.01)
				return maxAuthority[0]
			else
				return nil
			end
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

		@density = @linkCount.to_f / @number.size.to_f

		if(maxHub != nil)
			#if(maxHub[1] > $threshold)
			if(@density >= @firstDensity)
			#if(@density >= 0.01)
				return maxHub[0]
			else
				return nil
			end
		end
	end

	def add_page(page)
		#puts "add_page"

		list = [page]
		isHit = false
		count = -1
		@addList = Array.new

		@file.reverse_each do |num|

			first_num = num[0]
			second_num = num[1]

			if list[0].to_s == first_num || list[0].to_s == second_num
				
				if(@number[first_num] == nil)
					@number[first_num] = @num
					@num += 1
					eval("$cluster#{$num}").push(first_num)
					@addList.push(first_num)
					isHit = true
				end
				
				if(@number[second_num] == nil)
					@number[second_num] = @num
					@num += 1
					eval("$cluster#{$num}").push(second_num)
					@addList.push(second_num)
					isHit = true
				end

				@matrix[@number[first_num]][@number[second_num]] = 1

			end

			if(isHit)
				#@file.delete(num)
				@file.delete_at(count)
				isHit = false
			else
				count -= 1
			end	

		end

		count = -1

		@file.reverse_each do |num|

			first_num = num[0]
			second_num = num[1]
				
			num.each do |i|
				if @number.include?("#{first_num}") && @number.keys.include?("#{second_num}")
					if i[0].to_s != first_num && i[1].to_s != second_num
				
						@matrix[@number[first_num]][@number[second_num]] = 1

						break
					end
				end
			end
		end

		#スコアの高いページとリンク関係にある行を消去
		@file.reverse_each do |num|

			first_num = num[0]
			second_num = num[1]		

			@addList.reverse_each do |i|	

				if i == first_num || i == second_num					
					@file.delete_at(count)
					isHit = true
					break
				end
			end

			if(isHit)
				isHit = false
			else
				count -= 1
			end
		end

		$size = @file.size
	end

	def delete_relationPage

		count = -1
		isHit = false

		#スコアの高いページとリンク関係にある行を消去
		@file.reverse_each do |num|

			first_num = num[0]
			second_num = num[1]		

			eval("$cluster#{$num}").reverse_each do |i|	

				if i == first_num || i == second_num					
					@file.delete_at(count)
					isHit = true
					break
				end
			end

			if(isHit)
				isHit = false
			else
				count -= 1
			end
		end

		puts "-------スコアの高いページとリンク関係にある行を消去-------"
		puts "@file"
		p @file
		puts "--------------"
		puts "@file.size"
		puts @file.size

		$size = @file.size
	end

	def print_cluster()

		$num.times do |i|
			puts "-----------------"
			puts "cluster#{i}"
			#File.write(fileName,eval("$cluster#{i}"))
			p eval("$cluster#{i}")
			puts "clusterSize"
			puts eval("$cluster#{i}").size
		end
	end	

end

result = Benchmark.realtime do
	
	# SALSAインスタンス作成
	salsa = SALSA.new

	# 全ページのリスト
	$size = salsa.make_List()

	$num = 0

	while  true
		if($size != 0)
			# 1.Seedページの決定
			seedPage = salsa.find_SeedPage()

			# cluster初期化
			eval("$cluster#{$num} = Array.new") 

			# 2.seedページから初期セット作成
			initialSet = salsa.make_InitialSet(seedPage)
			
			# 初期ベクトル定義
			init = salsa.make_init()

			# 隣接行列
			salsa.make_matrix(initialSet)

			# 権威行列
			#salsa.make_ataMatrix()

			# 初期ハブスコア作成
			initialAuth = salsa.make_initialAuthorityScore(init)
			
			# 3.各SALSAスコア計算
			aScore = salsa.calc_authority(initialAuth)
			hScore = salsa.calc_hub(aScore)

			# 4.各SALSAスコア再計算
			aNewScore = salsa.calc_NewScore(aScore,true)
			hNewScore = salsa.calc_NewScore(hScore,false)

			# 各スコアをソート
			aScoreSort = salsa.sort_aRanking(aNewScore)
			hScoreSort = salsa.sort_hRanking(hNewScore)	

			# 近似値作成用
			

			# 各スコア最大値のページを抽出
			# 6.最大スコアのページから距離1のページを追加
			# 7.閾値を下回ったら終了
			while true
				# スコア最大のページを取得
				maxAuthorityPage = salsa.find_maxAuthority(aScoreSort)
				if(maxAuthorityPage != nil)
					salsa.add_page(maxAuthorityPage)
				end

				maxHubPage = salsa.find_maxHub(hScoreSort)
				if(maxHubPage != nil)
					salsa.add_page(maxHubPage)
				end

				if(maxAuthorityPage == nil && maxHubPage == nil)

					newMatrix = salsa.return_matrix

					salsa.make_matrix(newMatrix)
					
					init = salsa.make_init()
					
					initialAuth = salsa.make_initialAuthorityScore(init)
					
					aScore = salsa.calc_authority(initialAuth)
					hScore = salsa.calc_hub(aScore)

					aScoreSort = salsa.sort_aRanking(aScore)
					hScoreSort = salsa.sort_hRanking(hScore)

					eval("@aScoreSortOutput#{$num} = aScoreSort.clone")
					eval("@hScoreSortOutput#{$num} = hScoreSort.clone")	

					salsa.delete_relationPage

					break
				end
			end

			$num += 1

		else
			break
		end
	end

	# 近似値の計算
	calcfinalscore()

	#salsa.print_cluster

	# 出力
	# puts "-----------------"
	# puts "SeedPage"
	# p seedPage

	# salsa.print_matrix

	# puts "-----------------"
	# puts "SALSA_Authority_score"
	# p aScore

	# puts "-----------------"
	# puts "SALSA_NewAuthority_score"
	# p aNewScore

	# puts "-----------------"
	# puts "authority Ranking"
	# p @aScoreSortOutput1

	# puts "-----------------"
	# puts "SALSA_Hub_score"
	# p hScore

	# puts "-----------------"
	# puts "SALSA_NewHub_score"
	# p hNewScore

	# puts "-----------------"
	# puts "hub Ranking"
	# p hScoreSortOutput

	#puts "-----------------"
	#puts "cluster"
	

end

puts "-----------------"
puts "処理時間 #{result}s"