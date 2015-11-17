#エッジからRandom Surfer Modelを使ったrankを出す。
#因数に与えるファイルはタブ区切りにしています。
class Rank_matrix
  def initialize
    @p_surf = 0.8   # リンクを辿る確率
    @url = Hash.new   # urlのリスト
    @all_num = Hash.new   # urlの番号
 
    # urlのリスト作成と、全部に番号をふる
    File.open(ARGV[0]){|file|
      i = 0
      while text = file.gets do
        text = text.chomp!.split('\t ')
        key = text.shift
        @url[key] = text
        @all_num[key] = i
        i += 1
      end
    }
  end

  def make_matrix
    @url_matrix = Array.new(@url.length)
    @probability = Array.new   # ノードからの遷移確率
    @rank = Array.new   # urlのランク
    @nolink_node = Array.new   # リンクのないノード
    @url.each do |key, v|
      key_no = @all_num[key]
      if v.size == 0 then
        @probability[key_no] = 0
        @nolink_node.push key_no
        next
      end
      @probability[key_no] = 1.0 / v.size
      v.each do |url|
        url_no = @all_num[url]       
        @url_matrix[url_no] = Array.new if @url_matrix[url_no] == nil
        @url_matrix[url_no].push key_no
      end
    end
    @random_surfer = 1.0/@url.length
    @rank.fill(1, 0, @url.length)
 
    # ランクの更新
    20.times{update_rank}
  end
  def update_rank   # ランク更新
    i = 0
    new_rank = Array.new
    all_nolink_rank = 0.0
    link_all = 0.0
 
    # リンクを辿る場合
    @url_matrix.each do |no|
      sum = 0.0
      link_all += @rank[i]
      unless no == nil then
        no.each do |v|
          sum += (@probability[v] * @rank[v]) * @p_surf
        end
      end
      new_rank[i] = sum   # make rank
      i += 1
    end
    @nolink_node.each{|v| all_nolink_rank += @rank[v]}
 
    # 全てのノードにとぶ場合
    new_rank.collect!{|i|
      i += (1 - @p_surf) * @random_surfer * link_all
      i += @p_surf * @random_surfer * all_nolink_rank
    }
    @rank = new_rank   # update rank
  end
  def print_matrix   # 結果の出力
    @url.each do |key, v|
      print key, "\t"
    end
    print "\n"
    @url.each do |key, v|
      key_no = @all_num[key]
      print @rank[key_no], "\t"
    end
    print "\n"
  end
end
 
a = Rank_matrix.new
a.make_matrix
a.print_matrix
 