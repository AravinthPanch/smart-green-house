/*
 *  ------ Waspmote Demo Test 3 --------
 *
 *  Explanation:This Demo shows the Gases Sensor Board working.The 
 *  sensors included are:
 *    - Humidity sensor
 *    - Temperature sensor
 *    - Pressure sensor
 *    - O2 sensor
 *    - CO sensor
 *
 *  Copyright (C) 2013 Libelium Comunicaciones Distribuidas S.L.
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
 *  Version:		0.1
 *  Design:		David Gascón
 *  Implementation:	Yuri Carmona
 */


#include <WaspXBee802.h>
#include <WaspSensorGas_v20.h>


/////////////////////////////////////////////
char* DESTINATION="0013A2004061097E";
/////////////////////////////////////////////


#define CO_GAIN  1      // GAIN of the sensor stage
#define CO_RESISTOR 100  // LOAD RESISTOR of the sensor stage

#define O2_GAIN  100  //GAIN of the sensor stage


long previous=0;
char X[10];
char Y[10];
char Z[10];
char W[10];
char C[10];
packetXBee packet;
char data[30];
uint8_t state=2;
float value_temp=0;
float value=0;
float value2=0;
int flag=0;
uint8_t counter=0;


void setup()
{    
  // Board setup
  SensorGasv20.ON();
  
  SensorGasv20.setSensorMode(SENS_ON, SENS_PRESSURE);  
  
  // Configure the CO sensor on socket 4
  SensorGasv20.configureSensor(SENS_SOCKET4CO, CO_GAIN, CO_RESISTOR);  
  
  // Configure the O2 sensor socket
  SensorGasv20.configureSensor(SENS_O2, O2_GAIN);  
  // Turn on the O2 sensor and wait for stabilization and
  // sensor response time
  SensorGasv20.setSensorMode(SENS_ON, SENS_O2);
  
  // XBee setup
  xbee802.ON(); 
  
  previous=millis();
}




void loop()
{
  if( (millis()-previous) > 1000 )
  {
    sendData();
    previous=millis();
  }
}




/********************************************************************
* sends a message changing it depending on the input option
********************************************************************/
void sendData()
{
   memset( &packet, 0x00, sizeof(packet) );
   packet.mode=UNICAST;
   
   
   // Temperature
   value=0;
   value_temp=0;
   
   for(int g=0;g<5;g++)
   {
     value_temp = SensorGasv20.readValue(SENS_TEMPERATURE);
     value = value_temp + value;
     delay(10);
   }
   value = value/5;   
   Utils.long2array(value,X);  
   
   
   // Humidity
   value2=SensorGasv20.readValue(SENS_HUMIDITY);
   Utils.long2array(value2,Y);  
      
   // Pressure
   value=SensorGasv20.readValue(SENS_PRESSURE);                                          
   Utils.long2array(value,Z);  
  
   // O2
   value = SensorGasv20.readValue(SENS_O2);   
   value = value*21/0.687; // conversion to % 
   Utils.long2array(value,W); 
      
   // CO
   value=SensorGasv20.readValue(SENS_SOCKET4CO); 
   value = value*1000/33; // conversion to %                                 
   Utils.long2array(value,C);  
   
   sprintf(data,"GAS***%s,%s,%s,%s,%s,$", X, Y, Z, W, C);
   
   USB.print("data:");
   USB.println(data);
   
   xbee802.setDestinationParams(&packet, DESTINATION, data);
   
   while( counter<3 )
   {
     state=xbee802.sendXBee(&packet);
     counter++;
     if(state==0) break;
   }
   counter=0;
   if(!state)
   {
     USB.println("OK");
   }
   else
   {
     USB.println("ERROR");     
   }


}

