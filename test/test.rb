require File.expand_path("../../lib/findme.rb", __FILE__)
require 'pp'

Findme.discover.each do |i|

pp i.inspect
end

pp Findme::VERSION
