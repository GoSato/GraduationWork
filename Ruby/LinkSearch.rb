#ruby LinkSearch.rb リンク元URL
#リンク元\t リンク先\t リンク先\t リンク先 が書き込まれる
#書き込む際にURLにhttpを含むかチェックする


require 'rubygems'
require 'hpricot'
#html解析ライブラリ
require 'open-uri'
require 'kconv'
#処理時間計測
require 'benchmark'

result = Benchmark.realtime do
	#コマンドライン引数でリンク元URLを指定
	doc = Hpricot(open(ARGV[0]))
	#num = 1

	#リンク情報を記録
	File.open("RinkListTest.txt", "a") do |file|
		
		#file.print "["
		#file.print "#{num}"
		#file.print "] "

		#リンク元URLを先頭に書き込む
		file.print ARGV[0]

		(doc/'a').each { |e|
			s = e.inner_html.toutf8.gsub(/<.*?>/,'')
			next if s == nil || s == ''
			link = e.attributes['href']
			if(link.size != 0 && link.include?("http")) 
				
				file.print '\t '
				#リンク先URL
				file.print link
				#num += 1
			end
		}
		file.print "\n"
	end
end

puts "処理時間 #{result}s"
