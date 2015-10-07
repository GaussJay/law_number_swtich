require 'minitest/autorun'
require 'law_number_switch'

class LawNumberSwitchTest < Minitest::Test
  def test_cn_number_to_number
    assert_equal "112",
      "一百十二".to_number
    assert_equal "112",
      "一百一十二".to_number
    assert_equal "25252",
      "兩萬五千二百五十貳".to_number
    assert_equal "25252",
      "二五兩伍貳".to_number
  end

  def test_cn_number_to_dash_number
    assert_equal "第1手5-5",
      "第一手五之五".to_number
  end

  def test_double_units
    assert_equal "100000000",
      "一萬萬".to_number
    assert_equal "1000000000000",
      "一萬億".to_number
  end

  def test_number_to_cn_number
    assert_equal "二千五百十七",
      "2517".to_cn_number
    assert_equal "二千五百一十七",
      "2517".to_cn_number_oneten
    assert_equal "五萬三千五百三十五",
      "53535".to_cn_number
  end

  def test_dash_number_to_cn_number
    assert_equal "一千億之十萬之十",
      "100000000000-100000-10".to_cn_number
  end

  def test_number_to_cn_number_only
    assert_equal "一二三四五上山打老虎",
      "12345上山打老虎".to_cn_number_only
  end

  def test_capital_number
    assert_equal "伍仟伍佰陸拾陸",
      "5566".to_cn_number_capital
  end
end