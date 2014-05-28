/*
 *  ------Waspmote Demo Test 4--------
 *
 *  Explanation:This Demo shows the  working
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


long previous=0;
char X[10];
char Y[10];
char Z[10];
packetXBee packet;
char data[30];
uint8_t state=2;
float value=0;
int flag=0;

uint8_t byteIN[100];
uint8_t i=0;
uint8_t num_read;
uint8_t cont=0;
uint8_t aux=0;
uint8_t length=0;
uint8_t end=0;


void setup()
{    
    
  // XBee setup
  xbee802.ON(); 
  
}

void loop()
{
    if( xbee802.available() )
    {
      previous=millis();
      i=0;
      memset( byteIN, 0x00, sizeof(byteIN) );
      
      while( xbee802.available()>0 )
      {
        byteIN[i]=serialRead(0);        
        i++;
        delay(3);
      }
      
      for( int j=0; j<i; j++)
      {
        USB.printHex(byteIN[j]);
      }
      USB.println();
      
      num_read=i;
      i=0;
      
      parseData();
     
      length=0;
      cont=0;
      aux=0;
      i=0;
      num_read=0;
    }
}




/*****************************************************
*
*****************************************************/
void parseData()
{
  while( (i<num_read) )
      {
        while(  (byteIN[cont]!=0x7E) && (cont<num_read) )
        {
          cont++;
        }
        length=cont-aux;
        aux=length+aux;
        cont++;
        
        if( length==14 ) // XSTICK
        {
          if( byteIN[aux-length+12]==0x4B || byteIN[aux-length+12]==0x5B ) // ON
          {
            turnON();
            i=aux;
          }
          
          else if( byteIN[aux-length+12]==0x4D || byteIN[aux-length+12]==0x5D ) // OFF
          {
            turnOFF();
            i=aux;            
          }
          
          else if( byteIN[aux-length+12]==0x4F || byteIN[aux-length+12]==0x5F ) // END
          {
            i=aux;
          }
          
          else i=aux;
        }
        
        else if( length== 10 )
        {
          if( byteIN[aux-length+8]==0x01 ) // ON
          {
            turnON();
            i=aux;            
          }
          
          else if( byteIN[aux-length+8]==0x00 ) // OFF
          {
            turnOFF();
            i=aux;            
          }
          
          else i=aux;
        } 
 
        else i=aux;        
      }
}

void turnON()
{
  Utils.setLED(LED1,LED_ON);
  Utils.setLED(LED0,LED_OFF);
  //SensorProto.setRelayMode(SENS_ON);
}

void turnOFF()
{
  Utils.setLED(LED1,LED_OFF);
  Utils.setLED(LED0,LED_ON);  
  //SensorProto.setRelayMode(SENS_OFF);  
}
  
