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
    x.gsub(/\{(\d+)\}:/){$RGSS_SCRIPTS[$1.to_i][1]+": "}
  end
  
  def self.transmsg(a)
    if a =~ /undefined method `([^']+)' for (.+):(.+)/
        return "#{$3}: δ����ķ��� #{$1}, ����#{$2}"
    end
    
    if a =~ /syntax error, unexpected (.+)/
        return a.gsub(/syntax error, unexpected (.+)/){ "�﷨���󣬹����#{trans_syntax_symbol($1)}(�Ƿ��ٴ���һЩ����)"}
    end
      
    a
  end

  def self.trans_syntax_symbol(a)
    {"$end"=>"�ļ�����($end)"}[a]
  end
  
  def self.printex(a)
    ex = trans(a)
    msgbox ([ex.to_s] + ex.backtrace)*"\n"
  end
end

=begin Test and Usage
 begin
   eval ("33 + ")
 rescue Object => ex
   Localexception.printex(ex)
 end
=end