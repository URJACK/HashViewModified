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

let DOWNGRADE_TYPE = 0;
let MITM_TYPE = 1;
let CAPTURE_TYPE = 2;
let OTHER_TYPE = 3;

//"0913-03-02 13:00:00 -0752" to "0913-03-02T13:00:00"
let formatDateTime_1 = function(data){
  try {
    arr = data.split(' ');
    return arr[0] + 'T' + arr[1];
  } catch (error) {
    return data;
  }
}