#include <Digital_Light_TSL2561.h>
#include <DHT11.h>


/*
 *  ------Waspmote Power Setting Deep Sleep Mode Example--------
 *
 *  Explanation: This example shows how to set Waspmote in a low-power
 *  consumption mode waking up using the RTC
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
 *  Version:                0.1
 *  Design:                 David GascÃ³n
 *  Implementation:    Alberto Bielsa
 */
#define sleepTime "00:00:00:05"
 
DHT11 dht11(DIGITAL1);  

 
void setup()
{
  // Init USB
  USB.begin();
  USB.println("Sensor Test Program: \n");
  
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

void loop()
{
     
  
     
     

    //USB.println("Before getLux()");
    //Get Light sensor data
    unsigned long  Lux;
    TSL2561.getLux();
    
    //Get moisture value
    unsigned int moistVal;
    moistVal = analogRead(ANALOG1);
    
     int temp, humi;
    dht11.read(humi, temp);
    
    //Print Values
    
    USB.print("Temperature(celcius): ");
    USB.println(temp,DEC);
     
    USB.print("Humidity(%): ");
    USB.println(humi,DEC);
      
    USB.print("Moisture (Analog Val): ");
    USB.println(moistVal,DEC);
        
    USB.print("Light (lux): ");
    USB.println(TSL2561.calculateLux(0,0,1));

    USB.println("Sleep 5 seconds\n\n");
   // delay(5000);
  
  // Go to sleep disconnecting all the switches and modules
  // After 10 seconds, Waspmote wakes up thanks to the RTC Alarm
  PWR.deepSleep(sleepTime,RTC_OFFSET,RTC_ALM1_MODE1,ALL_OFF);
  if( intFlag & RTC_INT )
  {
    Utils.blinkLEDs(1000);
    initAfterWakeup();
    USB.println("Interrupt");
   
   intFlag &= ~(RTC_INT);
  }

}


