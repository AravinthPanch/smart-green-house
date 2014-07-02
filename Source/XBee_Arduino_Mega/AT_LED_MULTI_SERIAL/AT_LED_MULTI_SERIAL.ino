const int ledPin = 53; 
int incomingByte;      

void setup() {
  Serial.begin(115200);
  Serial1.begin(115200);
  pinMode(ledPin, OUTPUT);
}

void loop() {
  if (Serial.available() > 0) {

    incomingByte = Serial.read();

    //    if (incomingByte == 'H') {      
    //      digitalWrite(ledPin, HIGH);
    //      Serial.print(incomingByte); 
    //      Serial.print("High"); 
    //    } 

    //    if (incomingByte == 'L') {
    //      digitalWrite(ledPin, LOW);
    //      Serial.print(incomingByte); 
    //      Serial.print("Low");
    //    }

    if (Serial1.available() > 0) {
      Serial1.println("Incoming"); 
      Serial1.println(incomingByte); 
    }

  }
}









