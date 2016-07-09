require 'tk'
require 'art_net'
require 'ostruct'

TkOption.add '*tearOff', 0

artnet = ArtNet::IO.new :network => "192.168.0.100", :netmask => "255.255.255.0"
gui = OpenStruct.new
gui.setting_items = []
gui.root = TkRoot.new do |p|
  title "eDMX Configuration"
  p['menu'] = TkMenu.new(p) do |p|
    file = TkMenu.new(p) do |p|
      add :command, :label => 'Quit', :command => proc{gui.root.destroy}
    end
    advanced = TkMenu.new(p) do |p|
      m = TkMenu.new(p) do |p|
        add :command, :label => 'Short Name', :command => proc{gui.name_window(:short)}
        add :command, :label => 'Long Name', :command => proc{gui.name_window(:long)}
      end
      add :cascade, :label => 'Edit Node Name', :menu => m
    end
    add :cascade, :menu => file, :label => 'File'
    add :cascade, :menu => advanced, :label => 'Advanced'
  end

  TkFrame.new(p) do |p|
    pack('side' => 'top', fill: 'both', expand: true)
    TkLabelFrame.new(p) do |p|
      text 'eDMX devices'
      borderwidth 1
      pack('side' => 'left', fill: 'both', expand: true)
      TkFrame.new(p) do |p|
        pack('side' => 'top', fill: 'both', expand: true)
        gui.devices = Tk::Tile::Treeview.new(p) do |p|
          p['columns'] = 'name'
          p.heading_configure('#0', text: 'IP Address')
          p.heading_configure(:name, text: 'Name')
          selectmode :browse
          pack(side: 'left', fill: 'both', expand: true)
        end
        TkScrollbar.new(p) do |scroll|
          pack(side: 'right', fill: 'y')
          command do |*idx|
            gui.devices.yview(*idx)
          end
          gui.devices.yscroll proc { |*idx|
            set(*idx)
          }
        end
      end
      TkButton.new(p) do
        text 'Search For Device'
        pack(fill: 'both', expand: true)
      end
    end

    TkLabelFrame.new(p) do |p|
      text 'Network'
      borderwidth 1
      pack('side' => 'left', fill: 'both', expand: true)
      TkFrame.new(p) do |p|
        pack('side' => 'top', fill: 'both', expand: true)
        TkLabelFrame.new(p) do |p|
          text 'MAC Address'
          borderwidth 1
          pack('side' => 'left', fill: 'both', expand: true)
          gui.mac = TkLabel.new(p) do
            pack('side' => 'left', fill: 'both', expand: true)
          end
        end
        TkLabelFrame.new(p) do |p|
          text 'Device IP Address'
          borderwidth 1
          pack('side' => 'left', fill: 'both', expand: true)
          gui.ip = TkLabel.new(p) do
            pack('side' => 'left', fill: 'both', expand: true)
          end
        end
      end
      TkFrame.new(p) do |p|
        pack('side' => 'top', fill: 'both', expand: true)
        TkLabelFrame.new(p) do |p|
          text 'Network Settings'
          borderwidth 1
          pack('side' => 'left', fill: 'both', expand: true)
          TkFrame.new(p) do |p|
            pack('side' => 'top', fill: 'both', expand: true)
            TkLabel.new(p) do
              text 'Ip Address'
              pack('side' => 'left', fill: 'both', expand: true)
            end
            gui.setting_items << Tk::Tile::Entry.new(p) do
              textvariable gui.new_ip = TkVariable.new
              pack('side' => 'left', fill: 'both', expand: true)
            end
          end
          TkFrame.new(p) do |p|
            pack('side' => 'top', fill: 'both', expand: true)
            TkLabel.new(p) do
              text 'Subnet Mask'
              pack('side' => 'left', fill: 'both', expand: true)
            end
            gui.setting_items << Tk::Tile::Entry.new(p) do
              textvariable gui.new_netmask = TkVariable.new
              pack('side' => 'left', fill: 'both', expand: true)
            end
          end
          TkFrame.new(p) do |p|
            pack('side' => 'top', fill: 'both', expand: true)
            TkLabel.new(p) do
              text 'Default Gateway'
              pack('side' => 'left', fill: 'both', expand: true)
            end
            gui.setting_items << Tk::Tile::Entry.new(p) do
              textvariable gui.new_gateway = TkVariable.new
              pack('side' => 'left', fill: 'both', expand: true)
            end
          end
        end
        TkLabelFrame.new(p) do |p|
          text 'Network Mode'
          gui.net_mode = TkVariable.new
          borderwidth 1
          pack('side' => 'left', fill: 'both', expand: true)
          gui.setting_items << TkRadioButton.new(p) do
            text '2.X.Y.Z'
            variable gui.net_mode
            value '2.X.Y.Z'
            anchor 'w'
            pack('side' => 'top', 'fill' => 'x')
          end
          gui.setting_items << TkRadioButton.new(p) do
            text '10.X.Y.Z'
            variable gui.net_mode
            value '10.X.Y.Z'
            anchor 'w'
            pack('side' => 'top', 'fill' => 'x')
          end
          gui.setting_items << TkRadioButton.new(p) do
            text 'Custom IP'
            variable gui.net_mode
            value 'custom'
            anchor 'w'
            pack('side' => 'top', 'fill' => 'x')
          end
          gui.setting_items << TkRadioButton.new(p) do
            text 'DHCP'
            variable gui.net_mode
            value 'dhcp'
            anchor 'w'
            pack('side' => 'top', 'fill' => 'x')
          end
        end
      end
      TkFrame.new(p) do |p|
        pack('side' => 'top', fill: 'both', expand: true)
        TkLabelFrame.new(p) do |p|
          text 'Hardware Information'
          borderwidth 1
          pack('side' => 'left', fill: 'both', expand: true)
          TkLabelFrame.new(p) do |p|
            borderwidth 0
            pack('side' => 'top', fill: 'both', expand: true)
            TkLabel.new(p) do
              text 'Firmware Version'
              pack('side' => 'left', fill: 'both', expand: true)
            end
            gui.firmware = TkLabel.new(p) do
              pack('side' => 'left', fill: 'both', expand: true)
            end
          end
          TkLabelFrame.new(p) do |p|
            borderwidth 0
            pack('side' => 'top', fill: 'both', expand: true)
            TkLabel.new(p) do
              text 'Device'
              pack('side' => 'left', fill: 'both', expand: true)
            end
            gui.device_name = TkLabel.new(p) do
              pack('side' => 'left', fill: 'both', expand: true)
            end
          end
          gui.name = TkLabel.new(p) do
            wraplength 200
            pack('side' => 'left', fill: 'both', expand: true)
          end
        end
        TkLabelFrame.new(p) do |p|
          text 'Commands'
          borderwidth 1
          pack('side' => 'left', fill: 'both', expand: true)
          gui.setting_items << TkButton.new(p) do
            text 'Update Network Settings'
            pack(fill: 'both', expand: true)
          end
          gui.setting_items << TkButton.new(p) do
            text 'Firmware Update'
            pack(fill: 'both', expand: true)
          end
        end
      end
      TkFrame.new(p) do |p|
        pack('side' => 'top', fill: 'both', expand: true)
        TkLabelFrame.new(p) do |p|
          text 'Network Adapter IP Address'
          borderwidth 1
          pack('side' => 'left', fill: 'both', expand: true)
        end
        TkLabelFrame.new(p) do |p|
          text 'Network Adapter Subnet Mask'
          borderwidth 1
          pack('side' => 'left', fill: 'both', expand: true)
          adapter_mask = TkLabel.new(p) do
            text 'hello'
            pack('side' => 'left', fill: 'both', expand: true)
          end
        end
      end
    end
  end
  TkLabelFrame.new(p) do |p|
    text 'Messages'
    borderwidth 1
    pack('side' => 'bottom', fill: 'both', expand: true)
    gui.msgs = Tk::Tile::Treeview.new(p) do |p|
      pack(side: 'left', fill: 'y', expand: true)
      p['columns'] = 'type source message'
      p.heading_configure('#0', text: 'Time')
      p.heading_configure(:type, text: 'Type')
      p.heading_configure(:source, text: 'Source')
      p.heading_configure(:message, text: 'ArtNet Message')
    end
    TkScrollbar.new(p) do |scroll|
      pack(side: 'right', fill: 'y')
      command do |*idx|
        gui.msgs.yview(*idx)
      end
      gui.msgs.yscroll proc { |*idx|
        set(*idx)
      }
    end
  end
end

def gui.disable
  new_ip.value = ''
  new_netmask.value = ''
  new_gateway.value = ''
  net_mode.value = ''
  setting_items.each do |item|
    item.state :disabled
  end
end

def gui.name_window(type)
  self.new_name ||= TkVariable.new
  new_name = self.new_name
  new_name.value = type == :short ? node.shortname : node.longname
  gui = self
  win = TkToplevel.new(root) do |p|
    title 'Edit Art-Net Node Name'
    set_focus
    grab
    transient(root)
    TkLabel.new(p) do
      text type == :short ? 'Short Name (17 character max)' : 'Long Name (63 character max)'
      pack('side' => 'top', fill: 'both', expand: true)
    end
    Tk::Tile::Entry.new(p) do
      textvariable new_name
      pack('side' => 'top', fill: 'both', expand: true)
    end
    TkFrame.new(p) do |p|
      pack('side' => 'top', fill: 'both', expand: true)
      TkButton.new(p) do
        text 'OK'
        command proc {
          packet = ArtNet::Packet::Address.new
          packet.short_name = gui.node.shortname
          packet.long_name = gui.node.longname
          if type == :short
            packet.short_name = new_name.value
          else
            packet.long_name = new_name.value
          end
          gui.artnet.transmit packet, gui.node
          win.destroy
        }
        pack(side: 'left', fill: 'both', expand: true)
      end
      TkButton.new(p) do
        text 'Cancel'
        command proc {win.destroy}
        pack(side: 'left', fill: 'both', expand: true)
      end
    end
  end
end

gui.devices.bind('<TreeviewSelect>') do |e|
  ip = e.widget.selection.first.id
  node = artnet.node(ip)
  gui.node = node
  gui.ip.text = node.ip
  gui.mac.text = node.mac
  gui.name.text = node.longname
  gui.firmware.text = node.firmware_version
  if true # unknown device
    gui.device_name.text = 'Unknown Device'
    gui.disable
  end
end
gui.artnet = artnet
gui.disable
gui.thread = Thread.new do
  Tk.mainloop
end
artnet.on :node_update do |nodes|
  gui.devices.children('').each {|c| gui.devices.delete c }
  nodes.each do |node|
    gui.devices.insert nil, :end, text: node.ip, values: [node.shortname], id: node.ip
  end
end
artnet.on :message do |packet|
  if !(ArtNet::Packet::DMX === packet)
    type = (packet.sender_ip == artnet.local_ip ? 'Transmitted' : 'Received')
    gui.msgs.insert nil, :end, text: packet.received_at, values: [type, packet.sender_name, packet.type]
  end
end
artnet.poll_nodes
while(gui.thread.alive?) do
  artnet.process_events
  sleep 0.1
end

