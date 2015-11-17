class Stack

	def initialize
	    @index = 0  
	    @s = []
	end

	def push(e)
	    @s[@index] = e
	    @index +=1
	end

	def pop
	    @index -= 1
	    return @s[@index]
	end

end

i = 0
s = Stack.new

while i < ARGV.size do 
	s.push(ARGV[i])
	i+=1
end

i = 0
while i < ARGV.size do
	puts s.pop
	i+=1
end