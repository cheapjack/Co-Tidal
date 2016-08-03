//Code written with support of Chris Ball www.chrisballprojects.co.uk July 1

import processing.serial.*;

Serial thermal;

PImage input;

int scaleX=31;
int scaleY=31;

String[] output;

void setup(){
thermal=new Serial(this,"/dev/cu.usbmodem1411",19200);
thermal.write("\n\n");
delay(1000);

input=loadImage("folkart.jpg");
input.resize(scaleX,scaleY);
input.filter(THRESHOLD);

image(input,0,0);

output=new String[scaleY];

for(int j=0;j<scaleY;j++){
  output[j]="";
  for(int i=0;i<scaleX;i++){
    if(input.get(i,j)==color(0)){
      output[j]=output[j]+"(";
    }else{
      output[j]=output[j]+".";
    }
  }
}

saveStrings("OUTPUT.txt",output);

for(int j=0;j<scaleY;j++){
  thermal.write(output[j] + '\n');
  delay(1000);
}
}





void draw(){




}