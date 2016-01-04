require 'benchmark'

class PageRank
	ESP = 0.00001

	def initialize
	    @p_surf = 0.8   # リンクを辿る確率
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
		Array.new(@PageSize,1/@PageSize)
	end

	def make_matrix
		@dim = @matrix.size
		@p = []

		@dim.times do |i|
			#ランダム遷移行列を各出リンク数で割った値を格納
			@p[i] = [] # p[0],p[1],p[2],p[3]
			@dim.times do |j|
				#値に対して出リンク数で割る
				#例 [0,0,1/2,1/2]
				@p[i][j] = @matrix[i][j] / ((@matrix)[i].inject(:+) * 1.0)
			end
		end
	end

	def calc(curr,alpha)
		loop do
			prev = curr.clone
			err = 0

			@dim.times do |i|
				ip = 0
				@dim.times do |j|
					ip += @p.transpose[i][j] * prev[j]
				end
				curr[i] = (alpha * ip) + ((1.0 - alpha) / @dim * 1.0)
				err += (prev[i] - curr[i]).abs
			end

			if err < ESP
				return curr
			end
		end
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
	
	alpha = ARGV[1].to_f
	a = PageRank.new
	init = a.make_init()

	a.make_matrix()
	rank = a.calc(init,alpha)

	puts "-----------------"
	puts "alpha : #{alpha}"

	a.print_matrix

	puts "-----------------"
	puts "PageRank_score"
	p rank

end

puts "処理時間 #{result}s"