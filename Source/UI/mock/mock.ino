
void setup() {
  Serial.begin(38400);
}

void loop() {
  writeMock();
  //readMock();
}

void writeMock(){
  while (Serial.available() > 0) {
    String str = Serial.readString();

    if(str == "S:UI:GET:DATA:E"){
      //Temperature:Humidity:Luminosity:SoilMoisture
      Serial.write("S:CC:RANGE:15:30:30:50:20000:30000:400:600:E");
      delay(1000);      
      //Pump
      Serial.write("S:CC:ACTUATOR:1:2005:9000:E");
      delay(1000);
      //Light
      Serial.write("S:CC:ACTUATOR:2:2005:9000:E");
      delay(1000);
      Serial.write("S:CC:ACTUATOR:1:4005:9000:E");
      delay(1000);
      //Temperature 0:50 Range
      Serial.write("S:CC:SENSOR:1:15:E");  
      delay(1000); 
      //Humidity 20:90 Range
      Serial.write("S:CC:SENSOR:2:30:E");
      delay(1000);
      //Luminosity 0:40000 Range
      Serial.write("S:CC:SENSOR:3:20000:E");
      delay(1000);
      //SoilMoisture 0:1023 Range           
      Serial.write("S:CC:SENSOR:4:400:E");  
      delay(1000);      

      Serial.write("S:CC:SENSOR:1:30:E");  
      delay(1000);      
      Serial.write("S:CC:SENSOR:2:50:E");
      delay(1000);      
      Serial.write("S:CC:SENSOR:3:30000:E");   
      delay(1000);      
      Serial.write("S:CC:SENSOR:4:600:E");  

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
  Serial.write("S:CC:ACTUATOR:1:1405862340000:1405863000000:E");
  delay(2000);
  Serial.write("S:CC:ACTUATOR:2:1405862340000:1405862520000:E");
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








































