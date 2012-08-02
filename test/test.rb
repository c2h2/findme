require './findme.rb'
require 'pp'

Findme.discover.each do |i|

pp i.inspect
end
