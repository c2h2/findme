require 'findme'

SERVICE = "findme"
services = Findme.discover
services.select{|s| s.service == "_#{SERVICE}._tcp"}.each{|s| puts "#{s.ip}:#{s.port}"}
