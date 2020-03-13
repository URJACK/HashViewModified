PageSize = 5 
MessageSurvivingTime = 8
# "Status" means that the instance object of the "Operation" class is in the "Off" or "Open" state"
StatusOpen = 1
StatusClose = 0
CodeError = 233
# draw the basic url's view
get '/packets' do
  opid = params[:opid]
  # pageid is different from opid,its default value is 1,
  page = params[:page]
  if page == nil
    page = 1
  end
  page = page.to_i
  # process this specific situation
  if opid == ""
    opid = nil
  end
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
      @err = "this operation(opid:#{opid}) is not exist"
      haml :packets_error
    end
  end
end

# draw the search result's view
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

# draw the view of creating new net-packet 
get '/packets/new' do
  @opid = params[:opid]
  haml :packets_new
end

# the method of creating a new packet
post '/packets/create' do
  netpacket = NetPackets.new
  netpacket.starttime = params[:starttime]
  netpacket.stoptime = params[:stoptime]
  netpacket.srcip = params[:srcip]
  netpacket.dstip = params[:dstip]
  netpacket.srcport = params[:srcport]
  netpacket.dstport = params[:dstport]
  netpacket.packets = params[:packets]
  netpacket.protocols = params[:protocols]
  netpacket.sessionid = params[:sessionid]
  netpacket.indexname = params[:indexname]
  netpacket.info = params[:info]
  netpacket.pcappath = params[:pcappath]
  netpacket.type = params[:type]
  netpacket.opid = params[:opid]
  if netpacket.save
    msg = Messages.new
    msg.pid = netpacket.id;
    msg.deadtime = Time.new + MessageSurvivingTime
    msg.save
    redirect "/packets?opid=#{params[:opid]}"
    # return netpacket.id.to_s
  else
    @err = "saving data is not successful"
    haml :packets_error
    # return false.to_s
  end
end

# draw the view of editing a net-packet
get '/packets/edit' do
  @netpacket = NetPackets.find(id: params[:id].to_i)
  @opid = params[:opid]
  haml :packets_edit
end

# the method of updating a new net-packet
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
    netpacket[:protocols] = params[:protocols]
    netpacket[:sessionid] = params[:sessionid]
    netpacket[:indexname] = params[:indexname]
    netpacket[:info] = params[:info]
    netpacket[:pcappath] = params[:pcappath]
    netpacket[:type] = params[:type]
    if netpacket.save
      msg = Messages.new
      msg.pid = netpacket.id;
      msg.deadtime = Time.new + MessageSurvivingTime
      msg.save
      redirect to("/packets?opid=#{params[:opid]}")
    else
      @err = "this sequence can't be updated,id:#{params[:id]}"
      haml :packets_error
    end
  else
    @err = "this sequence is not exist,no id:#{params[:id]}"
    haml :packets_error
  end
end

# the method of destroy a net-packet
get '/packets/delete' do
  netpacket = NetPackets.find(id: params[:id].to_i)
  if netpacket != nil
    netpacket.destroy
    redirect to("/packets")
  else
    @err = "this record can't be delete,probably it had been removed just now, id:'#{params[:id]}'"
    haml :packets_error
  end
end

# the method of telling the server to start an operation(if this operation is not exist,a new operation will be created)
post '/packets/gather' do
  # methodindex will be send to the worker,means which method will be selected,but in the development environment,this param will be back to the frontend,
  # the frontend will use this param to simulate the different process of receiving packets
  methodindex = params[:methodindex]
  operation = Operations.new
  operation[:starttime] = Time.new
  operation[:status] = StatusOpen
  operation.save
  @netpackets = []
  @pageid = 1
  @opid = operation.id
  haml :packets_index
end

# this method will stop the specified "Operation" object
post '/packets/stopgather' do
  operation = Operations.find(id: params[:opid])
  if operation != nil
    operation[:stoptime] = Time.new
    operation[:status] = false
    operation.save
    # to set the status as "close" is successful
    return true
  else
    # can't find the right "Operation" instance object
    return false
  end
end

# this method will return the status of the specified "Operation" object
post '/packets/operationstatus' do
  operation = Operation.find(id: params[:opid])
  if operation != nil
    return operation[:status]
  else
    return CodeError
  end
end

post '/packets/refresh' do
  results = []
  msg = Messages.first
  if msg != nil
    while(Time.new > msg.deadtime)
      msg.destroy
      msg = Messages.first
      if(msg == nil)
        break
      end
    end
    msgs = Messages.all
    msgs.each do |ele|
      packet = NetPackets.find(id: ele[:pid])
      results.push packet
    end
  end
  return results.to_json
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