require 'findme'
require 'pp'

SERVICE = "findme"
#services = Findme.discover
h = Findme.discover_only_earliest
h.select{|k,s| s.service == "_#{SERVICE}._tcp"}.each{|k,s| puts "#{k}|#{s.ip}:#{s.port}:#{s.txt}"}
