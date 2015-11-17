# PageRank algorithm
# http://hongo35.hatenablog.com/entry/2013/11/20/004808

class PageRank
	#parameter
	EPS = 0.00001

	def initialize(matrix)
		@dim = matrix.size
		#puts @dim

		@p = []
		@dim.times do |i|
			#pも2次元配列
			#p[i] = [a,b,c,d]
			@p[i] = []
			@dim.times do |j|
				#inject(:+) : 配列の和を求める
				@p[i][j] = matrix[i][j] / (matrix[i].inject(:+) * 1.0)
			end
		end	
	end

	def calc(curr,alpha)
		#loop : 無限ループ
		loop do
			prev = curr.clone

			@dim.times do |i|
				ip = 0
				@dim.times do |j|
					#transpose : 行と列を入れ替える
					ip += @p.transpose[i][j] * prev[j]
				end
				curr[i] = (alpha * ip) + ((1.0 - alpha) / @dim * 1.0)
			end

			err = 0
			@dim.times do |i|
				#abs : 絶対値を求める
				err += (prev[i] - curr[i]).abs
			end

			if err < EPS
				return curr
			end
		end
	end
end

matrix = [[0,0,1,1],[0,0,1,1],[1,1,0,0],[0,1,1,0]]
init = [0.25,0.25,0.25,0.25]

pr = PageRank.new(matrix)

[1.0,0.8,0.5,0].each do |alpha|
	rank = pr.calc(init,alpha)

	puts "-------------"
	puts "alpha: #{alpha}"
	p rank
end

