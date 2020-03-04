get '/packets' do
  @netpackets = NetPackets.all
  @debugindex = @netpackets.length
  haml :packets_index
end

get '/debug' do
  # @wordlist = Wordlists.new
  # hash = rand(36**8).to_s(36)
  # wordlist = Wordlists.new
  # wordlist.type = 'dynamic'
  # wordlist.scope = 'hashfile'
  # wordlist.name = 'DYNAMIC [hashfile] - '
  # wordlist.path = 'control/wordlists/wordlist-' + hash + '.txt'
  # wordlist.size = 0
  # wordlist.checksum = nil
  # wordlist.lastupdated = Time.now
  # wordlist.save
  # redirect to("/home")
  netpacket = NetPackets.new
  netpacket.starttime = Time.new
  netpacket.stoptime = Time.new + 5
  netpacket.srcip = "192.168.0.2"
  netpacket.dstip = "192.168.0.2"
  netpacket.srcport = 3300
  netpacket.dstport = 3301
  netpacket.packets = 5
  netpacket.save
  redirect to("/home")
end