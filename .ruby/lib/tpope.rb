# -*- ruby -*- vim:set ft=ruby sw=2 sts=2 sta et:
# $Id$

old_current = $LOAD_PATH.pop if $LOAD_PATH.last == '.'
%w(.ruby/lib ruby/lib .ruby ruby).each do |dir|
  $LOAD_PATH.unshift(File.expand_path("~/#{dir}"))
end
Dir[File.expand_path('~/ruby/*')].each do |dir|
  $LOAD_PATH << "#{dir}/lib"       if File.directory?("#{dir}/lib")
  $LOAD_PATH << "#{dir}/trunk/lib" if File.directory?("#{dir}/trunk/lib")
end
$LOAD_PATH << old_current if old_current

$LOAD_PATH.uniq!

begin
  if require('rubygems')
    module Kernel
      alias gem_require__ require
      def require(path)
        gem_require__ path
      rescue ScriptError => err
        backtrace = caller
        # backtrace.shift while backtrace.first =~ %r{/active_support/dependencies\.rb:\d+:in }
        err.set_backtrace backtrace
        err.backtrace.unshift(err.backtrace.first+":in `require'")
        raise err
      end
      private :gem_require__, :require
    end
  end
rescue LoadError
end

module Kernel
  def stack_size(i=caller.size)
    stack_size(i+1)
  rescue SystemStackError
    i
  end
end

class Symbol
  def to_proc
    Proc.new { |*args| args.shift.__send__(self,*args) }
  end
end

class Integer
  def to_proc
    Proc.new { |obj,*args| obj[self,*args] }
  end
  def prime?
    '1' * self !~ /^1?$|^(11+?)\1+$/
  end
end

class Range
  def to_proc
    Proc.new { |obj,*args| obj[self,*args] }
  end
end

class Array

  def to_proc
    Proc.new do |obj,*args|
      if args.empty?
        obj.send(*self)
      else
        array = self.dup
        args.map(&array.pop)
      end
    end
  end

  def most(omit = 1)
    self[0..(-1-omit)]
  end
  def rest(omit = 1)
    self[omit..-1]
  end

  def word_list?
    return false if     size == 0
    return false unless all? {|el| el.kind_of?(String)}
    return false if     any? {|el| el =~ /[\000-\040()\\]/ || el.empty? }
    true
  end
  def w_inspect(always_single_line = false)
    return bracketed_inspect unless size.between?(1,1000)
    return bracketed_inspect unless word_list?
    list = "%w(" + join(" ") + ")"
    return list if list.length < 76 || always_single_line
    maxlen = inject(0) {|m,o| m>o.length ? m : o.length}
    interval = 72/(maxlen+1)
    return "%w(\n   " + join("\n   ") + "\n   )" if interval == 0
    list = "%w("
    each_with_index do |elem,index|
      if index % interval == 0
        list.rstrip!
        list << "\n   "
      end
      list << ("%-#{maxlen+1}s" % elem)
    end
    list.chomp!(" ")
    list << ")"
  end
  unless method_defined?(:bracketed_inspect)
    alias bracketed_inspect inspect
    def inspect
      w_inspect(caller.first(3).any? {|x|x.include?("in `inspect'")})
    end
  end

end

class String
  def to_proc
    Proc.new { |obj| obj.instance_eval self.gsub(/@/,' self ') }
  end
end

# require 'date'
# class Date
  # def inspect
    # "#<#{self.class}: #{strftime("%Y-%m-%d %H:%M:%S")}>"
  # end
# end

module Enumerable
  def reduce(op,arg=nil)
    b = lambda { |m,o| m.send(op,o) }
    arg.nil? ? inject(&b) : inject(arg,&b)
  end
end

class Object

  def __class__
    Kernel.instance_method(:class).bind(self).call
  end

  def tap
    yield(self)
    self
  end

  def metaclass
    class << self; self; end
  end

  def meta_eval(&block)
    metaclass.instance_eval(&block)
  end

  def returning(value)
    yield(value)
    value
  end

  # These all discard superclass methods but keep mixed in methods
  def ls(object = self)
    results  = object.methods
    results -= object.class.superclass.instance_methods rescue []
    results.sort!
  end

  def lsp(object = self)
    results  = object.private_methods
    results -= object.class.superclass.private_instance_methods rescue []
    results.sort!
  end

  def lsi(object)
    results  = object.instance_methods
    results -= object.superclass.instance_methods if object.respond_to?(:superclass) && object.superclass
    results.sort!
  end

  def lsip(object)
    results  = object.private_instance_methods
    results -= object.superclass.private_instance_methods if object.respond_to?(:superclass) && object.superclass
    results.sort!
  end

end

class Module
  def lsi(object = self)
    super(object)
  end
  def lsip(object = self)
    super(object)
  end
end


class Time
  PROCESS_ATTRIBUTES = [:utime, :stime, :cutime, :cstime, :other]
  Process = Struct.new(*PROCESS_ATTRIBUTES)
  class Process
    def inspect
      final = "#<#{self.class.inspect} "
      final << "%.4f" % PROCESS_ATTRIBUTES[0..-2].inject(0) {|m,o| m + self[o]}
      PROCESS_ATTRIBUTES.each do |method|
        final << (" #{method}=%.4f" % self[method]) if self[method] > 0
      end
      final << ">"
    end
  end
  def self.measure(count = 1, &block)
    attrs = PROCESS_ATTRIBUTES[0..-2]
    sum  = lambda {|pt| attrs.map {|a| pt[a]}.inject(&:+)}
    diff = lambda {|o1,o2,method,c| (o2.send(method)-o1.send(method))/c }
    t1 = Time.now
    p1 = ::Process.times
    count.times(&block)
    t2 = Time.now
    p2 = ::Process.times
    other = ((t2 - t1) - (sum[p2] - sum[p1]))/count
    Time::Process.new(*attrs.map {|a| diff[p1,p2,a,count]} + [other])
  end

end

module IRB
  def self.on_exec
    if caller.size == 1 && caller.first.sub(/:\d+$/,'') == $0
      yield if block_given?
      require 'irb'
      IRB.start($0)
    end
  end
end

module Tpope
  def self.status
    `tpope status`.chomp
  end
  def self.const_missing(const)
    begin
      require File.join('tpope',const.to_s.downcase)
    rescue LoadError
    end
    if const_defined?(const)
      const_get(const)
    else
      super
    end
  end
end

class String
  def checksum
    t = 0
    each_byte do |b|
      t += b
    end
    t & 255
  end
end
