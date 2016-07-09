require 'tk'
require 'art_net'
require 'ostruct'

artnet = ArtNet::IO.new :network => "192.168.0.100", :netmask => "255.255.255.0"
gui = OpenStruct.new
TkRoot.new do |p|
  title "eDMX Configuration"

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
          p.heading_configure('#0', text: 'IP')
          p.heading_configure(:name, text: 'Name')
          pack(side: 'left', fill: 'both', expand: true)
          #insert 0, *["yellow", "gray", "green"]*10
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
          mac = TkLabel.new(p) do
            text 'hello'
            pack('side' => 'left', fill: 'both', expand: true)
          end
        end
        TkLabelFrame.new(p) do |p|
          text 'Device IP Address'
          borderwidth 1
          pack('side' => 'left', fill: 'both', expand: true)
          ip = TkLabel.new(p) do
            text 'hello'
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
          TkLabel.new(p) do
            text 'Ip Address'
            pack('side' => 'top', fill: 'both', expand: true)
          end
          TkLabel.new(p) do
            text 'Subnet Mask'
            pack('side' => 'top', fill: 'both', expand: true)
          end
          TkLabel.new(p) do
            text 'Default Gateway'
            pack('side' => 'top', fill: 'both', expand: true)
          end
        end
        TkLabelFrame.new(p) do |p|
          text 'Network Mode'
          borderwidth 1
          pack('side' => 'left', fill: 'both', expand: true)
          TkRadioButton.new(p) do
            text '2.X.Y.Z'
            variable $v
            value '2.X.Y.Z'
            anchor 'w'
            pack('side' => 'top', 'fill' => 'x')
          end
          TkRadioButton.new(p) do
            text '10.X.Y.Z'
            variable $v
            value '10.X.Y.Z'
            anchor 'w'
            pack('side' => 'top', 'fill' => 'x')
          end
          TkRadioButton.new(p) do
            text 'Custom IP'
            variable $v
            value 'custom'
            anchor 'w'
            pack('side' => 'top', 'fill' => 'x')
          end
          TkRadioButton.new(p) do
            text 'DHCP'
            variable $v
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
        end
        TkLabelFrame.new(p) do |p|
          text 'Commands'
          borderwidth 1
          pack('side' => 'left', fill: 'both', expand: true)
          TkButton.new(p) do
            text 'Update Network Settings'
            pack(fill: 'both', expand: true)
          end
          TkButton.new(p) do
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
    msgs = Tk::Tile::Treeview.new(p) do |p|
      pack(side: 'left', fill: 'y', expand: true)
      p['columns'] = 'type source message'
      p.heading_configure('#0', text: 'Time')
      p.heading_configure(:type, text: 'Type')
      p.heading_configure(:source, text: 'Source')
      p.heading_configure(:message, text: 'ArtNet Message')
      p.insert(nil, :end, text: 1, values: [2,3,4])
      p.insert(nil, :end, text: 1, values: [2,3,4])
      p.insert(nil, :end, text: 1, values: [2,3,4])
      p.insert(nil, :end, text: 1, values: [2,3,4])
      p.insert(nil, :end, text: 1, values: [2,3,4])
      p.insert(nil, :end, text: 1, values: [2,3,4])
      p.insert(nil, :end, text: 1, values: [2,3,4])
      p.insert(nil, :end, text: 1, values: [2,3,4])
      p.insert(nil, :end, text: 1, values: [2,3,4])
      p.insert(nil, :end, text: 1, values: [2,3,4])
      p.insert(nil, :end, text: 1, values: [2,3,4])
      p.insert(nil, :end, text: 1, values: [2,3,4])
    end
    TkScrollbar.new(p) do |scroll|
      pack(side: 'right', fill: 'y')
      command do |*idx|
        msgs.yview(*idx)
      end
      msgs.yscroll proc { |*idx|
        set(*idx)
      }
    end
  end
end
gui.thread = Thread.new do
  Tk.mainloop
end
artnet.on :node_update do |nodes|
  gui.devices.children('').each {|c| gui.devices.delete c }
  nodes.each do |node|
    puts node.ip
    gui.devices.insert nil, :end, text: node.ip, values: [node.shortname]
  end
end
artnet.poll_nodes
while(gui.thread.alive?) do
  artnet.process_events
  sleep 0.1
end

