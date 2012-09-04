findme
======

Find neighborhood host and services. fineme uses `avahi-deamon` and `avahi-browse` to discover and register services. Only works with ubuntu linux for now. (12.04 is tested working)


Install
-------
    sudo apt-get install avahi-utils avahi-daemon libnss-mdns
    gem install findme
    
Enable normal user to use this gem (first time):
    sudo chmod a+w /etc/avahi/services/
    
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
    Findme.cleanup
    Findme.register "findme", 1337

on client -> client.rb:
    
    require 'findme'

    SERVICE = "findme"
    services = Findme.discover
    services.select{|s| s.service == "_#{SERVICE}._tcp"}.each{|s| puts "#{s.ip}:#{s.port}"}

on client discover latest and earliest -> client_earliest_latest.rb:
    
    require 'findme'
    require 'pp'

    SERVICE = "findme"
    h = Findme.discover_only_earliest
    h.select{|k,s| s.service == "_#{SERVICE}._tcp"}.each{|k,s| puts "#{k}|#{s.ip}:#{s.port}:#{s.txt}"}

     
    h = Findme.discover_only_latest
    h.select{|k,s| s.service == "_#{SERVICE}._tcp"}.each{|k,s| puts "#{k}|#{s.ip}:#{s.port}:#{s.txt}"}
 

results on client.rb:

    ~ > ruby client.rb
    fe80::a00:27ff:feeb:xxxx:1337
    192.168.xx.xx:1337


     ~ > ruby client_earliest_latest.rb
     _findme._tcp|192.168.10.xxx:1337:"findme_startup_time=1346228166"
     _findme._tcp|192.168.10.yyy:1337:"findme_startup_time=1346229066"
