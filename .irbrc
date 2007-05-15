# -*- ruby -*- vim:set ft=ruby sw=2 sts=2 sta et:
# $Id$

IRB.conf[:AUTO_INDENT]   = true
IRB.conf[:USE_READLINE]  = true
IRB.conf[:LOAD_MODULES] |= %w(irb/completion stringio ostruct enumerator pp)
IRB.conf[:HISTORY_FILE]  = File.expand_path('~/.irb_history.rb') rescue nil
IRB.conf[:SAVE_HISTORY]  = 50
IRB.conf[:EVAL_HISTORY]  = 2

$LOAD_PATH.unshift(File.expand_path('~/.ruby/lib'),File.expand_path('~/.ruby'))
$LOAD_PATH.uniq!

def optional_require(lib)
  begin; require lib; rescue LoadError; end
end

optional_require 'tpope'
optional_require 'rubygems'
optional_require 'active_support' unless IRB.conf[:PROMPT_MODE] == :SIMPLE && ENV["RAILS_ENV"]
optional_require File.expand_path('~/.irb_local.rb')

$KCODE = 'UTF8' if RUBY_PLATFORM =~ /mswin32/ || ENV['LANG'].to_s =~ /UTF/i

class Object

  def doc(method = nil)
    method = ri_topic(method) unless method.to_s =~ /[#:]/
    exec_ri(method.to_s)
  end

  private
  def ri_topic(method = nil)
    return self.class.to_s unless method
    self.class.ancestors.each do |anc|
      if anc.instance_methods(false).include?(method.to_s)
        return anc == Kernel ? "#{method}" : "#{anc}##{method}"
      end
    end
    self.class.ancestors.each do |anc|
      if anc.private_instance_methods(false).include?(method.to_s)
        return "#{anc}##{method}"
      end
    end
    return "#{self.class}##{method}"
  end

  def exec_ri(*args)
    system("ri","-f","bs",*args)
  end

end

class Module

  def doc!(method = nil)
    if method
      klass = ancestors.detect do |anc|
        anc.instance_methods(false).include?(method.to_s)
      end
      exec_ri("#{klass||self}##{method}")
    else
      exec_ri(to_s)
    end
  end

  private

  def ri_topic(method = nil)
    if method.to_s == "new"
      ancestors.each do |anc|
        if anc.private_instance_methods(false).include?('initialize')
          return "#{anc}::#{method}"
        end
      end
    end
    if method
      ancestors.each do |anc|
        if anc.methods(false).include?(method.to_s)
          return "#{anc}::#{method}"
        end
      end
    end
    super
  end

  def method_missing(method,*args)
    super unless args.empty?
    doc! method or super
  end if false

end

class IRB::Irb
  def output_value
    if @context.inspect_mode.kind_of?(Symbol)
      value = @context.last_value.send(@context.inspect_mode).to_s.dup
      if value.chomp! 
        value[0,0] = "\n"
      end
      printf @context.return_format, value
    elsif @context.inspect?
      printf @context.return_format, @context.last_value.inspect
    else
      printf @context.return_format, @context.last_value
    end
  end
end

class Class
  def inspect_filter
    alias_method 'unfiltered_inspect', :inspect unless instance_methods.include?('unfiltered_inspect')
    define_method(:inspect) do
      if caller.first(5).any? {|t| t =~ /\birb\.?r[bc]:\d+:in `output_value'$/}
        if ENV['TERM'] && ENV['TERM'] != 'dumb'
          return yield(unfiltered_inspect)
        end
      end
      unfiltered_inspect
    end
  end
end

[String, Numeric, TrueClass, FalseClass].each do |klass|
  klass.inspect_filter {|text| "\e[1;35m#{text}\e[0m"}
end
NilClass.inspect_filter {|text| "\e[1;30m#{text}\e[0m"}
Symbol.inspect_filter {|text| "\e[1;36m#{text}\e[0m"}
Module.inspect_filter {|text| "\e[1;32m#{text}\e[0m"}
Object.inspect_filter do |text|
  text.gsub(/#<([A-Z]\w*(?:::\w+)*)/,"#<\e[1;32m\\1\e[0m")
end
