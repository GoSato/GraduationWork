class Rank_matrix
  
  def initialize
    @p_surf = 0.8  # リンクを辿る確率
    @url = Hash.new  # urlのリスト
    @all_num = Hash.new  # urlの番号

    #URLのリスト作成と、全部に番号をふる
    File.open(ARGV[0]){ |file|
      i = 0
      #fileから1行ずつ読み込む
      while text = file.gets do
        text = text.chomp!.split('\t ')

        #shit : 配列の最初の要素を排除
        key = text.shift # => text[0]

        #リンク元をキー、リンク先を値にしてハッシュを作成
        @url[key] = text
        @all_num[key] = i
        i += 1

        #puts @url[key]
        #puts key
        #puts @all_num[key]
      end
    }
  end

  def make_matrix
    @url_matrix = Array.new(@url.length)
    @probability = Array.new  # ノードからの遷移確率
    @rank = Array.new  # URLのランク
    @nolink_node = Array.new  # リンクのないノード

    @url.each do |key,v|
      key_no = @all_num[key]
      if v.size == 0 then
        @probability[key_no] = 0
        @nolink_node.push key_no
        next
      end

      #出リンク数で割る
      @probability[key_no] = 1.0 / v.size
      v.each do |url|
        url_no = @all_num[url]
        @url_matrix[url_no] = Array.new if @url_matrix[url_no] == nil
      end
    end
  end

end

a = Rank_matrix.new
a.make_matrix()