class Settings < ArtNet::Packet::Base

  def pack
    [ArtNet::Packet::ID, opcode, ArtNet::Packet::PROTVER].pack "Z7xvnx48"
  end
#48*0 request
  #
  #ports update
  #  84 00 12 34 56 78 87 65 43 21
  #  00 00 00 00 00 00 00 00
  #  [mac 00 00 00 00 00 00] [ip 00 00 00 00] [netmask00 00 00 00] [gateway 00 00 00 00]
  #  [ip mode 00=custom 01=2.x 02=10.x 00] 00
  #  01 00 00 01 00 00 00 28 [A port 09 fa]
  #  00 00 00 01 00 00 00 28 [B port 68 29]
  #  01 00 00 01 00 00 00 28 [C Port top bit set 86 8b]
  #  [00=atrnet 02=sacn 01-dmxout 00] [b0-0=htp b0-1=ltp, b1=timoutsources, b3=recalldmx 00] 00 [rdmspacing 01] [rdmdiscovery 00 00] 00 [update rate 1-40hz 28] [D port top bit set 8a e2]

end

class SettingsReply < ArtNet::Packet::Base

  attr_reader :mac, :ip, :netmask, :gateway, :netmode, :ports

  def unpack(data)
    version, @mac, ip, netmask, gateway, @netmode, final = data.unpack 'nx18a6NNNCxC'
    check_version(version)
    @ip = ::IPAddr.new(ip,  Socket::AF_INET)
    @netmask = ::IPAddr.new(netmask,  Socket::AF_INET)
    @gateway = ::IPAddr.new(gateway,  Socket::AF_INET)
    ptr = 40
    @ports = []
    while !final.nil?
      port = OpenStruct.new
      port.operation_mode, flags, port.rdm_spacing, port.rdm_discovery, port.update_rate, port.addr, final = data.unpack "@#{ptr}CCxCnxCnC"
      port.merge = flags & 1 == 0 ? :htp : :ltp
      port.timeout_sources = flags & 2 != 0
      port.recall_dmx = flags & 4 != 0
      @ports << port
      ptr += 10
    end
  end

end
