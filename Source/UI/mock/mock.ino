
void setup() {
  Serial.begin(38400);
}

void loop() {
  readMock();
}

void writeMock(){
  while (Serial.available()) {
    char inChar = (char)Serial.read();
    if(inChar == 'G'){ 
      readMock();
    }    
  }
}

void readMock(){
  Serial.write("S:CC:SENSOR:1:25:E");
  delay(2000);        
  Serial.println("HELLO"); 
  delay(2000);      
  Serial.write("S:CC:SENSOR:1:55:E");
  delay(2000);      
  Serial.write("S:CC:SENSOR:2:45:E");
  delay(2000);
  Serial.write("S:CC:SENSOR:3:35:E");
  delay(2000);
  Serial.write("S:CC:SENSOR:4:65:E");
  delay(2000);
  Serial.write("S:CC:SENSOR:2:75:E");
  delay(2000);
  Serial.write("S:CC:SENSOR:3:85:E");
  delay(2000);
  Serial.write("S:CC:LOW:E"); 
  delay(2000); 
}





