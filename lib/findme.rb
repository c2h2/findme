module Findme

  AVAHI_SERVICE_DIR = "/etc/avahi/services/"
  AVAHI_BROWSE      = "/usr/bin/avahi-browse"


  #return all the services running by avahi
  def self.services
    files_with_path = Dir.glob(AVAHI_SERVICE_DIR + "*.service")
    files = files_with_path.map{|fwp| fwp.split("/").last}
  end

  #clean up all the services this gem registered. should be called by user to clean up unused services.
  def self.cleanup
    findme_services = []
    files_with_path = Dir.glob(AVAHI_SERVICE_DIR + "*.service")
    files_with_path.each do |fwp|
      File.open(fwp, 'r') do |infile|
        while (line = infile.gets)
          if line.strip == "<!-- findme generated -->"
            findme_services << fwp
          end
        end
      end
    end
    findme_services.each do |fs|
      puts "Removing #{fs}"
      File.delete fs
    end
  end

  def self._get_startup_time str
    begin
      pairs = str.strip.split(" ")
      pairs.each do |p|
        kv=p.strip.split("=")
        if kv[0] == "\"findme_startup_time"
          return kv[0].to_i
        end
      end
    rescue Exception => e
      # do nothing or if you want to debug: puts e
    end
    nil
  end

  def self.discover_only_earliest
    services = discover
    h = {}
    h_out={}

    #construct the hash, group the services of the same name
    services.each do |s|
      if h[s.service].nil?
        h[s.service]=[]
      else
        #existing hash, do nothing
      end
      h[s.service] << s
    end

    h.each do |k, v|
      if (_get_startup_time v[0].txt).nil?
        #cant find the earliest time, just return the first one.
      else
        v.sort! {|x,y| _get_startup_time(x.txt) <=> _get_startup_time(y.txt) }
      end
      h_out[k]=v.last #fix a bug here.
    end
    h_out
  end

  def self.discover_only_latest
    services = discover
    h = {}
    h_out={}

    #construct the hash, group the services of the same name
    services.each do |s|
      if h[s.service].nil?
        h[s.service]=[]
      else
        #existing hash, do nothing
      end
      h[s.service] << s
    end

    h.each do |k, v|
      if (_get_startup_time v[0].txt).nil?
        #cant find the earliest time, just return the first one.
      else
        v.sort! {|x,y| _get_startup_time(x.txt) <=> _get_startup_time(y.txt) }
      end
      h_out[k]=v.first #latest registerd.
    end
    h_out
  end

  def self.discover_service(service, ip=nil)
    services = discover

    result = services.detect {|x| x.service == "_#{service}._tcp" && x.ip == ip}
    return result if result #here we choose best match if previous is this ip
    #todo, using other factor to determine rank algorithm
    return services.detect {|x| x.service == "_#{service}._tcp"}[0]
  end

  def self.discover_services(service)
    services = discover

    result = services.select {|x| x.service == "_#{service}._tcp" }
  end


  def self.discover custom_cmd=nil

    if custom_cmd.nil?
      res = `avahi-browse -arpt`
    else
      res = `#{custom_cmd}`
    end

    services = []
    lines = res.scan(/\S+/)
    lines.each do |line|
      if line[0] == "="
        elems=line.split(";")
        as = AvahiService.new
        as.eth      = elems[1]
        as.ipv4     = elems[2]
        as.hosttxt  = elems[3]
        as.service  = elems[4]
        as.hostname = elems[6]
        as.ip       = elems[7]
        as.port     = elems[8]
        as.txt      = elems[9]
        services << as
      end
    end
    services
  end

  #register a new service to the folder
  def self.register service_name,  port, txt="", type = '_tcp', protocol="ipv4"
    txt = ("findme_startup_time=#{Time.now.to_i.to_s} " + txt).strip
    xml = '<?xml version="1.0" standalone=\'no\'?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">

<!-- findme generated -->
<!-- This file is part of '+ service_name + '} -->

<service-group>
  <name replace-wildcards="yes">%h</name>

  <service protocol="' + protocol + '">

    <type>'+ "_#{service_name}.#{type}" +'</type>
    <port>'+ port.to_s + '</port>
    <txt-record>' + txt.to_s + '</txt-record>
  </service>
</service-group>'

    File.open(AVAHI_SERVICE_DIR  + service_name + ".service", "w" ){|f| f.write xml}
  end

  # Unregister a service, just remove .service file from avahi service directory.
  # result: BOOLEAN, In most cases we don't care it.
  def self.unregister service_name
    service_file = AVAHI_SERVICE_DIR + service_name + ".service"
    if File.exist? service_file
      File.delete service_file
      return true
    end
  rescue # Errno::EACCES: Permission denied
    false
  end

  #find the mac address
  def self.mac
    return @mac_address if defined? @mac_address
    re = %r<(?:hwaddr|:)\s+((?:[0-9a-f]{1,2}[-:]){5}[0-9a-f]{1,2})\s*$>i
    lines =
      begin
        IO.popen('ifconfig'){|fd| fd.readlines}
      rescue
        IO.popen('ipconfig /all'){|fd| fd.readlines}
      end
    candidates = lines.map{|l| re.match( l )[1] rescue nil }.compact
    @mac_address = candidates.first
  end

  def self.mac_short
    self.mac.split(":").join("")
  end

end

class AvahiService
  attr_accessor :eth, :ipv4, :ip, :hosttxt, :hostname, :port, :txt, :service

  def ip_and_port
    [ip, port]
  end

  def inspect
    "#<eth: #{eth}, ipv4: #{ipv4}, ip: #{ip}, hosttxt: #{hosttxt}, hostname: #{hostname}, port: #{port}, txt: #{txt}, service: #{service}>"
  end

end
