// let debugString = "1000-12-12T01:32:00.000Z"
let formZtoUTC = function(data){
  let arr = data.split('T')
  console.log(arr)
  let dateStr = arr[0]
  let timeStr = arr[1]
  timeStr = timeStr.split('.')[0];
  let dateArr = dateStr.split('-');
  let timeArr = timeStr.split(':');
  console.log(dateArr)
  let result = ""
  for(let i = 0 ; i < 2; ++i){
    result += dateArr[i];
    result += '-'
  }
  result += dateArr[2]
  result += " "
  for(let i = 0 ; i < 2; ++i){
    result += timeArr[i];
    result += ':'
  }
  result += dateArr[2]
  result += " UTC"
  return result
}
let STARTTIME_INDEX = 0;
let STOPTIME_INDEX = 1;
let SRCIP_INDEX = 2;
let SRCPORT_INDEX = 3;
let DSTIP_INDEX = 4;
let DSTPORT_INDEX = 5;
let PACKETS_INDEX = 6;
let refreshViewByTheData = function(datas){
  for(let i = 0 ; i < datas.length ; ++i){
    element = document.getElementById(datas[i].id)
    //to find the data which is needed to be changed
    if(element != null){
      console.log(typeof datas[i].starttime)
      element.children[STARTTIME_INDEX].innerText = formZtoUTC(datas[i].starttime)
      element.children[STOPTIME_INDEX].innerText = formZtoUTC(datas[i].stoptime)
      element.children[SRCIP_INDEX].innerText = datas[i].srcip;
      element.children[SRCPORT_INDEX].innerText = datas[i].srcport;
      element.children[DSTIP_INDEX].innerText = datas[i].dstip;
      element.children[DSTPORT_INDEX].innerText = datas[i].dstport;
      element.children[PACKETS_INDEX].innerText = datas[i].packets;
    }
  }
}
let getDataFromServer = function(){
  console.log("I'm going to get data from the server");
  // $.ajax({
  //   url:"/net_packets/refresh",
  //   data:null,
  //   method:"POST",
  //   success:function(data){
  //     console.log("success!!")
  //     console.log(data)
  //     refreshViewByTheData(data)
  //   },
  //   error:function(){
  //     console.log("failed!!")
  //     clearInterval(clock)
  //   }
  // })
}