PageSize = 5 
get '/packets' do
  opid = params[:opid]
  # pageid is different from opid,its default value is 1,
  page = params[:page]
  if page == nil
    page = 1
  end
  page = page.to_i
  if opid == nil
    @netpackets = NetPackets.limit(PageSize).offset((page - 1) * PageSize)
    @pageid = page
    @opid = opid
    haml :packets_index
  else
    @operation = Operations.find(id: opid)
    if @operation != nil
      @netpackets = NetPackets.where(opid: opid).limit(PageSize).offset((page - 1) * PageSize)
      @pageid = page
      @opid = opid
      haml :packets_index
    else
      # @err = "this operation is not exist"
      # haml :packets_error
      @netpackets = []
      @pageid = page
      @opid = opid
      haml :packets_index
    end
  end
end

get '/packets/search' do
  @data = params[:data]
  @opid = params[:opid]
  page = params[:page]
  if page == nil
    page = 1
  end
  page = page.to_i
  @netpackets = NetPackets.fetch("SELECT * FROM netpackets WHERE srcip = ? OR srcport = ? OR dstip = ? OR dstport = ? limit ? offset ?;", @data,@data,@data,@data,PageSize,(page - 1) * PageSize)
  @pageid = page
  haml :packets_search
end

get '/packets/new' do
  haml :packets_new
end

post '/packets/create' do
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

get '/packets/edit' do
  @netpacket = NetPackets.find(id: params[:id].to_i)
  haml :packets_edit
end

post '/packets/update' do
  netpacket = NetPackets.find(id: params[:id].to_i)
  if netpacket != nil
    netpacket[:starttime] = params[:starttime]
    netpacket[:stoptime] = params[:stoptime]
    netpacket[:srcip] = params[:srcip]
    netpacket[:dstip] = params[:dstip]
    netpacket[:srcport] = params[:srcport]
    netpacket[:dstport] = params[:dstport]
    netpacket[:packets] = params[:packets]
    netpacket.save
    redirect to("/packets")
  else
    @err = "this sequence is not exist,no id:#{params[:id]}"
    haml :packets_error
  end
end

get '/packets/delete' do
  netpacket = NetPackets.find(id: params[:id].to_i)
  if netpacket != nil
    netpacket.destroy
    redirect to("/packets")
  else
    @err = "this sequence can't be delete, id:#{params[:id]}"
    haml :packets_error
  end
end

post '/packets/gather' do
  # methodindex will be send to the worker,means which method will be selected,but in the development environment,this param will be back to the frontend,
  # the frontend will use this param to simulate the different process of receiving packets
  methodindex = params[:methodindex]
  @netpackets = []
  @pageid = 1
  @opid = 1
  haml :packets_index
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