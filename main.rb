module Localexception
  
  def self.trans(ex)
    myex = ex.backtrace.map{|x|
      transbt(x)
    }
    q = ex.exception(transmsg(ex.message))
    q.set_backtrace(myex)
    q
  end
  
  def self.transbt(x)
    x.gsub(/\{(\d+)\}:(\d+)/){
        $RGSS_SCRIPTS[$1.to_i][1]+": "+$2
    }
  end
  
  def self.transmsg(a)
    if a =~ /undefined method `([^']+)' for (.+):(.+)/
        return "#{$3}: 未定义的方法 #{$1}, 对象#{$2}"
    end
    
    if a =~ /syntax error, unexpected (.+)/
        return a.gsub(/syntax error, unexpected (.+)/){ "语法错误，过早的#{trans_syntax_symbol($1)}(是否少打了一些代码)"}
    end
     
    if a =~ /wrong number of arguments \((\d+) for (\d+)\)/
        return "参数个数错误，应该是#$2，却提供了#$1"
    end
      
    if a =~ /No such file or directory - (.+)/
        return "找不到文件或目录 : #$1"
    end
      
    if a =~ /Permission denied - (.+)/
       return "权限被拒绝，不能读写#$1"
    end
    
    if a =~ /not opened for reading/
       return "打开的文件不可读（可能是只写方式打开)"
    end
    
    if a =~ /not opened for writing/
       return "打开的文件不可写（可能是只读方式打开)"
    end
     
    if a=~ /closed stream/ 
       return "文件或流已关闭"
    end
     
    if a=~/(.+) can't be coerced into (.+)/
       return "不能把#$1强制转换为#{trans_class_ex($2)}"
    end
     
    a
  end

  def self.trans_syntax_symbol(a)
    {"$end"=>"文件结束($end)"}[a]
  end
  
  def self.trans_class_ex(a)
    trans_class(a) || {
      "Fixnum" => "整数(Fixnum)",
    
    }[a.to_s]
  end
  
  def self.trans_class(a)
    { "NoMethodError"  => "找不到方法错误(#{a})",
      "SyntaxError"    => "语法错误(#{a})",
      "ArgumentError"  => "参数错误(#{a})",
      "Errno::ENOENT"  => "找不到项目错误(#{a})",
      "Errno::EACCES"  => "访问错误(#{a})",
      "IOError"        => "输入输出错误(#{a})",
      "TypeError"      => "类型错误(#{a})",
    }[a.to_s]
  end
  
  def self.msg(msg)
    Win32API.new("User32", "MessageBoxW", "ippi", "i").call(
      0,
      Seiran20.to_wc(msg+"\0\0"),
      Seiran20.to_wc("错误\0\0"),
      48
    )
  end
  def self.printex(a)
    ex = trans(a)
    msg(([trans_class(ex.class) || ex.class.to_s, ex.to_s, ""] + ex.backtrace)*"\n")
  end
end

begin
 print 1+nil
rescue Object => ex
  Localexception.printex(ex)
end
