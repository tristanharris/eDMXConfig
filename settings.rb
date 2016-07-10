class Settings < ArtNet::Packet::Base

  class Port

    attr_accessor :rdm_spacing, :rdm_discovery, :update_rate, :addr

    OPERATION_MODES = {0 => :artnet, 1 => :dmx, 2 => :sacn}

    def initialize
      @operation_mode = 0
      @rdm_spacing = 0
      @rdm_discovery = 0
      @update_rate = 0
      @addr = 0
      @flags = 0
    end

    def broadcast_threshold
      0 #Not sure where this comes from
    end

    def merge_mode
      @flags & 1 == 0 ? :htp : :ltp
    end

    def merge_mode=(v)
      @flags &= ~1
      @flags |= 1 if v.to_sym == :ltp
    end

    def operation_mode
      OPERATION_MODES[@operation_mode]
    end

    def operation_mode=(v)
      @operation_mode = OPERATION_MODES.invert[v.to_sym] || 1
    end

    def timeout_sources?
      @flags & 2 != 0
    end

    def timeout_sources=(v)
      @flags &= ~2
      @flags |= 2 if v
    end

    def recall_dmx?
      @flags & 4 != 0
    end

    def recall_dmx=(v)
      @flags &= ~4
      @flags |= 4 if v
    end

    def unpack(data)
      @operation_mode, @flags, @rdm_spacing, @rdm_discovery, @update_rate, @addr = data.unpack "CCxCnxCn"
    end

    def pack
      [@operation_mode, @flags, @rdm_spacing, @rdm_discovery, @update_rate, @addr].pack "CCxCnxCn"
    end

  end

  attr_accessor :mac, :ip, :netmask, :gateway, :netmode, :ports

  def initialize
    @mac = ArtNet::MacAddr.new
    @ip = ::IPAddr.new(0,  Socket::AF_INET)
    @netmask = ::IPAddr.new(0,  Socket::AF_INET)
    @gateway = ::IPAddr.new(0,  Socket::AF_INET)
    @netmode = 0
    @ports = []
    @ports << Port.new
    @cmd = [0] * 10
  end

  def update!
    #Don't know what this chunk does but it's needed to perfom an update
    @cmd = [0x84, 0x00, 0x12, 0x34, 0x56, 0x78, 0x87, 0x65, 0x43, 0x21]
  end

  def pack
    data = [ArtNet::Packet::ID, opcode, ArtNet::Packet::PROTVER, @cmd.pack('C10'), @mac.to_bytes, @ip.to_i, @netmask.to_i, @gateway.to_i, @netmode].pack "Z7xvn a10x8a6NNNCx"
    data + @ports.map(&:pack).join
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
    version, @mac, ip, netmask, gateway, @netmode = data.unpack 'nx10x8a6NNNCx'
    check_version(version)
    @ip = ::IPAddr.new(ip,  Socket::AF_INET)
    @netmask = ::IPAddr.new(netmask,  Socket::AF_INET)
    @gateway = ::IPAddr.new(gateway,  Socket::AF_INET)
    ptr = 40
    @ports = []
    while !data.unpack("@#{ptr}C").first.nil?
      port = Settings::Port.new
      port.unpack data.unpack("@#{ptr}a10").first
      @ports << port
      ptr += 10
    end
  end

end
