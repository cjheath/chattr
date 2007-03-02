#
# Rakefile for chattr.
#
# See LICENSE file for copyright notice.
#
require 'rubygems'
Gem::manage_gems
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rake/clean'
require 'spec'

task :default => [ :test, :rdoc, :packaging, :package ]

task :test do
    gem 'rspec', "> 0"
    require 'spec'

    $LOAD_PATH.unshift "lib"	# Make sure we know where to find the module
    Spec::Runner::CommandLine::run(
	    %w{spec/chattr_spec.rb -f s},
	    $stderr, $stdout,
	    false		# Don't exit after testing
	)
end

CLEAN.include("docs")	# Make sure we clean up the generated docs
Rake::RDocTask.new do |rd|
    rd.rdoc_files.include("lib/**/*.rb", "LICENSE")
    rd.rdoc_dir = "docs"
end

# Create the package task dynamically so FileList happens after RDocTask
CLOBBER.include("pkg")	# Make sure we clean up the gem
task :packaging do
    spec = Gem::Specification.new do |s|
	s.name       = "chattr"
	s.version    = "0.9.0"
	s.author     = "Clifford Heath"
	s.email      = "clifford dot heath at gmail dot com"
	s.homepage   = "http://rubyforge.org/projects/chattr"
	s.platform   = Gem::Platform::RUBY
	s.summary    = "Methods for defining type-checked arrays and attributes"
	s.files      = FileList["{bin,lib,test}/**/*"].to_a
	s.files      += [ "LICENSE" ]
	s.require_path      = "lib"
	s.autorequire       = "chattr"
	s.test_file         = "spec/runtest.rb"
	s.has_rdoc          = true
	s.extra_rdoc_files  = []
    end

    Rake::GemPackageTask.new(spec) do |pkg|
	pkg.package_files += FileList["docs/**/*"].exclude(/rdoc$/).to_a
	pkg.need_tar = true
    end
end
