TEST_FROM_GEM = true
$: << File.join(File.dirname(__FILE__),'../lib')
Dir[File.join(File.dirname(__FILE__), '**/test_*.rb')].each { |test| require test }

