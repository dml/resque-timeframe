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
  spec.homepage = 'http://www.railsware.com'

  spec.rubyforge_project = nil
  spec.has_rdoc = true
  spec.rdoc_options = ['--main', 'README.rdoc', '--charset=UTF-8']
  spec.extra_rdoc_files = ['README.markdown', 'LICENSE', 'CHANGELOG']
  spec.rubygems_version = %q{1.3.6}

  spec.files = Dir['Rakefile', '{lib,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")

  if spec.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    spec.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      spec.add_runtime_dependency(%q<resque>, [">= 1.7.0"])
    else
      spec.add_dependency(%q<resque>, [">= 1.7.0"])
    end
  else
    spec.add_dependency(%q<resque>, [">= 1.7.0"])
  end
end
