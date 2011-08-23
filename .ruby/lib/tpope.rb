old_current = $LOAD_PATH.pop if $LOAD_PATH.last == '.'
%w(.ruby/lib .ruby src/ruby/lib).each do |dir|
  $LOAD_PATH.unshift(File.expand_path("~/#{dir}"))
end
$LOAD_PATH << old_current if old_current

$LOAD_PATH.uniq!

begin
  require 'rubygems'
rescue LoadError
end

module Kernel
  def stack_size(i=caller.size)
    stack_size(i+1)
  rescue SystemStackError
    i
  end

  def r(*objects)
    raise RuntimeError, objects.map { |o| o.inspect }.join("\n"), caller
  end
end

class Symbol
  def to_proc
    Proc.new { |*args| args.shift.__send__(self, *args) }
  end unless method_defined?(:to_proc)
end

class Integer
  def prime?
    '1' * self !~ /^1?$|^(11+?)\1+$/
  end
end

class Object

  alias __class__ class

  def tap
    yield(self) if block_given?
    self
  end if RUBY_VERSION =~ /^1\.8/

  def metaclass
    class << self; self; end
  end

  def meta_eval(&block)
    metaclass.instance_eval(&block)
  end

  def ls(object = self)
    (object.methods - Class.instance_methods).sort!
  end

  def lsi(object)
    (object.instance_methods - Object.instance_methods).sort!
  end

end

class Module
  def lsi(object = self)
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
    sum  = lambda { |pt| attrs.map {|a| pt[a]}.inject(&:+)}
    diff = lambda { |o1,o2,method,c| (o2.send(method)-o1.send(method))/c }
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

class String
  def checksum
    t = 0
    each_byte do |b|
      t += b
    end
    t & 255
  end

  if RUBY_VERSION == '1.8.7' && method_defined?(:chars)
    undef chars
    def chars(*args, &block)
      ActiveSupport::Multibyte::Chars.new(self)
    end
  end
end
