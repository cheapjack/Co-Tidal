//Code written with support of Chris Ball www.chrisballprojects.co.uk July 16

//import java.until to be able to use Calndar object

import java.util.*;


//creates a calandar with the current date and locale
Calendar c = Calendar.getInstance();

//set calendar date to a specific date i.e Birthday
c.set(1981, 3, 15, 0, 0, 0);

//print info in standrad date format
println(c.getTime());

//print info as unix epoch timestap, divide by 1000 as result is millisecond offset from Epoch  https://docs.oracle.com/javase/7/docs/api/java/util/Calendar.html#DATE) 
println(c.getTime().getTime()/1000);

//variable to store UnixTime (large number)
long UnixTime=c.getTime().getTime()/1000;

//create Floats for specified locationg, lat and long i.e Oslo
float Latitude=59.903792;
float Longitude=10.700992;

//set intergers Length of time to create report for (number of seconds in 24 hrs), step is interval of readings in secs
int Length=24*3600;
int Step=3600;

//creating the url as a string to call data
String URLQuery=
 "https://www.worldtides.info/api?heights&lat=" + Latitude + 
 "&lon=" + Longitude +
 "&start=" + UnixTime +
 "&length=" + Length +
 "&step=" + Step +
 "&key=3e121dbf-988e-4c22-996a-9147f70814cc";//my unique key change if new log in

//set up a String array whihc holds the retruned text from the url
String[] Results=loadStrings(URLQuery);

//have to find the square brackets on the string, start and end, isolate the json table inside it
int start=Results[0].indexOf('[');
int end=Results[0].indexOf(']');

//new rray to hold the isolated json data, set array length to '1', in order to save the file e have to create an array of strings and the dat is only one string long even with multiple results
String[] JSONTable=new String[1];
//first and only string in array is to be the substring between the square brackets, +1 ensures end bracket is included
JSONTable[0] =  Results[0].substring(start, end+1);

//save copy of the table as results.json
saveStrings("results.json", JSONTable);

//load the saved file as a Json array object
JSONArray TideData=loadJSONArray("results.json");


for (int i = 0; i < TideData.size(); i++) { //for loop

 JSONObject TideHeight = TideData.getJSONObject(i); //create an object called TideHeight to store entry

 float data = TideHeight.getFloat("height");//get value of height from it
 println(data);
}
