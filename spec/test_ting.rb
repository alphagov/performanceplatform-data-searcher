$:.unshift File.join(File.dirname(__FILE__),'..','lib','ppdatasearcher')

require 'test/unit'
require 'ting'

class TestTing < Test::Unit::TestCase
  
  def setup
  end
  
  def teardown
  end
  
  def test_nil_value
    assert_equal ["null", "metric"], Ting.new.wassup(nil)
  end
  
  def test_float_greater_than_one
    assert_equal ["decimal", "metric"], Ting.new.wassup(4.5)
  end
  
  def test_float_less_than_one
    assert_equal ["decimal", "metric"], Ting.new.wassup(0.50234)
  end
  
  def test_integer_as_float
    assert_equal ["integer_decimal", "metric"], Ting.new.wassup(2.00000)
  end
  
  def test_integer
    assert_equal ["integer", "metric"], Ting.new.wassup(12345)
  end
  
  def test_negative_integer
    assert_equal ["integer", "metric"], Ting.new.wassup(-12345)
  end
  
  def test_zero_integer
    assert_equal ["integer", "metric"], Ting.new.wassup(0)
  end
  
  def test_zero_float_as_integer
    assert_equal ["integer_decimal", "metric"], Ting.new.wassup(0.0)
  end
  
  def test_integer_as_string
    assert_equal ["string_integer", "metric"], Ting.new.wassup("1")
  end
  
  def test_octal_as_string
    assert_equal ["string_octal", "metric"], Ting.new.wassup("01465")
  end
  
  def test_hex_as_string
    assert_equal ["string_hex", "metric"], Ting.new.wassup("0x1465A2")
  end
  
  def test_binary_as_string
    assert_equal ["string_binary", "metric"], Ting.new.wassup("0b01101101")
  end
  
  def test_float_as_string
    assert_equal ["string_decimal", "metric"], Ting.new.wassup("12.543")
  end
  
  def test_integer_float_as_string
    assert_equal ["string_integer_decimal", "metric"], Ting.new.wassup("12.000")
  end
  
  def test_date_time_with_offset
    assert_equal ["string_date_time","key"], Ting.new.wassup("2014-01-01T23:12:34+00:00")
  end
  
  def test_date_time_with_default_offset
    assert_equal ["string_date_time","key"], Ting.new.wassup("2014-01-01T23:12:34Z")
  end
  
  def test_invalid_date_time_with_default_offset
    assert_equal ["string","dimension"], Ting.new.wassup("2014-01-01 23:12:34Z")
  end
  
  def test_invalid_date_time_with_misformed_offset
    assert_equal ["string","dimension"], Ting.new.wassup("2014-01-01T23:12:34/00:00")
  end
  
  def test_time_duration
    assert_equal ["string_time_duration","metric"], Ting.new.wassup("23:12:34")
  end
  
  def test_long_time_duration
    assert_equal ["string_time_duration","metric"], Ting.new.wassup("99:99:99")
  end
  
  def test_bad_time_duration
    assert_equal ["string","dimension"], Ting.new.wassup("199:99:99")
  end
  
  def test_short_version_number
    assert_equal ["string_integer_decimal", "metric"], Ting.new.wassup("1.0")
  end
  
  def test_longer_version_number
    assert_equal ["string_version_number","pseudo-dimension"], Ting.new.wassup("1.0.1")
  end
  
  def test_long_version_number
    assert_equal ["string_version_number","pseudo-dimension"], Ting.new.wassup("1.0.1.1")
  end
  
  def test_bad_version_number
    assert_equal ["string","dimension"], Ting.new.wassup("a.a.1")
  end
  
  def test_base64_encoded
    assert_equal ["string_base64_encoded","key"], Ting.new.wassup("YnJvd3Nlci11c2FnZV8yMDE0MDkyOTAwMDAwMF93ZWVrX0FuZHJvaWQgQnJvd3Nlcg==",false)
  end
  
  def test_another_base64_encoded
    assert_equal ["string_base64_encoded","key"], Ting.new.wassup("MjAxNS0wMy0xN1QwMDowMDowMFouZGF5LmFsbC11c2Vycy5lbWFpbC12ZXJpZmljYXRpb24=",false)
  end
  
  def test_should_not_be_base64_encoded
    assert_equal ["string","dimension"], Ting.new.wassup("YnJvd3Nlci11c2FnZV8yMDE0MDkyOTAwMDAwMF93ZWVrX0FuZHJvaWQgQnJvd3Nlcg=",false)
  end
  
  def test_not_base64_encoded
    assert_equal ["string","dimension"], Ting.new.wassup("browser-usage_20140929000000_week_Android Browser",false)
  end
  
  def test_false_positive_base64_encoded
    assert_equal ["string_base64_encoded","key"], Ting.new.wassup("week",false)
  end
  
  def test_exclude_false_positive_base64_encoded
    assert_equal ["string","dimension"], Ting.new.wassup("week",true)
  end
  
  def test_string
    assert_equal ["string","dimension"], Ting.new.wassup("0b.Dave")
  end
  
end
    
    