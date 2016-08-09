/*
  Uses Input Pullup Serial Example 
  http://www.arduino.cc/en/Tutorial/InputPullupSerial
  to read from an RS rotary number dial: 
  Connect the underlined pins _1, _2, _4, _8 to 4 digital INPUT_PULLUPs
  Connect C to GND with a 10K resistor

  Converts readings on 4 pins to decimal values 0-9 from binary and prints Month
  in Norwegian to serial

  Needs moving to a Mega and will need to read
  Month first digit (0 or 1) 1 pin
  Month second digit (0 - 9) 4 pins
  Year first digit (1 or 2) 2 pins
  Year second digit (1 to 9) 4 pins
  Year third digit (0 to 9) 4 pins
  Year fourth digit (0 to 9) 4 pins

  Total of 19 pins to read 
  
 This code is in the public domain

*/

// Pins that the year digits are connected to
const int kFirstDigitOnePin = 53;
const int kFirstDigitTwoPin = 52;
const int kSecondDigitOnePin = 51;
const int kThirdDigitOnePin = 47;
const int kFourthDigitOnePin = 43;
const int kMinYearDigitPin = 40;
const int kMaxYearDigitPin = 53;

// Analog pin to which the month carousel is connected
const int kMonthPin = A0;
const int kMonthThresholds[12] = { 930, 840, 752, 658, 556, 446, 344, 241, 146, 51, 3, 0 };
// Max and min analog values for the extremes of the carousel's travel
const int kMinCalendar = 10;
const int kMaxCalendar = 1010;

// "Take a reading" button details
// Expects a button which will pull the pin to ground when pressed
const int kButtonPin = 6;
unsigned long gButtonPressedTime;
int gLastButtonState = HIGH;
const int kButtonDebounce = 50;

// Status LED details
const int kLEDPin = 7;

#define PRINTER Serial2

void setup() {
  // Start serial
  Serial.begin(115200);
  delay(100);

  // Set up the printer
  PRINTER.begin(9600);

  // Configure year pins as inputs and enable the internal pull-up resistors
  for (int i = kMinYearDigitPin; i <= kMaxYearDigitPin; i++){
    pinMode(i, INPUT_PULLUP);
  }
  pinMode(kButtonPin, INPUT_PULLUP);
  
  // Setup status LED
  pinMode(kLEDPin, OUTPUT);
  digitalWrite(kLEDPin, HIGH);
  
#ifdef DEBUG
  Serial.println("Let's go!");
#endif
}

void loop() {
  // Check for the button being pressed
  int buttonState = digitalRead(kButtonPin);
  if ((buttonState == LOW) && (gLastButtonState != LOW))
  {
    // Button has been pressed, start timing when that happened
    gButtonPressedTime = millis();
  }
  else if ( (buttonState == HIGH) && 
            (gLastButtonState == LOW) &&
            ((millis() - gButtonPressedTime) > kButtonDebounce) )
  {
    // Button has been released (and was down long enough to be
    // a proper button press)

    // Read in the month
    int sensorValue = analogRead(kMonthPin);
    int month = 0;
    while (sensorValue < kMonthThresholds[month])
    {
      month++;
    }
    month++; // The array is 0-based, we want 1-based
  
    // print the results to the serial monitor:
#ifdef DEBUG
    Serial.print("sensor = " );
    Serial.print(sensorValue);
    Serial.print("\t month = ");
    Serial.println(month);
#endif
    
    // Read in what the year is
    int digit = 0;
    int year = 0;
    if (digitalRead(kFirstDigitOnePin) == LOW)
    {
      digit = 1;
    }
    if (digitalRead(kFirstDigitTwoPin) == LOW)
    {
      digit = 2;
    }
    year = digit;
    digit = readBinaryEncodedDigit(kSecondDigitOnePin, 4, -1);
    year = (year * 10) + digit;
    digit = readBinaryEncodedDigit(kThirdDigitOnePin, 4, -1);
    year = (year * 10) + digit;
    digit = readBinaryEncodedDigit(kFourthDigitOnePin, 4, -1);
    year = (year * 10) + digit;
#ifdef DEBUG
    Serial.print("Year: ");
    Serial.println(year);
#endif

    // Report it
    Serial.print(month);
    Serial.print("-");
    Serial.println(year);
  }
  gLastButtonState = buttonState;

  // Send any data to the printer
  while (Serial.available())
  {
    PRINTER.write(Serial.read());
  }
  
#if 0
  //read the pushbutton value into a byte variable
  byte sensorVal = digitalRead(2);
  byte sensorVal2 = digitalRead(3);
  byte sensorVal3 = digitalRead(4);
  byte sensorVal4 = digitalRead(5);
  
  //put the value of the readings in an array
  byte dials[] = {sensorVal4, sensorVal3, sensorVal2, sensorVal};
  // declare another byte thats more useful than a string of serial messages
  byte dialnumber = B0000;
  // loop through each position in the array, print it, use Bitwise OR to push into
  // dialnumber and then Bit shift it along to place the bits in the right spots
  for (int i = 0; i < 4; i++) {
    Serial.print(dials[i]);
    dialnumber |= dials[i] << (3 -i); 
  }
//tab over
  Serial.print("\t");
  // print the binary dialnumber in decimal
  Serial.print(dialnumber, DEC);
  Serial.print("\t");
  // Example switch case statements for months
  // dial number could feed into the Calendar instance c.set
  switch (dialnumber) {
    case 1:
      Serial.print("Januar");
      break;
    case 2:
      Serial.print("Februar");
      break;
    case 3:
      Serial.print("Mars");
      break;
    case 4:
      Serial.print("April");
      break;
    case 5:
      Serial.print("Kan");
      break;
    case 6:
      Serial.print("Juni");
      break;
    case 7:
      Serial.print("Juli");
      break;
    case 8:
      Serial.print("August");
      break;
    case 9:
      Serial.print("September");
      break;
    case 10:
      Serial.print("Oktober");
      break;
    case 11:
      Serial.print("November");
      break;
    case 12:
      Serial.print("November");
      break;
    case 15:
      Serial.print("Velg dato vennligst!");
      break;
    default:
      Serial.print("Velg dato vennligst!");
      break;
    }
#endif
  //Serial.println();
  //delay(8000);
}

// Read in a value from a binary-encoded rotary dial
// Assumes the pin is LOW when selected
// Assumes the pins are all wired up sequentially
//
// Parameters:
//   aOnePin - pin that the 1 bit is wired to
//   aNumBits - how many bits this encoder has
//   aPinSequenceDirection - value to add to a pin to get to the
//                           next bit's pin.  Usually 1, but -1
//                           if your bits are wired "backwards"
// Returns the value read in
int readBinaryEncodedDigit(int aOnePin, int aNumBits, int aPinSequenceDirection)
{
  int ret = 0;
  for (int i = 0; i < aNumBits; i++)
  {
    // Read in this bit
    int bitValue = digitalRead(aOnePin+(i*aPinSequenceDirection));
    //Serial.print(aOnePin+(i*aPinSequenceDirection));
    //Serial.print(": ");
    //Serial.println(bitValue);
    // And add it to the value
    // (using "|" the bitwise OR, and "<<" to shift the bit into the right place)
    ret = ret | (bitValue << i);
  }
  return ret;
}

/*
  // Keep in mind the pullup means the pushbutton's
  // logic is inverted. It goes HIGH when it's open,
  // and LOW when it's pressed. Turn on pin 13 when the
  // button's pressed, and off when it's not:
  if (sensorVal == HIGH) {
    digitalWrite(13, LOW);
  } else {
    digitalWrite(13, HIGH);
  }
  }
*/


