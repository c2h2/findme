class Findme
 
  AVAHI_SERVICE_DIR = "/etc/avahi/services/"
  AVAHI_BROWSE      = "/usr/bin/avahi-browse"

 
  #return all the services running by avahi
  def self.services
    files_with_path = Dir.glob(AVAHI_SERVICE_DIR + "*.service")
    files = files_with_path.map{|fwp| fwp.split("/").last}
  end

  #clean up all the services this gem registered.
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

  #register a new service to the folder
  def self.register service_name,  port, type = '_tcp'
    xml = '<?xml version="1.0" standalone=\'no\'?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">

<!-- findme generated -->
<!-- This file is part of udisks -->

<service-group>
  <name replace-wildcards="yes">%h</name>

  <service>
    <type>'+ "_#{service_name}.#{type}" +'</type>
    <port>' + port.to_s + '</port>
  </service>
</service-group>'

    File.open(AVAHI_SERVICE_DIR  + service_name + ".service", "w" ){|f| f.write xml}
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
