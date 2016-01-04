require 'benchmark'

class SALSA

	def initialize
	    @url = Hash.new   # urlのリスト
	    @all_num = Hash.new   # urlの番号

	    # urlのリスト作成と、全部に番号をふる
	    File.open(ARGV[0]){|file|  
		    i = 0  # URLごとにナンバリング
		    j = 0  # 行番号用
		    @PageSize = File.readlines(ARGV[0]).size
		    @matrix = Array.new(@PageSize){Array.new(@PageSize,0)}
		    
		    while text = file.gets do
		        text = text.chomp!.split('\t ')
		        size = text.size  #=> 3
		        key = text.shift
		        @url[key] = text  # リンク元をキー、リンク先を値に

		        # ループ処理
		        for num in 1..size do
		          
		          	# まだナンバリングされていなかったらリンクに番号をふる
		          	if(@all_num[key] == nil)
		            	@all_num[key] = i
		            	i += 1
		          	end

		          	# ループ1週目に自分の行番号を保持
		          	if(num == 1)
	            		j = @all_num[key]
	            	end
		          	
		          	# リンク先に対して配列を1に
		          	if(j != @all_num[key])
		            	@matrix[j][@all_num[key]] = 1
		            end

		          	if(text != nil)
		            	key = text.shift
		          	end
		        end
		    end
	    }
	end

	def make_init
		Array.new(@PageSize,1) #[1/4,1/4,1/4,1/4]
	end

	def make_matrix
		@dim = @matrix.size #4
		@a = []

		@dim.times do |i|
			#ランダム遷移行列を各出リンク数で割った値を格納
			@a[i] = [] # p[0],p[1],p[2],p[3]
			@dim.times do |j|
				#値に対して出リンク数で割る
				#例 [0,0,1/2,1/2]
				@a[i][j] = @matrix[i][j] / ((@matrix)[i].inject(:+) * 1.0)
			end
		end
	end

	def make_ataMatrix
		@ata = Array.new(@PageSize){Array.new(@PageSize,0)}

		@dim.times do |i|
			@dim.times do |j|
				@dim.times do |k|
					@ata[i][j] += @a.transpose[i][k] * @a[k][j]
				end
				k = 0
			end
		end
	end

	def calc_authority(curr)
		15.times do #試験的に15回
			prev = curr.clone
			err = 0
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
				curr[k] = curr[k] / sum
			end

		end
		return curr
	end

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
			line[k] = line[k] / sum
		end
		return(line)
	end

	def print_matrix
		puts "-----------------"
		puts "matrix"
		p @matrix

		puts "-----------------"
		puts "list"
		puts @all_num
	end
	
end

result = Benchmark.realtime do
	
	x = SALSA.new
	init = x.make_init()

	x.make_matrix()
	x.make_ataMatrix()
	aRank = x.calc_authority(init)
	hRank = x.calc_hub(aRank)

	x.print_matrix

	puts "-----------------"
	puts "SALSA_Authority_score"
	p aRank

	puts "-----------------"
	puts "SALSA_Hub_score"
	p hRank

end

puts "-----------------"
puts "処理時間 #{result}s"