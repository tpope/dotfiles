# -*- mode: ruby -*- vim:set ft=ruby:

ENV['HOME'] ||= ENV['USERPROFILE'] || File.dirname(__FILE__)

%w(rubygems pry pry-editline).each do |lib|
  begin
    require lib
  rescue LoadError
  end
end

(Pry.start; exit) if defined?(Pry)

IRB.conf[:AUTO_INDENT] = true
IRB.conf[:LOAD_MODULES] |= %w(irb/completion stringio enumerator ostruct)
IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = if defined?(Rails) && Rails.root
                            Rails.root.join('tmp', 'history.rb')
                          else
                            File.expand_path('~/.history.rb')
                          end
