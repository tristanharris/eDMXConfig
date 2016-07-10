class Snapshot < ArtNet::Packet::Base

  attr_accessor :port_id

  def pack
    [ArtNet::Packet::ID, opcode, ArtNet::Packet::PROTVER, 1, 1 << @port_id].pack "Z7xvn CC"
  end

end
