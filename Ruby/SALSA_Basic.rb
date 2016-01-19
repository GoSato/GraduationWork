require 'benchmark'
require 'matrix'

class SALSA

	$rankingSize = 50
	
	# rootsetからbasesetを作成
	def extraction

		# rootset
		
		list = [1,2295,2498,6485,191,462,373,958,391,396,414,1034,2979,3202,5672,6866,6894,7522,7874,7916,8492,9978,565,848,8555,957,1162,1215,2061,3173]

		# basesetでの隣接行列
		matrix = Hash.new { |h,k| h[k] = {} }
		# ノードにつけられる番号
		@number = Hash.new   
		# ページごとの番号
		num = 0	

		File.open(ARGV[0]){|file| 
			file.each_line do |line|
				
				first_num,second_num = line.chomp!.split(",")
				
				list.size.times do |i|
					if list[i].to_s == first_num || list[i].to_s == second_num
						
						if(@number[first_num] == nil)
							@number[first_num] = num
							num += 1
						end
						
						if(@number[second_num] == nil)
							@number[second_num] = num
							num += 1
						end

						matrix[@number[first_num]][@number[second_num]] = 1

						break
					end
				end
			end
		}

		File.open(ARGV[0]){|file| 

			file.each_line do |line|
				
				first_num,second_num = line.chomp!.split(",")
				
				list.size.times do |i|
					if @number.keys.include?("#{first_num}") && @number.keys.include?("#{second_num}")
						if list[i].to_s != first_num && list[i].to_s != second_num
					
							matrix[@number[first_num]][@number[second_num]] = 1

							break
						end
					end
				end
			end
		
		}

		return matrix

	end

	# 初期ベクトル作成
	def make_init
		Array.new(@number.size,1) #[1,1,1,1,1]
	end

	# 隣接行列作成(正規化)
	def make_matrix(list)

		@dim = @number.size 
		@a = [] #隣接行列
		@lr = [] #出リンク数で正規化
		@lc = [] #入リンク数で正規化
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
			if @lrt[i].inject(:+) != 0 
				@dim.times do |j|
					if @lc[j].inject(:+) != 0 
						@dim.times do |k|
							if(@inLinks[k] != 0)
								#@ata[i][j] += @listTranspose[i][k] * @listTranspose[j][k]
								@ata[i][j] += @lrt[i][k] * @lc[j][k]
							end
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

	def print_matrix
		puts "-----------------"
		puts "list"
		p @number.keys
		puts "list size"
		puts @number.size


		puts "-----------------"
		30.times do |i|
			print @number.keys[i].to_i
			puts ","
		end

		# puts "-----------------"
		# puts "matrix"
		# p @a
	end

	# 下の2つは1つにまとめる
	def print_aRanking(score)
		aRank = Hash.new
		score.size.times do |i|
			aRank[@number.key(i)] = score[i]
		end
		puts "-----------------"
		puts "authority Ranking"
		puts "-----------------"
		p aRank.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }
		aRank = aRank.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }
		$rankingSize.times do |j|
			print aRank[j][0].to_i
			puts ","
		end
	end

	def print_hRanking(score)
		hRank = Hash.new
		score.size.times do |i|
			hRank[@number.key(i)] = score[i]
		end
		puts "-----------------"
		puts "hub Ranking"
		puts "-----------------"
		p hRank.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }
		hRank = hRank.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }
		$rankingSize.times do |j|
			print hRank[j][0].to_i
			puts ","
		end
	end
	
end

result = Benchmark.realtime do
	
	# SALSAインスタンス作成
	x = SALSA.new

	# rootsetからbaseset抽出
	extractionList = x.extraction()
	
	# 初期ベクトル定義
	init = x.make_init()

	# 隣接行列
	x.make_matrix(extractionList)
	
	# # 権威行列
	# x.make_ataMatrix()

	initialAuth = x.make_initialAuthorityScore(init)
	
	# 各スコア計算
	aScore = x.calc_authority(initialAuth)
	hScore = x.calc_hub(aScore)

	# 出力
	x.print_matrix

	puts "-----------------"
	puts "SALSA_Authority_score"
	p aScore

	puts "-----------------"
	puts "SALSA_Hub_score"
	p hScore

	x.print_aRanking(aScore)
	x.print_hRanking(hScore)	

end

puts "-----------------"
puts "処理時間 #{result}s"