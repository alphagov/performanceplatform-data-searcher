class Ting
  
  REGEX_INTEGER = /^[-+]?[1-9]([0-9]*)?$/
  REGEX_BINARY = /^0b[01]+$/
  REGEX_OCTAL = /^0[0-7]+$/
  REGEX_HEX = /^0x[0-9A-Fa-f]+$/
  REGEX_ISO_DATE_TIME = /^([\+-]?\d{4}(?!\d{2}\b))((-?)((0[1-9]|1[0-2])(\3([12]\d|0[1-9]|3[01]))?|W([0-4]\d|5[0-2])(-?[1-7])?|(00[1-9]|0[1-9]\d|[12]\d{2}|3([0-5]\d|6[1-6])))([T]((([01]\d|2[0-3])((:?)[0-5]\d)?|24\:?00)([\.,]\d+(?!:))?)?(\17[0-5]\d([\.,]\d+)?)?([zZ]|([\+-])([01]\d|2[0-3]):?([0-5]\d)?)?)?)?$/
  REGEX_ISO_DURATION = /^(\d{2})\:(\d{2})\:(\d{2})$/
  REGEX_VERSION_NUMBER = /^(?:(\d+)\.)?(?:(\d+)\.)?(?:(\d+)\.)?(\*|\d+)$/
  REGEX_BASE64_ENCODE = /^([A-Za-z0-9+\/]{4})*([A-Za-z0-9+\/]{4}|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{2}==)$/
  
  def initialize
  end
  
  def wassup(ting,exlcude_base64_flag = true)
    
    return "null", "metric" if is_null?(ting)    # check for nil
    return "integer", "metric" if is_integer?(ting)    # check for integer/fixnum
    return "integer_decimal", "metric" if is_integer_float?(ting)    # check whether integer masked as a float
    return "decimal", "metric" if is_float?(ting)    # check if float
    return is_stringy?(ting,exlcude_base64_flag) if ting.is_a?String    #so its a string we hope ... could be something else hiding as a string!!!
    return "unknown", "metric"     # mmmm ... not sourced from json!
    
  end
  
  private
  
  def is_null?(val)
    val.nil?
  end
  
  def is_integer?(val)
    return true if val.is_a?Integer
    val.is_a?Fixnum
  end
  
  def is_integer_float?(val)
    return (val.floor() - val).zero? if val.is_a?Float
    false
  end
  
  def is_float?(val)
    val.is_a?Float
  end
  
  def is_stringy?(number_text,exlcude_base64_flag)
    return "string_integer","metric" if number_text =~ REGEX_INTEGER # decimal
    return "string_binary","metric" if number_text =~ REGEX_BINARY # binary
    return "string_octal","metric" if number_text =~ REGEX_OCTAL # octal
    return "string_hex","metric" if number_text =~ REGEX_HEX # hex
    return "string_integer_decimal","metric" if is_string_integer_float?(number_text) # check integer-decimal
    return "string_decimal","metric" if is_string_float?(number_text) # its a decimal
    return "string_version_number","pseudo-dimension" if is_version_number?(number_text) # this needs to go after check for number strings
    return "string_date_time","key" if is_date_time?(number_text)    # is it iso date_time - ish
    return "string_time_duration","metric" if is_time_duration?(number_text)     # is it iso time duration - ish
    unless exlcude_base64_flag 
      return "string_base64_encoded","key" if is_base_64_encoded?(number_text)     # is it base64 encoded
    end
    return "string","dimension"
  end
  
  def is_string_integer_float?(val)
    true if is_integer_float?(Float(val)) rescue false
  end
  
  def is_string_float?(val)
    true if Float(val) rescue false
  end
  
  def is_date_time?(val)
    return true if val =~ REGEX_ISO_DATE_TIME
    false
  end
  
  def is_time_duration?(val)
    return true if val =~ REGEX_ISO_DURATION
    false
  end
  
  def is_version_number?(val)
    return true if val =~ REGEX_VERSION_NUMBER
    false
  end
  
  def is_base_64_encoded?(val)
    return true if val =~ REGEX_BASE64_ENCODE
    false
  end
  
end
