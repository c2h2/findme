findme
======

Find neighborhood host and services. By using avahi deamon and avahi-brwose to discover and register services. Only works with ubuntu linux for now.


Install
-------

    gem install findme
    
    
    
Example
-------

    require 'findme'
    require 'pp'

    Findme.discover.each{|service| pp service.inspect}
