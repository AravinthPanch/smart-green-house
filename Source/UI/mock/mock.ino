
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
  Serial.write("S:CC:RANGE:75:100:110:150:160:200:210:300:E");
  delay(2000);  
  Serial.write("S:CC:SENSOR:3:35:E");
  delay(2000);
  Serial.write("S:CC:SENSOR:4:65:E");
  delay(2000);
  Serial.write("S:CC:RANGE:25:150:60:100:90:200:250:500:E");
  delay(2000);
  Serial.write("S:CC:SENSOR:2:75:E");
  delay(2000);
  Serial.write("S:CC:SENSOR:3:85:E");
  delay(2000);
  Serial.write("S:CC:LOW:E"); 
  delay(2000); 
  Serial.write("S:CC:RANGE:50:300:100:400:200:450:300:390:E");
  delay(2000);
}








