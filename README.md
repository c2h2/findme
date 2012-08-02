findme
======

Find neighborhood host and services. fineme uses `avahi-deamon` and `avahi-browse` to discover and register services. Only works with ubuntu linux for now. (12.04 is tested working)


Install
-------

    gem install findme
    
Example
-------

    require 'findme'
    require 'pp'

    puts Findme.discover.count.to_s + " Service discovered."
    Findme.discover.each{|service| pp service.inspect}
    
More advanced Example
---------------------

on server:

    require 'findme'

    Findme.register "findme", 1337

on client:
    
    require 'findme'

    SERVICE = "findme"
    services = Findme.discover
    services.select{|s| s.service == "_#{SERVICE}._tcp"}.each{|s| puts "#{s.ip}:#{s.port}"}

results on client.rb:

    ~ > ruby client.rb
    fe80::a00:27ff:feeb:xxxx:1337
    192.168.xx.xx:1337

