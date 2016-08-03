//Code written with support of Chris Ball www.chrisballprojects.co.uk July 1

import processing.serial.*;
import java.util.*;


Serial thermal;

PImage input;

int scaleX=24;
int scaleY=31;
String[] output;

char blackChar=')';
char whiteChar=' ';

float Latitude=59.903792;
float Longitude=10.700992;

Calendar c;

int Length=24*31*3600;
int Step=3600;


void setup() {

  c = Calendar.getInstance();

  c.set(1981, 3, 15, 0, 0, 0);
  println(c.getTime());
  println(c.getTime().getTime()/1000);
  long UnixTime=c.getTime().getTime()/1000;

  String URLQuery=
    "https://www.worldtides.info/api?heights&lat=" + Latitude + 
    "&lon=" + Longitude +
    "&start=" + UnixTime +
    "&length=" + Length +
    "&maxcalls=5" +
    "&step=" + Step +
    "&key=3e121dbf-988e-4c22-996a-9147f70814cc";


  String[] Results=loadStrings(URLQuery);

  //have to find the square brackets on the string, start and end, isolate the json table inside it
  int start=Results[0].indexOf('[');
  int end=Results[0].indexOf(']');

  String[] JSONTable=new String[1];
  JSONTable[0] =  Results[0].substring(start, end+1);

  saveStrings("results.json", JSONTable);

  JSONArray TideData=loadJSONArray("results.json");

  for (int i = 0; i < TideData.size(); i++) { //for loop

    JSONObject TideHeight = TideData.getJSONObject(i); //create an object called TideHeight to store entry

    float data = TideHeight.getFloat("height");//get value of height from it
    println(data);
  }




  thermal=new Serial(this, "/dev/cu.usbmodem1411", 19200);
  thermal.write("\n\n");
  delay(1000);

  input=loadImage("folkart.jpg");
  input.resize(scaleX, scaleY);
  input.filter(THRESHOLD);

  image(input, 0, 0);

  output=new String[scaleY];

  for (int j=0; j<scaleY; j++) {
    output[j]="";
    for (int i=0; i<scaleX; i++) {
      if (input.get(i, j)==color(0)) {
        output[j]=output[j]+blackChar;
      } else {
        output[j]=output[j]+whiteChar;
      }
    }
  }

  saveStrings("OUTPUT.txt", output);

  for (int j=0; j<scaleY; j++) {
    thermal.write(output[j] + '\n');
    delay(1000);
  }
}


void draw(){
  
}