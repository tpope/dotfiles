# -*- mode: ruby -*- vim:set ft=ruby:

ENV['HOME'] ||= ENV['USERPROFILE'] || File.dirname(__FILE__)

Pry.editor = ENV['VISUAL']
Pry.config.history.file = if defined?(Rails)
                            Rails.root.join('tmp', 'history.rb')
                          else
                            File.expand_path('~/.history.rb')
                          end

Gem.path.each do |gemset|
  $:.concat(Dir.glob("#{gemset}/gems/pry-*/lib"))
end if defined?(Bundler)
$:.uniq!

Pry.load_plugins if Pry.config.should_load_plugins
