int incomingByte;   

// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(38400);
}

// the loop routine runs over and over again forever:
void loop() {
  // read the input on analog pin 0:
  incomingByte = Serial.read();
  // print out the value you read:
  Serial.println(incomingByte);
}
