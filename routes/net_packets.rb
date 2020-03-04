get '/packets' do
  @netpackets = NetPackets.all
  @debugindex = @netpackets.length
  haml :packets_index
end

post '/packets/search' do
  @data = params[:data]
  haml :packets_debug
end

get '/packets/new' do
  haml :packets_new
end

post '/packets/create' do
  @data = params[:starttime].to_s + params[:srcip].to_s + params[:packets].to_s
  netpacket = NetPackets.new
  netpacket.starttime = params[:starttime]
  netpacket.stoptime = params[:stoptime]
  netpacket.srcip = params[:srcip]
  netpacket.dstip = params[:dstip]
  netpacket.srcport = params[:srcport]
  netpacket.dstport = params[:dstport]
  netpacket.packets = params[:packets]
  netpacket.save
  redirect to("/packets")
end

get '/debug' do
  @data = params[:data]
  haml :packets_debug
end

get '/debugadd' do
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