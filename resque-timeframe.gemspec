# encoding: utf-8
require File.expand_path('../lib/resque-timeframe/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name = 'resque-timeframe'
  spec.version = ResqueTimeframe::VERSION::STRING
  spec.date    = Time.now.strftime('%Y-%m-%d')

  spec.summary = "Bigtable adapter"
  spec.description = "resque-timeframe is an extension to resque queue system that allow the execution at configured time."

  spec.author = 'Dmitry Larkin'
  spec.email = 'dmitry.larkin@gmail.com'
  spec.homepage = 'http://github.com/dml/resque-timeframe'

  spec.rubyforge_project = nil
  spec.has_rdoc = true
  spec.rdoc_options = ['--main', 'README.rdoc', '--charset=UTF-8']
  spec.extra_rdoc_files = ['README.markdown', 'LICENSE', 'CHANGELOG']

  spec.files = Dir['Rakefile', '{lib,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")

  spec.add_dependency(%q<resque>, [">= 1.8.0"])
  spec.add_dependency(%q<resque-scheduler>, [">= 1.8.0"])
  spec.add_runtime_dependency(%q<resque>, [">= 1.8.0"])
end
