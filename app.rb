require 'tk'

TkRoot.new do |p|
  title "eDMX Configuration"

  TkFrame.new(p) do |p|
    pack('side' => 'top', fill: 'both', expand: true)
    TkLabelFrame.new(p) do |p|
      text 'eDMX devices'
      borderwidth 1
      pack('side' => 'left', fill: 'both', expand: true)
      TkListbox.new(p) do
        pack(fill: 'both', expand: true)
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
        end
        TkLabelFrame.new(p) do |p|
          text 'Network Mode'
          borderwidth 1
          pack('side' => 'left', fill: 'both', expand: true)
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
      pack(fill: 'both', expand: true)
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
  end
end
Tk.mainloop
