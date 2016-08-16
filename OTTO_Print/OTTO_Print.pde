import processing.serial.*;
import java.util.*;

Serial thermalCutter;
Serial thermalContinuous;

PImage input;
PImage original;

int scaleX=24;
int scaleY=31;
int displayScale = 20;
int myScreenWidth = displayScale*scaleX*2;
int myScreenHeight = displayScale*scaleY;

String[] output;

// Oslo
float Latitude=59.903792;
float Longitude=10.700992;

void setup(){
  size(960, 620);  // size always goes first!
  //  thermal=new Serial(this,"/dev/cu.usbmodem1421",19200);
  thermalCutter=new Serial(this,"/dev/ttyACM0",115200);
  thermalContinuous=new Serial(this,"/dev/ttyACM1",19200);
  thermalCutter.write("\n\n");
  thermalContinuous.write("\n\n");
  delay(1000);

  input=loadImage("OTTO_O.png");
  input.resize(scaleX,scaleY);
  input.filter(THRESHOLD);
  original=loadImage("OTTO_O.png");
  original.resize(displayScale*scaleX,displayScale*scaleY);
  original.filter(THRESHOLD);

  image(original,0,0);
}

// Where we'll store any calendar values as they're read in
String calendarBuffer = "";
// Months
String[] monthStrings = {
  "Januar", "Februar", "Mars", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Desember" };
int Length=24*31*3600;
int Step=3600;

void draw() {
  if (thermalCutter.available() > 0) {
    // There's something to read.
    char c = thermalCutter.readChar();
    if (c == '\n') {
      // We've reached the end of a line, so we'll have
      // a full <month>-<year> to deal with
      
      // Parse the calendarBuffer
      String[] cals = split(calendarBuffer, "-");
      // calendarBuffer will have a \r at the end, which
      // means that cals[1] will be <year>\r
      // This will confuse int(cals[1]) unless you trim()
      // cals[1] first!!!
      int month = int(cals[0]);
      int year = int(trim(cals[1]));
      println(monthStrings[month-1]);
      println(year);
    
      Calendar cal = Calendar.getInstance();
    
      cal.set(year, month-1, 1, 0, 0, 0);
      println(cal.getTime());
      println(cal.getTime().getTime()/1000);
      long UnixTime=cal.getTime().getTime()/1000;
    
      String URLQuery=
        "https://www.worldtides.info/api?heights&lat=" + Latitude + 
        "&lon=" + Longitude +
        "&start=" + UnixTime +
        "&length=" + Length +
        "&maxcalls=5" +
        "&step=" + Step +
        "&key=3e121dbf-988e-4c22-996a-9147f70814cc";
  
      println(URLQuery);
      String[] Results=loadStrings(URLQuery);
    
      //have to find the square brackets on the string, start and end, isolate the json table inside it
      int start=Results[0].indexOf('[');
      int end=Results[0].indexOf(']');
    
      String[] JSONTable=new String[1];
      JSONTable[0] =  Results[0].substring(start, end+1);
    
      saveStrings(year+"-"+month+"-results.json", JSONTable);
    
      JSONArray TideData=loadJSONArray(year+"-"+month+"-results.json");
    
      for (int i = 0; i < TideData.size(); i++) { //for loop
    
        JSONObject TideHeight = TideData.getJSONObject(i); //create an object called TideHeight to store entry
    
        float data = TideHeight.getFloat("height");//get value of height from it
        println(data);
      }

      
      output=new String[scaleY];
      // Show the resultant pattern on screen alongside the original
      PImage outImg = createImage(scaleX, scaleY, RGB);
      outImg.loadPixels();
      for(int j=0;j<scaleY;j++){
        output[j]="";
        for(int i=0;i<scaleX;i++){
          int newCol;
          if(input.get(i,j)==color(0)){
            newCol = 170;
          }else{
            newCol = 85;
          }
          JSONObject TideHeight = TideData.getJSONObject((scaleX*j)+i); //create an object called TideHeight to store entry
    
          float data = TideHeight.getFloat("height");//get value of height from it
          // Work out the colour for this pixel, by combining the pattern and the tide height
          // 450 is a useful multiplier given the range of tide heights we get
          // (process_json.rb is handy to help work this out)
          newCol = int((data*450)+newCol);
          outImg.set(i,j,newCol);
          if (newCol < 60) {
            output[j]=output[j]+" ";
          } else if (newCol > 150) {
            output[j]=output[j]+"X";
          } else {
            output[j]=output[j]+"~";
          }
        }
      }
      outImg.save(year+"-"+month+"-out.png");
      // Display the output
      outImg.resize(displayScale*scaleX,displayScale*scaleY);
      image(outImg,displayScale*scaleX,0);
      saveStrings("OUTPUT.txt",output);
// Simple disabling of printer output...
// Change this next line to "if (false) {" to stop printing
if (true) {    
      thermalContinuous.write("\n");
      thermalContinuous.write("### Co~Tidal... "+monthStrings[month-1]+" "+year+"\n");
      thermalContinuous.write("    http://currently.no\n\n");
      thermalCutter.write("### Co~Tidal... "+monthStrings[month-1]+" "+year+"\n");
      thermalCutter.write("    http://currently.no\n\n");
      // Print a guide row
      for (int i=0; i<scaleX; i++) {
        thermalCutter.write("#");
      }
      thermalCutter.write("\n");
      // Now output the pattern
      for(int j=0;j<scaleY;j++){
        thermalCutter.write(output[j] + '\n');
        thermalContinuous.write(output[j] + '\n');
        delay(1000);
      }
      
      // Print a guide row
      for (int i=0; i<scaleX; i++) {
        thermalCutter.write("#");
      }
      thermalCutter.write("\n");
      // Cut the paper
      byte[] cut = new byte[4];
      cut[0] = 0x1D;
      cut[1] = 0x56;
      cut[2] = 66;
      cut[3] = 5;
      thermalCutter.write(cut);
      thermalCutter.write("\n\n\n");
      thermalContinuous.write("\n\n");
}
      // Clear the buffer ready for next time
      calendarBuffer = "";
    } else {
      // Not the end of a line, just add it to our buffer
      calendarBuffer = calendarBuffer + c;
    }
  }
}