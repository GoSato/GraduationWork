class PageRank
	ESP = 0.00001

	def initialize(matrix)
		@dim = matrix.size # => 4
		@p = []

		@dim.times do |i|
			#ランダム遷移行列を各出リンク数で割った値を格納
			@p[i] = [] # p[0],p[1],p[2],p[3]
			@dim.times do |j|
				#値に対して出リンク数で割る
				#例 [0,0,1/2,1/2]
				@p[i][j] = matrix[i][j] / ((matrix)[i].inject(:+) * 1.0)
				#puts matrix[i][j]
				#puts @p[i][j]
			end
		end
	end

	def calc(curr,alpha)
		#curr <= init
		loop do
			prev = curr.clone

			@dim.times do |i|
				ip = 0
				@dim.times do |j|
					ip += @p.transpose[i][j] * prev[j]
				end
				curr[i] = (alpha * ip) + ((1.0 - alpha) / @dim * 1.0)
			end

			err = 0
			@dim.times do |i|
				err += (prev[i] - curr[i]).abs
			end

			if err < ESP
				return curr
			end
		end
	end
end

#ランダム遷移行列
matrix = [[0,0,1,1],
		  [0,0,1,1],
		  [1,1,0,0],
		  [0,1,1,0]]

#均一分布行列
init = [0.25,0.25,0.25,0.25]

#pr = PageRank.new(matrix)

alpha = ARGV[0].to_f
#puts alpha.to_f

pr = PageRank.new(matrix)

rank = pr.calc(init,alpha)

puts "-----------------"
puts "alpha : #{alpha}"
p rank