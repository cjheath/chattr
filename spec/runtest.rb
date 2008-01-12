require 'rubygems'
gem 'rspec'
require 'spec'

Spec::Runner::CommandLine::run(
	%w{test/chattr_spec.rb -f s},
	$stderr, $stdout
    )
