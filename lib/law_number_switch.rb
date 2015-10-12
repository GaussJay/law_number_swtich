module LawNumberSwitch
  CN_NUMBER = ["", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十" ]
  CN_UNIT = ["", "十", "百", "千" ]
  CN_UNIT_BIG = ["", "萬", "億", "兆" ]

  def to_cn_number
    self.to_cn_number_oneten.gsub(/一十/, '十')
  end

  def to_cn_number_capital
    self.to_cn_number.tr('一二三四五六七八九十百千', '壹貳參肆伍陸柒捌玖拾佰仟')
  end

  def to_cn_number_only
    output = ''
    self.split('').each do |num|
      output += num.to_cn_number_oneten
    end
    output
  end

  def to_cn_number_oneten
    output = ''
    string = ''
    self.scan(/./).each do |char|
      if char =~ /\d/ || char == '-'
        string += char
      else
        char = string.to_cn_number_judge + char unless string.empty?
        output += char
        string = ''
      end
    end
    output += string.to_cn_number_judge unless string.empty?
    output
  end

  def to_cn_number_judge
    self =~ /-/ ? dash_words : int_words
  end

  def int_words
    return '零' if self == '0'
    return self if self.length > 16
    num_arr = self.split('').reverse
    cn_num_arr = []
    write = -1 
    #1： 都需要寫；
    #0： 寫一個零，後面的千不用寫； 
    #-1：不需要寫千，也不需要寫零；
    num_arr.each_with_index do |value, index|
      write = -1 if index % 4 == 0
      unit_big = (index % 4 == 0) ? CN_UNIT_BIG[index / 4] : ""
      number = CN_NUMBER[value.to_i]
      if value.to_i == 0
        unit = (write == 1) ? "零" : ""
        write = (write == 1) ? 0 : -1
      else
        unit = CN_UNIT[index % 4]
        write = 1
      end
      cn_num_arr << number + unit + unit_big
    end
    string = cn_num_arr.reverse.join

    CN_UNIT_BIG.each_with_index do |char, index|
      position = string.index(char)
      if index > 0 && position != nil && string[position - 1] == CN_UNIT_BIG[index + 1]
        string[position] = ''
        # case: successive units
      end
    end
    string
  end

  def dash_words
    return '負' if self == '-'
    output = ''
    self.split('-').each do |part|
      output += part.to_cn_number_oneten + '之'
    end
    self[0] == '-' ? output = output.sub(/之/, '負') : output
    self[-1] == '-' ? output : output.chop
  end

  CN_NUMS = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九"]
  CN_DECS = ["十", "百", "千", "萬", "億", "兆", "拾", "佰", '仟']
  CN_NUMS_MAP = {'〇' => 0,  '○' => 0, '一' => 1, '二' => 2, '兩' => 2, '三' => 3, '四' => 4,
    '五' => 5, '六' => 6, '七' => 7, '八' => 8, '九' => 9, '零' => 0, '壹' => 1, '貳' => 2, 
    '參' => 3, '肆' => 4, '伍' => 5, '陸' => 6, '柒' => 7, '捌' => 8, '玖' => 9}
  CN_DECS_MAP = {'個' => 1, '十' => 10, '百' => 100, '千' => 1000, '萬' => 10000, 
    '億' => 100000000, '兆' => 100000000000, '拾' => 10, '佰' => 100, '仟' => 1000}

  def to_number
    output = ''
    string = ''
    self.scan(/./) do |char|
      if CN_NUMS_MAP[char] || CN_DECS_MAP[char] || char == '之'
        string += char
      else
        char = string.to_number_judge + char unless string.empty?
        output += char
        string = ''
      end
    end
    output += string.to_number_judge unless string.empty?
    output
  end

  def to_number_only
    number_only = ''
    self.scan(/./) do |char|
      if char == '之'
        number_only += "-"
      else
        number_only += CN_NUMS_MAP[char].to_s
      end
    end
    number_only
  end

  def to_number_judge
    return '之' if self == '之'
    non_unit = 0
    string = self.gsub(/(?:○|〇)/, "零").gsub(/(?:零|○|〇)(?:十|拾)/, "一十")
      .gsub(/廿/, "二十").gsub(/卅/, "三十") 
    CN_DECS.each do |dec|
      no_ten = dec + "(?:十|拾)"
      one_ten = dec + "一十"
      string = string.gsub(Regexp.new(no_ten), one_ten)
      non_unit += 1 if string !~ Regexp.new(dec)
    end
    if non_unit == CN_DECS.length
      string.to_number_only
    elsif string =~ /之/
      string.dash_number
    else
      string.int_number
    end
  end

  def int_number
    num_str = ''
    self.scan(/./) do |char|
      num_str += char if char != '零'
    end
    if num_str =~ /^(?:十|拾)/
      num_str = '一' + num_str
    end

    sums = []
    temp_sum = 0
    last_num = 0
    num_str.scan(/./) do |char|
      if num = CN_NUMS_MAP[char]
        last_num = num
      elsif dec = CN_DECS_MAP[char]
        if dec < 10000
          temp_sum += last_num * dec
        else
          sums.each_with_index do |x, i|
            if x < dec * 10 # case: double units
              sums[i] = x * dec
            else
              break
            end
          end
          temp_sum += last_num
          sums << temp_sum * dec
          temp_sum = 0
        end
        last_num = 0
      else
        next
      end
    end
    sums << temp_sum + last_num

    sum = 0
    sums.each do |num|
      sum += num
    end
    sum.to_s
  end

  def dash_number
    output = ''
    self.split('之').each do |part|
      output += part.to_number + '-'
    end
    self[-1] == '之' ? output : output.chop
  end
end

String.include LawNumberSwitch