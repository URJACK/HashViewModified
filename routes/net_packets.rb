PacketsConfig = JSON.parse(File.read('config/packets_config.json'))
PageSize = PacketsConfig['pagesize'].to_i
MessageSurvivingTime = PacketsConfig['messagesurvivingtime'].to_i
ExecGatherFilePath = PacketsConfig['execgatherfilepath']
CodeError = 233
GatherThreadIdPool = {}
GatherCountsPool = {}
gatheringOperationId = 0;

# "Status" means that the instance object of the "Operation" class is in the "Off" or "Open" state"
StatusOpen = 1
StatusClose = 0
# draw the basic url's view
get '/packets' do
  opid = params[:opid].to_i
  # pageid is different from opid,its default value is 1,
  page = params[:page]
  if page == nil
    page = 1
  end
  page = page.to_i
  # process this specific situation
  if opid == 0
    opid = nil
  end
  if opid == nil
    if GatherCountsPool[0] == nil
      GatherCountsPool[0] = NetPackets.fetch("SELECT COUNT(id) AS len FROM netpackets;")[0][:len]
    end
    @netpackets = NetPackets.limit(PageSize).offset((page - 1) * PageSize)
    @pageid = page
    @opid = opid
    @pagesize = PageSize
    @packetscount = GatherCountsPool[0]
    haml :packets_index
  else
    @operation = Operations.find(id: opid)
    if @operation != nil
      if GatherCountsPool[opid] == nil
        GatherCountsPool[opid] = NetPackets.fetch("SELECT COUNT(id) AS len FROM netpackets WHERE opid = ?;",opid)[0][:len]
      end
      @netpackets = NetPackets.where(opid: opid).limit(PageSize).offset((page - 1) * PageSize)
      @pageid = page
      @opid = opid
      @pagesize = PageSize
      @packetscount = GatherCountsPool[opid]
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
  if @opid != nil && @opid != ""
    @netpackets = NetPackets.fetch("SELECT * FROM netpackets WHERE (srcip = ? OR srcport = ? OR dstip = ? OR dstport = ?) AND opid = ? limit ? offset ?;", @data,@data,@data,@data,@opid,PageSize,(page - 1) * PageSize)
  else
    @netpackets = NetPackets.fetch("SELECT * FROM netpackets WHERE srcip = ? OR srcport = ? OR dstip = ? OR dstport = ? limit ? offset ?;", @data,@data,@data,@data,PageSize,(page - 1) * PageSize)
  end  
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
  netpacket.pcappath = params[:pcappath].gsub("&#x2F;","/")
  netpacket.type = params[:type]
  netpacket.opid = params[:opid]
  opid = params[:opid].to_i
  if netpacket.save
    msg = Messages.new
    msg.pid = netpacket.id;
    msg.deadtime = Time.new + MessageSurvivingTime
    msg.save
    if GatherCountsPool[0] == nil
      GatherCountsPool[0] = NetPackets.fetch("SELECT COUNT(id) AS len FROM netpackets;")[0][:len]
    else
      GatherCountsPool[0] = GatherCountsPool[0] + 1;
    end
    if GatherCountsPool[opid] != nil
      GatherCountsPool[opid] = GatherCountsPool[opid] + 1
    else
      GatherCountsPool[opid] = NetPackets.fetch("SELECT COUNT(id) AS len FROM netpackets WHERE opid = ?;",opid)[0][:len]
    end
    if params[:ajax].to_i == 0
      redirect "/packets?opid=#{params[:opid]}"
    else
      return netpacket.id.to_s
    end
  else
    if params[:ajax].to_i == 0
      @err = "saving data is not successful"
      haml :packets_error
    else
      return false.to_s
    end
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
    netpacket[:pcappath] = params[:pcappath].gsub("&#x2F;","/")
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
  # opid will probably be nil or ""
  opid = params[:opid]
  if opid == nil
    opid = ""
  end
  if netpacket != nil
    netpacket.destroy
    redirect to("/packets?opid=#{opid}")
  else
    @err = "this record can't be delete,probably it had been removed just now, id:'#{params[:id]}'"
    haml :packets_error
  end
end

# initialize the constant params
Method_Id = 0
Method_SrcIp = 1
Method_DstIp = 2
Method_Time = 3
Method_Protocol = 4
# this variable(ExportFilePath) probably need to be changed by each machine
ExportFilePath = PacketsConfig['exportfilepath']
RequestFilePath = "https://127.0.0.1:4567/packets/download?file="

# the method
post '/packets/export' do
  # get form data from the frontend
  methodindex = params[:methodindex]
  opid = params[:opid]
  fromid = params[:fromid]
  toid = params[:toid]
  srcip = params[:srcip]
  dstip = params[:dstip]
  fromtime = params[:fromtime]
  totime = params[:totime]
  protocol = params[:protocol]
  # fileId.tar will be created
  fileId = (rand*100).to_i
  if methodindex.to_i == Method_Id
    packets = NetPackets.fetch("SELECT * FROM netpackets WHERE id >= ? AND id <= ?",fromid,toid)
  elsif methodindex.to_i == Method_SrcIp
    packets = NetPackets.fetch("SELECT * FROM netpackets WHERE srcip = ?",srcip)
  elsif methodindex.to_i == Method_DstIp
    packets = NetPackets.fetch("SELECT * FROM netpackets WHERE dstip = ?",dstip)
  elsif methodindex.to_i == Method_Time
    packets = NetPackets.fetch("SELECT * FROM netpackets WHERE starttime >= ? AND stoptime <= ?",fromtime,totime)
  elsif methodindex.to_i == Method_Protocol
    packets = NetPackets.fetch("SELECT * FROM netpackets WHERE protocols = ?",protocol)
  else
    return ""
  end
  tarStr = "tar zcvf #{ExportFilePath}#{fileId}.tar"
  if packets != nil
    packets.each do |pkt|
      arr = pkt[:pcappath].split('/')
      if arr.size == 0
        # it means it didn't have the pcappath
        break
      end
      fileStr = arr[arr.size - 1]
      dirStr = ""
      arr.each do |ele|
        if ele != fileStr
          dirStr += '/'
          dirStr += ele
        end
      end
      tarStr += " -C #{dirStr} #{fileStr}"
    end
    `#{tarStr}`
    return "#{RequestFilePath}#{fileId}.tar"
  else
    return ""
  end
end

get '/packets/download' do
  file = params[:file]
  send_file("#{ExportFilePath}#{file}",
  filename: file,
  type: "application/octet-stream")
end

# the method of telling the server to start an operation(if this operation is not exist,a new operation will be created)
post '/packets/gather' do
  # methodindex will be send to the worker,means which method will be selected,but in the development environment,this param will be back to the frontend,
  # the frontend will use this param to simulate the different process of receiving packets
  result = {}

  if gatheringOperationId == 0
    methodindex = params[:methodindex]
    dstip = params[:dstip]
    gateway = params[:gateway]
    operation = Operations.new
    operation[:starttime] = Time.new
    operation[:status] = StatusOpen
    operation[:methodindex] = methodindex
    operation.save
    # @netpackets = []
    # @pageid = 1
    # @opid = operation.id
    # @pagesize = PageSize
    # @packetscount = 0
    # create a sub process to gather infomation,and push its id into the "GTIP"
    GatherThreadIdPool[operation.id] = spawn("#{ExecGatherFilePath} #{operation.id}")
    gatheringOperationId = operation.id;
    result["status"] = true;
    result["id"] = gatheringOperationId;
    return result.to_json
  else
    result["status"] = false;
    result["id"] = gatheringOperationId;
    return result.to_json;
  end
end

get '/packets/turntogather' do
  if gatheringOperationId != 0
    @netpackets = NetPackets.where(opid: gatheringOperationId).limit(PageSize)
    @packetscount = NetPackets.fetch("SELECT COUNT(id) AS len FROM netpackets WHERE opid = ?;",gatheringOperationId)[0][:len]
    @pageid = 1
    @opid = gatheringOperationId
    @pagesize = PageSize
    haml :packets_index
  else
    @err = "there's no gathering running,you can start a new gathering"
    haml :packets_error
  end
end

# this method will stop the specified "Operation" object
post '/packets/stopgather' do
  opid = params[:opid].to_i
  if opid == gatheringOperationId
    gatheringOperationId = 0;
  end
  operation = Operations.find(id: opid)
  if operation != nil
    methodindex = operation[:methodindex]
    operation[:stoptime] = Time.new
    operation[:status] = false
    pid = GatherThreadIdPool[opid]
    # to stop the sub process
    if pid != nil
      `kill #{pid}`
      GatherThreadIdPool.delete(opid)
    end
    operation.save
    # to set the status as "close" is successful
    redirect '/packets'
  else
    # can't find the right "Operation" instance object
    @err = "this operation has lost"
    haml :packets_error
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
  results = {}
  arr = []
  opid = params[:opid].to_i
  len = GatherCountsPool[opid]
  # if the len didn't initialize,we will initialize it by searching some datas from the mysql
  if len == nil
    len = NetPackets.fetch("SELECT COUNT(id) AS len FROM netpackets WHERE opid = ?;",opid)[0][:len]
  end
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
      arr.push packet
    end
  end
  results["arr"] = arr
  results["len"] = len
  return results.to_json
end

get '/packets/debug' do
  @data = params[:data]
  haml :packets_debug
end

post '/packets/debug2' do
  datas = NetPackets.fetch("SELECT COUNT(id) as len from netpackets;")
  return datas[0][:len].to_s
end