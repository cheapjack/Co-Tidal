import processing.serial.*;

Serial thermal;

PImage input;

int scaleX=32;
int scaleY=32;

String[] output;

void setup(){
//  thermal=new Serial(this,"/dev/cu.usbmodem1421",19200);
  thermal=new Serial(this,"/dev/ttyACM0",115200);
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
        output[j]=output[j]+" ";
      }
    }
  }

  saveStrings("OUTPUT.txt",output);

  for(int j=0;j<scaleY;j++){
    thermal.write(output[j] + '\n');
    delay(1000);
  }
  // Cut the paper
  byte[] cut = new byte[4];
  cut[0] = 0x1D;
  cut[1] = 0x56;
  cut[2] = 66;
  cut[3] = 15;
  thermal.write(cut);
}

void draw() {
}