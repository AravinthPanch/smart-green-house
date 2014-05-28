/*
 *  ------Waspmote Demo Test 2--------
 *
 *  Explanation:This Demo shows the Events Sensor Board working. The 
 *  sensors included are:
 *    - Liquid sensor
 *    - LDR sensor
 *    - Pressure sensor
 *    - PIR sensor
 *    - Hall Effect sensor
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
#include <WaspSensorEvent_v20.h>

/////////////////////////////////////////////
char* DESTINATION="0013A2004061097E";
/////////////////////////////////////////////

#define THRESHOLD 1.0  //THRESHOLD for interruption from the sensor

long previous=0;
char S[10];
char T[10];
char U[10];
char V[10];
char P[10];

packetXBee packet;
char data[100];
uint8_t state=2;
float value=0;
int flag=0;
uint8_t counter=0;


#define NORMAL_OPTION  0
#define SENS_OPTION  1

#define  SENS_LIQUID    SENS_SOCKET8
#define  SENS_LDR       SENS_SOCKET3
#define  SENS_PRESS     SENS_SOCKET1
#define  SENS_PIR       SENS_SOCKET7
#define  SENS_HALL      SENS_SOCKET2

#define  LIQ_INT  2

void setup()
{    
  setBoard();

  // XBee set up  
  xbee802.ON(); 

  previous=millis();

}

void loop()
{
  if(intFlag & SENS_INT)
  {
    intFlag &= ~(SENS_INT);    
    sendData();
  }
  else if( (millis()-previous) > 1000 )
  {
    sendData();
    previous=millis();
  }
}





/***************************************
 * sends a message 
 *
 ***************************************/
void sendData()
{
  memset( &packet, 0x00, sizeof(packet) );
  packet.mode=UNICAST;

  // Disable interruptions from the board
  SensorEventv20.detachInt();

  // Load the interruption flag
  flag = SensorEventv20.loadInt();


  //USB.print("flag:");
  //USB.println(flag,DEC);
  //USB.print("SensorEventv20.intFlag:");
  //USB.println(SensorEventv20.intFlag, BIN);
  //printIntFlag();
  Utils.long2array(SensorEventv20.intFlag,S); 

  // Read LDR
  value = SensorEventv20.readValue(SENS_LDR);
  value*=10;
  Utils.long2array(value,T);  
  //USB.print("LDR:");
  //USB.println(value);

  // Read Pressure
  value = SensorEventv20.readValue(SENS_PRESS);
  value*=10;
  Utils.long2array(value,V);
  ///USB.print("Pressure:");
  //USB.println(value);

  // Read Pressure
  value = SensorEventv20.readValue(SENS_PIR);
  //value*=10;
  Utils.long2array(value,P);
  //USB.print("PIR:");
  //USB.println(value);


  // Create frame
  sprintf(data, "EVE***%s,%s,%s,%s,$", S, T, V, P);

  //USB.print("data:");
  //USB.println(data);  

  xbee802.setDestinationParams(&packet, DESTINATION, data);

  while( counter<3 ) 
  {
    state=xbee802.sendXBee(&packet);
    if(state==0) break;
    counter++;

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

  // Clean the interruption flag
  clearIntFlag();

  // Enable interruptions from the board
  SensorEventv20.attachInt();
}



/***************************************
 * set Sensor Board
 *
 ***************************************/
void setBoard()
{
  // Set Event Board Mode ON and configure it
  SensorEventv20.ON();

  // Turn on the RTC
  RTC.ON();

  // Configure the socket 2 threshold
  SensorEventv20.setThreshold(SENS_SOCKET1, THRESHOLD);
  SensorEventv20.setThreshold(SENS_SOCKET2, THRESHOLD);
  SensorEventv20.setThreshold(SENS_SOCKET3, THRESHOLD);


  // Enable interruptions from the board
  SensorEventv20.attachInt();

}



/***************************************
 * Print info related to the Events Sensor Board Flag vector
 ***************************************/
void printIntFlag()
{
  USB.println(F(" _____________________________________________________"));
  USB.println(F("|        |     |      |       |     |     |     |     |"));
  USB.println(F("| Liquid | PIR | HALL | PRESS | S_5 | S_6 | LDR | S_4 |"));
  USB.println(F("|________|_____|______|_______|_____|_____|_____|_____|"));
  USB.print(F("     "));
  USB.print(bool(SensorEventv20.intFlag & SENS_SOCKET8));
  USB.print(F("      "));
  USB.print(bool(SensorEventv20.intFlag & SENS_SOCKET7));
  USB.print(F("     "));
  USB.print(bool(SensorEventv20.intFlag & SENS_SOCKET2));
  USB.print(F("      "));
  USB.print(bool(SensorEventv20.intFlag & SENS_SOCKET1));
  USB.print(F("      "));
  USB.print(bool(SensorEventv20.intFlag & SENS_SOCKET5));
  USB.print(F("      "));
  USB.print(bool(SensorEventv20.intFlag & SENS_SOCKET6));
  USB.print(F("     "));
  USB.print(bool(SensorEventv20.intFlag & SENS_SOCKET3));
  USB.print(F("     "));
  USB.print(bool(SensorEventv20.intFlag & SENS_SOCKET4));
  USB.println();
  USB.println();
}



