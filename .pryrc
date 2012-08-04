# -*- mode: ruby -*- vim:set ft=ruby:

ENV['HOME'] ||= ENV['USERPROFILE'] || File.dirname(__FILE__)

Pry.editor = ENV['VISUAL']
Pry.config.history.file = if defined?(Bundler)
                            Bundler.tmp.parent.join('history.rb')
                          else
                            File.expand_path('~/.history.rb')
                          end

$LOAD_PATH.unshift(File.expand_path('~/.ruby/lib'), File.expand_path('~/.ruby'))
$LOAD_PATH.uniq!

%w(tpope pry-editline).each do |lib|
  begin
    require lib
  rescue LoadError
  end
end
