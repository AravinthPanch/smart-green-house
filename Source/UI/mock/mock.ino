
void setup() {
  Serial.begin(38400);
}

void loop() {
  writeMock();
  //  readMock();
}

void writeMock(){
  while (Serial.available() > 0) {
    String str = Serial.readString();
    if(str == "S:UI:GET:DATA:E"){
      Serial.write("S:CC:RANGE:100:500:200:500:300:500:400:500:E");
      delay(1000);      
      Serial.write("S:CC:SENSOR:1:25:E");  
      delay(1000);      
      Serial.write("S:CC:SENSOR:2:45:E");  
      delay(1000);      
      Serial.write("S:CC:SENSOR:3:35:E");
      delay(1000);      
      Serial.write("S:CC:SENSOR:4:65:E");
      delay(1000);
      Serial.write("S:CC:ACTUATOR:1:1405852800000:1405854000000:E");
      delay(1000);
      Serial.write("S:CC:ACTUATOR:2:1405852800000:1405854000000:E");
    }
    else if(str.indexOf("S:UI:SET:RANGE:") > -1){
      str.replace("UI:SET:","CC:");
      Serial.print(str);
    }

  }
}

void readMock(){
  Serial.write("S:CC:SENSOR:1:25:E");
  delay(2000);        
  Serial.println("HELLO"); 
  delay(2000);
  Serial.write("S:CC:ACTUATOR:1:100:E");
  delay(2000);
  Serial.write("S:CC:ACTUATOR:2:0:E");
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




























