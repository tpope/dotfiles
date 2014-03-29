$:.unshift(*%w(~/src/ruby/lib ~/.ruby/lib).map {|d| File.expand_path d})
$:.unshift('.') if $:.delete('.')

begin
  require 'rubygems'
  Gem.path.grep(/@global$/).each do |gemset|
    $:.concat(Dir.glob("#{gemset}/gems/*").map { |gem| "#{gem}/lib" })
  end if defined?(Bundler)
  $:.uniq!
rescue LoadError
end

module Kernel
  def r(*objects)
    raise RuntimeError, objects.map { |o| o.inspect }.join("\n"), caller
  end
end

class Object
  alias __class__ class
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
