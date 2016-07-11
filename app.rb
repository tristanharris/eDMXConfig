require 'tk'
require 'art_net'
require 'ostruct'
require_relative 'settings'
require_relative 'snapshot'

ArtNet::Packet.register Settings
ArtNet::Packet.register SettingsReply
ArtNet::Packet.register Snapshot

TkOption.add '*tearOff', 0

local_ips = Socket.getifaddrs.select{|a| a.addr.ipv4? && !a.addr.ipv4_loopback?}
artnet = ArtNet::IO.new :network => local_ips[0].addr.ip_address, :netmask => local_ips[0].netmask.ip_address
gui = OpenStruct.new
gui.setting_items = []
gui.ports = []
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
        command proc {
          gui.reset
          gui.artnet.poll_nodes
        }
      end
    end

    gui.tabs = Tk::Tile::Notebook.new(p) do |p|
      pack('side' => 'left', fill: 'both', expand: true)
      network = TkFrame.new(p) do |p|
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
              value '1'
              anchor 'w'
              pack('side' => 'top', 'fill' => 'x')
            end
            gui.setting_items << TkRadioButton.new(p) do
              text '10.X.Y.Z'
              variable gui.net_mode
              value '2'
              anchor 'w'
              pack('side' => 'top', 'fill' => 'x')
            end
            gui.setting_items << TkRadioButton.new(p) do
              text 'Custom IP'
              variable gui.net_mode
              value '0'
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
              command proc {
                packet = Settings.new
                packet.mac = gui.node.mac
                packet.ip = ::IPAddr.new(gui.new_ip.value,  Socket::AF_INET)
                packet.netmask = ::IPAddr.new(gui.new_netmask.value,  Socket::AF_INET)
                packet.gateway = ::IPAddr.new(gui.new_gateway.value,  Socket::AF_INET)
                packet.netmode = gui.net_mode.value.to_i
                packet.ports = gui.ports.map do |port|
                  translate_port(port)
                end
                packet.update! :network
                gui.artnet.transmit packet, gui.node
              }
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
            gui.adapter_ip = Tk::Tile::Combobox.new(p) do
              values local_ips.map{|a| a.addr.ip_address}
              pack('side' => 'left', fill: 'both', expand: true)
              state :readonly
              set artnet.local_ip
              bind("<ComboboxSelected>") do |*l|
                gui.adapter_ip.selection_clear
                gui.adapter_mask.text = gui.artnet.netmask
                gui.reset
                gui.artnet.reconnect(local_ips[current].addr.ip_address, local_ips[current].netmask.ip_address)
              end
            end
          end
          TkLabelFrame.new(p) do |p|
            text 'Network Adapter Subnet Mask'
            borderwidth 1
            pack('side' => 'left', fill: 'both', expand: true)
            gui.adapter_mask = TkLabel.new(p) do
              text artnet.netmask
              pack('side' => 'left', fill: 'both', expand: true)
            end
          end
        end
      end
      p.add network, text: 'Network'
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

def gui.reset
  disable
  devices.children('').each {|c| devices.delete c }
  (tabs.tabs.count - 1).times do
    tabs.forget(1)
  end
  ports.clear
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

def gui.port_tab(port)
  gui = self
  vars = OpenStruct.new
  frame = TkFrame.new(tabs) do |p|
    TkLabelFrame.new(p) do |p|
      text 'ArtNet Settings'
      borderwidth 1
      pack('side' => 'top', fill: 'both', expand: true)
      TkFrame.new(p) do |p|
        pack('side' => 'top', fill: 'both', expand: true)
        TkLabel.new(p) do
          pack('side' => 'left', fill: 'both', expand: true)
          text 'Update Rate'
        end
        scale = Tk::Tile::Scale.new(p) do
          pack('side' => 'left')
          orient 'horizontal'
          length 200
          from 1
          to 40
          variable vars.update_rate = TkVariable.new(port.update_rate)
        end
        value = TkLabel.new(p) do
          pack('side' => 'left', fill: 'both', expand: true)
          text port.update_rate.to_s + 'Hz'
        end
        scale.command proc{|v|
          value.text v.to_i.to_s + 'Hz'
        }
      end
      TkFrame.new(p) do |p|
        pack('side' => 'top', fill: 'both', expand: true)
        TkLabel.new(p) do
          pack('side' => 'left', fill: 'both', expand: true)
          text 'Broadcast Threshold'
        end
        scale = Tk::Tile::Scale.new(p) do
          pack('side' => 'left')
          orient 'horizontal'
          length 200
          from 0
          to 20
          set port.broadcast_threshold
        end
        value = TkLabel.new(p) do
          pack('side' => 'left', fill: 'both', expand: true)
          text port.broadcast_threshold.to_s
        end
        scale.command proc{|v|
          value.text v.to_i.to_s
        }
      end
    end
    TkFrame.new(p) do |p|
      pack('side' => 'top', fill: 'both', expand: true)
      TkLabelFrame.new(p) do |p|
        text 'Merge Mode'
        borderwidth 1
        pack('side' => 'left', fill: 'both', expand: true)
        vars.merge_mode = TkVariable.new port.merge_mode
        TkRadioButton.new(p) do
          text 'Highest Takes Priority (HTP)'
          variable vars.merge_mode
          value :htp
          anchor 'w'
          pack('side' => 'top', 'fill' => 'x')
        end
        TkRadioButton.new(p) do
          text 'Latest Takes Priority (LTP)'
          variable vars.merge_mode
          value :ltp
          anchor 'w'
          pack('side' => 'top', 'fill' => 'x')
        end
        Tk::Tile::CheckButton.new(p) do
          text 'Timeout all sources'
          onvalue true
          offvalue false
          variable vars.timeout_sources = TkVariable.new(port.timeout_sources?)
          pack('side' => 'top', 'fill' => 'x')
        end
      end
      TkLabelFrame.new(p) do |p|
        text 'Operation Mode'
        borderwidth 1
        pack('side' => 'left', fill: 'both', expand: true)
        vars.operation_mode = TkVariable.new(port.operation_mode)
        TkRadioButton.new(p) do
          text 'DMX In Art-Net'
          variable vars.operation_mode
          value :artnet
          anchor 'w'
          pack('side' => 'top', 'fill' => 'x')
        end
        TkRadioButton.new(p) do
          text 'DMX In sACN'
          variable vars.operation_mode
          value :sacn
          anchor 'w'
          pack('side' => 'top', 'fill' => 'x')
        end
        TkRadioButton.new(p) do
          text 'DMX Out'
          variable vars.operation_mode
          value :dmx
          anchor 'w'
          pack('side' => 'top', 'fill' => 'x')
        end
      end
    end
    TkLabelFrame.new(p) do |p|
      text 'RDM Settings'
      borderwidth 1
      pack('side' => 'top', fill: 'both', expand: true)
      TkFrame.new(p) do |p|
        pack('side' => 'top', fill: 'both', expand: true)
        TkLabel.new(p) do
          pack('side' => 'left', fill: 'both', expand: true)
          text 'Discovery Period'
        end
        scale = Tk::Tile::Scale.new(p) do
          pack('side' => 'left')
          orient 'horizontal'
          length 200
          from 0
          to 600
          variable vars.rdm_discovery = TkVariable.new(port.rdm_discovery)
        end
        value = TkLabel.new(p) do
          pack('side' => 'left', fill: 'both', expand: true)
          text port.rdm_discovery.to_s + 's'
        end
        scale.command proc{|v|
          value.text v.to_i.to_s + 's'
        }
      end
      TkFrame.new(p) do |p|
        pack('side' => 'top', fill: 'both', expand: true)
        TkLabel.new(p) do
          pack('side' => 'left', fill: 'both', expand: true)
          text 'Packet Spacing'
        end
        scale = Tk::Tile::Scale.new(p) do
          pack('side' => 'left')
          orient 'horizontal'
          length 200
          from 0
          to 40
          variable vars.rdm_spacing = TkVariable.new(port.rdm_spacing)
        end
        value = TkLabel.new(p) do
          pack('side' => 'left', fill: 'both', expand: true)
          text port.rdm_spacing.to_s + '1/20s'
        end
        scale.command proc{|v|
          value.text v.to_i.to_s + ' 1/20s'
        }
      end
    end
    TkFrame.new(p) do |p|
      pack('side' => 'top', fill: 'both', expand: true)
      Tk::Tile::CheckButton.new(p) do
        text 'Recall DMX snapshot at startup'
        onvalue true
        offvalue false
        variable vars.recall_dmx = TkVariable.new(port.recall_dmx?)
        pack('side' => 'left', 'fill' => 'x')
      end
      TkButton.new(p) do
        text 'Snapshot DMX'
        command proc {
          packet = Snapshot.new
          packet.port_id = port.id
          gui.artnet.transmit packet, gui.node
        }
        pack(side: 'left', fill: 'both', expand: true)
      end
    end
    TkFrame.new(p) do |p|
      pack('side' => 'top', fill: 'both', expand: true)
      TkButton.new(p) do
        text 'Update'
        command proc {
          packet = Settings.new
          packet.ports = gui.ports.map do |port|
            translate_port(port)
          end
          packet.update! :ports
          gui.artnet.transmit packet, gui.node
        }
        pack(side: 'left', fill: 'both', expand: true)
      end
      TkLabelFrame.new(p) do |p|
        text 'Universe'
        borderwidth 1
        pack('side' => 'left', fill: 'both', expand: true)
        Tk::Tile::Entry.new(p) do
          textvariable vars.universe = TkVariable.new
          pack('side' => 'left', fill: 'both', expand: true)
        end
        TkLabelFrame.new(p) do |p|
          text 'Art-Net Address'
          borderwidth 0
          pack('side' => 'left', fill: 'both', expand: true)
          TkLabel.new(p) do
            vars.universe.trace :w, proc{|v|
              text '%04X' % (v.value.to_i - 1)
            }
            pack('side' => 'left', fill: 'both', expand: true)
          end
          vars.universe.value = port.addr + 1
        end
      end
    end
  end
  [frame, vars]
end

def translate_port(port)
  set_port = Settings::Port.new
  set_port.rdm_spacing = port.rdm_spacing.value.to_i
  set_port.rdm_discovery = port.rdm_discovery.value.to_i
  set_port.update_rate = port.update_rate.value.to_i
  set_port.addr = port.universe.value.to_i - 1
  set_port.merge_mode = port.merge_mode.value
  set_port.timeout_sources = port.timeout_sources.value == '1'
  set_port.recall_dmx = port.recall_dmx.value == '1'
  set_port.operation_mode = port.operation_mode.value
  set_port
end

gui.devices.bind('<TreeviewSelect>') do |e|
  ip = e.widget.selection.first.id
  node = artnet.node(ip)
  gui.node = node
  artnet.transmit Settings.new, node
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
    gui.msgs.insert nil, 0, text: packet.received_at, values: [type, packet.sender_name, packet.type]
    if SettingsReply === packet
      gui.new_ip.value = packet.ip
      gui.new_netmask.value = packet.netmask
      gui.new_gateway.value = packet.gateway
      gui.net_mode.value = packet.netmode
      (gui.tabs.tabs.count - 1).times do
        gui.tabs.forget(1)
      end
      gui.ports.clear
      packet.ports.each_with_index do |port, i|
        frame, vars = gui.port_tab(port)
        gui.ports[i] = vars
        gui.tabs.add frame, text: 'Port ' + (i+65).chr
      end
      gui.setting_items.each do |item|
        item.state :normal
      end
    end
  end
end
artnet.poll_nodes
while(gui.thread.alive?) do
  artnet.process_events
  sleep 0.1
end

