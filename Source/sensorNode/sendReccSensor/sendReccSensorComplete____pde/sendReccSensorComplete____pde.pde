#include <Digital_Light_TSL2561.h>
#include <DHT11.h>

/*
 *  ------Waspmote XBee 802.15.4 Sending & Receiving Example------
 *
 *  Explanation: This example shows how to send and receive packets
 *  using Waspmote XBee 802.15.4 API
 *
 *  This code sends a packet to another node and waits for an answer from
 *  it. When the answer is received it is shown.
 *
 *  Copyright (C) 2009 Libelium Comunicaciones Distribuidas S.L.
 *  http://www.libelium.com
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 2 of the License, or
 *  (at your option) any later version.
 * 
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 * 
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  Version:                0.2
 *  Design:                 David Gascón
 *  Implementation:    Alberto Bielsa
 */


// edit by Sven 10:58 AM 07/16/14 (did not compile because the Digital_Light... was not found
 // We are using the following network adresses:
//controller: 0x01, 0x01
// sensor node: 0x02 0x02
// actuator node: 0x03 0x03

#define sleepTime "00:00:00:05"

packetXBee* paq_sent;
int8_t state=0;
long previous=0;
char*  data="Test message!";
char* received = "Received Message over the network";
int dummySwitch=0;
uint8_t  PANID[2]={0x12,0x34};
 //Sensor Side Variables:
 // values[0] ... humidity
 // values[1] ... temperature
 // value[2] ...   light value 
int values[3];
 
//global range values 
int tempRange[2] = {0, 0};
int humRange[2] = {0, 0}; 
int lightRange[2] = {0, 0};
int moistRange[2] = {0, 0};
 
// Global sensor values
int temp = 0;
int humi = 0;
int light = 0;
int moistVal = 0; // between 0 and 1023, the higher the value the drier
  
//global fast sample state variable
bool fastMode = 0;
int criticalMoistVal = 0; //sensor in water means gives sth like 350-400

int noWokenUp = 0;  
  
int modVal = 2;  

int actuator_adress;

// call constructor of DHT11 class with DIGITAL1 pin
DHT11 dht11(DIGITAL1);  


 //Sensor Side Messages: a= sendValues, b = receiveRange, c = requestToReturnCurrentRange, d = ReturnCurrentRange
 
void setup()
{
  booting();
}

void booting()
{
    // Inits the XBee 802.15.4 library
  xbee868.init(XBEE_868,FREQ868M,NORMAL);
  
  // Powers XBee
  xbee868.ON();
//  xbee868.setOwnNetAddress(0x02, 0x02);
//  xbee868.setChannel(0x0F);

  // Init USB
  USB.begin();
  USB.println("Sensor Node initialization: \n");
  
  // Init RTC
  RTC.ON();
  RTC.setTime("09:10:21:04:14:25:00");
    
   //Enable 3,3V Output Pin
  pinMode(SENS_PW_3V3,OUTPUT);
  digitalWrite(SENS_PW_3V3,HIGH);
  
  //Enable 5V Output Pin
  pinMode(SENS_PW_5V,OUTPUT);
  digitalWrite(SENS_PW_5V,HIGH);  
    
  //Init Light sensor
  TSL2561.init(); 
  USB.println("Initialization successful!\n");
  
}

void initAfterWakeup()
{
  // Init USB
  USB.begin();
  USB.println("After wakeup reinitialization: \n"); 
 
  // Inits the XBee 802.15.4 library
  xbee868.init(XBEE_868,FREQ868M,NORMAL);
  
  // Powers XBee
  xbee868.ON();
//  xbee868.setOwnNetAddress(0x02, 0x02);
//  xbee868.setChannel(0x0F);

   
  //Enable 3,3V Output Pin
  pinMode(SENS_PW_3V3,OUTPUT);
  digitalWrite(SENS_PW_3V3,HIGH);
  
  //Enable 5V Output Pin
  pinMode(SENS_PW_5V,OUTPUT);
  digitalWrite(SENS_PW_5V,HIGH);

  // Init RTC
  RTC.ON();
 
  //Init Light sensor
  TSL2561.init(); 
  USB.println("Initialization successful!\n");
}

void sendValues(int temperature,int humidity,int light, int soil_moisture){
   // Set params to send
  paq_sent=(packetXBee*) calloc(1,sizeof(packetXBee)); 
  paq_sent->mode=BROADCAST;
  // known net address (0 unknown)
 // paq_sent->MY_known=1;
  // set destination: control center
 // paq_sent->naD[0] = 0x01;
 // paq_sent->nad[1] = 0x01;
  
  // 16b Adresse (and not 64b)
  paq_sent->address_type=0;
  
  //TODO set packetID for duplicate packet detection
  paq_sent->packetID=0x52;
  paq_sent->opt=0; 
  
  //MAC Mode:   0 - DigiMode + 802.15.4
  //            1 - 802.15.4 without ACKs
  //            2 - 802.15.4 according to the standard
  //            3 - DigiMode + 802.15.4 without ACKs
//  xbee868.setMacMode(2);

  sprintf(data, "a%d;%d;%d;%d;", temperature, humidity, light, soil_moisture);  
  xbee868.hops=0;
  xbee868.setOriginParams(paq_sent, "0202", MY_TYPE);
  xbee868.setDestinationParams(paq_sent, "FFFF", data, MY_TYPE, DATA_ABSOLUTE);
  xbee868.sendXBee(paq_sent);
  if( !xbee868.error_TX )
  {
    XBee.println("\nSensor Node: Values sent sucessfully.");
  }
  free(paq_sent);
  paq_sent=NULL;
 
}

void sendStop(){
   // Set params to send
  paq_sent=(packetXBee*) calloc(1,sizeof(packetXBee)); 
  paq_sent->mode=BROADCAST;
  // known net address (0 unknown)
 // paq_sent->MY_known=1;
  // set destination: control center
 // paq_sent->naD[0] = 0x01;
 // paq_sent->nad[1] = 0x01;
  
  // 16b Adresse (and not 64b)
  paq_sent->address_type=0;
  
  //TODO set packetID for duplicate packet detection
  paq_sent->packetID=0x52;
  paq_sent->opt=0; 
  
  //MAC Mode:   0 - DigiMode + 802.15.4
  //            1 - 802.15.4 without ACKs
  //            2 - 802.15.4 according to the standard
  //            3 - DigiMode + 802.15.4 without ACKs
//  xbee868.setMacMode(2);

  sprintf(data, "j");  
  xbee868.hops=0;
  xbee868.setOriginParams(paq_sent, "0202", MY_TYPE);
  xbee868.setDestinationParams(paq_sent, "FFFF", data, MY_TYPE, DATA_ABSOLUTE);
  xbee868.sendXBee(paq_sent);
  if( !xbee868.error_TX )
  {
    XBee.println("\nSensor Node: Stop sent");
  }
  free(paq_sent);
  paq_sent=NULL;
}


void sendCurrentRange(){
   USB.println("Send range");
        
  // Set params to send
  paq_sent=(packetXBee*) calloc(1,sizeof(packetXBee)); 
  paq_sent->mode=UNICAST;
  // known net address (0 unknown)
 // paq_sent->MY_known=1;
  // set destination: control center
 // paq_sent->naD[0] = 0x01;
 // paq_sent->nad[1] = 0x01;
  
  // 16b Adresse (and not 64b)
  paq_sent->address_type=0;
  
  //TODO set packetID for duplicate packet detection
  paq_sent->packetID=0x52;
  paq_sent->opt=0; 
  
  //MAC Mode:   0 - DigiMode + 802.15.4
  //            1 - 802.15.4 without ACKs
  //            2 - 802.15.4 according to the standard
  //            3 - DigiMode + 802.15.4 without ACKs
  //xbee868.setMacMode(2);

  sprintf(data, "d%d;%d;%d;%d;%d;%d;%d;%d", tempRange[0], tempRange[1], humRange[0], humRange[1], lightRange[0], lightRange[1],moistRange[0],moistRange[1]);  
  xbee868.hops=0;
  xbee868.setOriginParams(paq_sent, "0202", MY_TYPE);
  xbee868.setDestinationParams(paq_sent, "0101", data, MY_TYPE, DATA_ABSOLUTE);
  xbee868.sendXBee(paq_sent);
  if( !xbee868.error_TX )
  {
    XBee.println("ok");
  }
  free(paq_sent);
  paq_sent=NULL;
 
}


void receive(){ //TODO add moist range
    USB.println("Receive range");
    //checking for answers
    if( XBee.available() )
    {
      xbee868.treatData();
      if( !xbee868.error_RX )
      {
        // Writing the parameters of the packet received
        while(xbee868.pos>0)
        {
          int length = xbee868.packet_finished[xbee868.pos-1]->data_length;
          if(length != 0)
          {
		  
			// --- read payload with sensor ranges
			XBee.print("Data: ");                    
			for(int f=0;f<xbee868.packet_finished[xbee868.pos-1]->data_length;f++)
			{
				XBee.print(xbee868.packet_finished[xbee868.pos-1]->data[f],BYTE);
			}
			XBee.println("");
		  
            int f = 0;
            //receive Range
            if((xbee868.packet_finished[xbee868.pos-1]->data[f]) == 'b')
            {
              f++;
              int i = 0;
              char* tmp;
              char* start = "Hello World";
              //Receive Temp Range
              while(i < 2 && f < length)
              {
                tmp = start;
                while((xbee868.packet_finished[xbee868.pos-1]->data[f]) != ';')
                {
                  *tmp = (xbee868.packet_finished[xbee868.pos-1]->data[f]);
                  tmp++;
                  f++;
                }
                tmp++;
                *tmp = 0;
                 tempRange[i] = atoi(start);
                 i++;
                 f++;
              }
              // Receive Humidity Range
              i = 0;
              while(i < 2 && f < length){
                tmp = start;
                while( (xbee868.packet_finished[xbee868.pos-1]->data[f]) != ';'){
                  *tmp =  (xbee868.packet_finished[xbee868.pos-1]->data[f]);
                  tmp++;
                  f++;
                }
                tmp++;
                *tmp = 0;
                 humRange[i] = atoi(start);
                 i++;
                 f++;
              }
              //Receive Light Range
              i =0;
              while(i < 2 && f < length){
                tmp = start;
                while( (xbee868.packet_finished[xbee868.pos-1]->data[f]) != ';'){
                  *tmp =  (xbee868.packet_finished[xbee868.pos-1]->data[f]);
                  tmp++;
                  f++;
                }
                tmp++;
                *tmp = 0;
                 lightRange[i] = atoi(start);
                 i++;
                 f++;
              }
               //Receive moisture Range
              i =0;
              while(i < 2 && f < length){
                tmp = start;
                while( (xbee868.packet_finished[xbee868.pos-1]->data[f]) != ';'){
                  *tmp =  (xbee868.packet_finished[xbee868.pos-1]->data[f]);
                  tmp++;
                  f++;
                }
                tmp++;
                *tmp = 0;
                 moistRange[i] = atoi(start);
                 i++;
                 f++;
              }    
            }
            
            if( (xbee868.packet_finished[xbee868.pos-1]->data[f]) == 'h') //receive fast mode state and critical value
            {
               f++;
              int i = 0;
              char* tmp;
              char* start = "Hello World";
              while(i < 2 && f < length)
              {
                tmp = start;
                while((xbee868.packet_finished[xbee868.pos-1]->data[f]) != ';')
                {
                  *tmp = (xbee868.packet_finished[xbee868.pos-1]->data[f]);
                  tmp++;
                  f++;
                }
                tmp++;
                *tmp = 0;
                if(i == 0){
                 fastMode = atoi(start);
                  if(fastMode == 1){
                    USB.print("fastmode on");
                  }
                  else{
                  USB.print("fastmode off");
                  }
                }
                else if(i == 1){
                  criticalMoistVal = atoi(start);
                 
                }
                 i++;
                 f++;
              }
            }
            
          }
          free(xbee868.packet_finished[xbee868.pos-1]);
          xbee868.packet_finished[xbee868.pos-1]=NULL;
          xbee868.pos--;
        }
      }
    }
}

void sampleSensors()
{
    USB.println("Start sampling all sensors");
   
    //Get Light sensor data
    unsigned long  Lux;
    TSL2561.getLux();
    light = TSL2561.calculateLux(0,0,1);
    
    //Get moisture value
    moistVal = analogRead(ANALOG1);
    
    //Get temperature and humidity
    dht11.read(humi, temp);
 
    USB.println("Sampling successful");
}

void loop()
{
  //fast mode disabled
  
  
  //sample all sensors
  sampleSensors();
  
  //all values in range
  if((tempRange[0] <= temp && temp <= tempRange[1]) && (humRange[0] <= humi && humi <= humRange[1]) && (lightRange[0] <= light && light <= lightRange[1]) &&  (moistRange[0] <= moistVal && moistVal <= moistRange[1]))
  {
       noWokenUp++;
      // to send anyway after x wakeups
      if(noWokenUp % modVal == 0){
        noWokenUp = 0;     
        USB.println("Sending values(in range)");
        sendValues(temp,humi,light,moistVal);
      }
          
  }
  else //at least 1 value not in range
  {
    //send values to control center // int temperature,int humidity,int light, int moisture
    noWokenUp = 0;
    USB.println("Sending values(out of range");
    sendValues(temp,humi,light,moistVal);
  }
  
  //Try to receive command x times
  for(int j = 0; j<15;j++){
    
    USB.println("ReceiveRange");
    receive();
    if(fastMode == 1) break;
    delay(500);
  }
  
   //fast Mode enabled    
  while(fastMode == 1){
     
     USB.println("Enter fast mode");
     
     sampleSensors();
     
     if(moistVal <= criticalMoistVal){
       USB.println("Send stop signal");
       sendStop();
     }
     //send values to control center
     //sendValues(temp,humi,light,moistVal);
     delay(500);
     //check if fastmode can be left (-> means pump off again)
     receive();
  }
  
  //flush xbee buffers
  xbee868.flush();
  // Go to sleep disconnecting all the switches and modules
  // After defined time, Waspmote wakes up thanks to the RTC Alarm
  USB.println("Enter deep sleep mode\n\n");
  PWR.deepSleep(sleepTime,RTC_OFFSET,RTC_ALM1_MODE1,ALL_OFF);

 if( intFlag & RTC_INT )
  {
    Utils.blinkLEDs(1000);
    initAfterWakeup();
    USB.println("Woke up through RTC interrupt");

    intFlag &= ~(RTC_INT);
  }
  
}

