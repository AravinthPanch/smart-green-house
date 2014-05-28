/*
 *  ------Waspmote Demo Test 1--------
 *
 *  Explanation:This Demo shows the accelerometer working and sending
 *  messages using XBee modules
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


int x_acc, y_acc, z_acc =0;
long previous=0;
char X[10];
char Y[10];
char Z[10];
packetXBee packet;
char data[100];
uint8_t state=2;
uint8_t counter=0;

/////////////////////////////////////////////
//char* DESTINATION="0013A200406E5E9E";
char* DESTINATION="0013A2004061097E";
/////////////////////////////////////////////

#define NORMAL_OPTION  0
#define FREE_OPTION  1


void setup()
{  
  // Set ACC on
  ACC.ON(); 
  ACC.setFF();
  
  xbee802.ON(); 
  
  previous=millis();
}

void loop()
{
  if( intFlag & ACC_INT )
  {
    intFlag &= ~(ACC_INT);    
    sendData(FREE_OPTION);
    ACC.setFF();
  }
  else if( (millis()-previous) > 10 )
  {
    sendData(NORMAL_OPTION);
    previous=millis();
  }
}



/*****************************************************************
*
* sends a message changing it depending on the input option
*
*****************************************************************/
void sendData(uint8_t option)
{
   memset(&packet, 0x00, sizeof(packet) );
   packet.mode=UNICAST;
   
  switch(option)
  {
    case  NORMAL_OPTION :      x_acc=ACC.getX();
                               y_acc=ACC.getY();
                               z_acc=ACC.getZ();   
                                               
                               Utils.long2array(x_acc,X);
                               Utils.long2array(y_acc,Y);
                               Utils.long2array(z_acc,Z);   
                                               
                               sprintf(data,"ACC***%u,%u,%s,%s,%s,$", PWR.getBatteryLevel(), 0, X, Y, Z);
                               break;
    case  FREE_OPTION :        x_acc=ACC.getX();
                               y_acc=ACC.getY();
                               z_acc=ACC.getZ();   
                                               
                               Utils.long2array(x_acc,X);
                               Utils.long2array(y_acc,Y);
                               Utils.long2array(z_acc,Z);
                               
                               int acc=1;                            
                               clearIntFlag();
                               PWR.clearInterruptionPin();                            
                                              
                               sprintf(data,"ACC***%u,%u,%s,%s,%s,$", PWR.getBatteryLevel(), acc, X, Y, Z);
                               break;                                          
  }

   xbee802.setDestinationParams(&packet, DESTINATION, data);
   while( counter<3 ) 
   {
     state=xbee802.sendXBee(&packet);
     if(!state) break;
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
}

