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
 
 // We are using the following network adresses:
//controller: 0x01, 0x01
// sensor node: 0x02 0x02
// actuator node: 0x03 0x03

 packetXBee* paq_sent;
 int8_t state=0;
 long previous=0;
 char*  data="Test message!";
 char* received = "Received Message over the network";
 int g=0;
   uint8_t  PANID[2]={0x12,0x34};
 //Sensor Side Variables:
 // values[0] ... humidity
 // values[1] ... temperature
 // value[2] ...   light value 
 int values[3];
 
 int tempRange[2] = {0, 0};
 int humRange[2] = {0, 0}; 
 int lightRange[2] = {0, 0};


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
  
}

void sendValues(int temperature,int humidity,int light){
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

  sprintf(data, "a%d;%d;%d", temperature, humidity, light);  
  xbee868.hops=0;
  xbee868.setOriginParams(paq_sent, "0202", MY_TYPE);
  xbee868.setDestinationParams(paq_sent, "FFFF", data, MY_TYPE, DATA_ABSOLUTE);
  xbee868.sendXBee(paq_sent);
  if( !xbee868.error_TX )
  {
    XBee.println("ok");
  }
  free(paq_sent);
  paq_sent=NULL;
 
}

void sendCurrentRange(){
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

  sprintf(data, "d%d;%d;%d;%d;%d;%d", tempRange[0], tempRange[1], humRange[0], humRange[1], lightRange[0], lightRange[1]);  
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


void receiveRange(int tempRange[2], int humRange[2], int lightRange[2]){

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
            }
            //answer request by control center
            if( (xbee868.packet_finished[xbee868.pos-1]->data[f]) == 'c')
            {
              sendCurrentRange();
            }
            
          }
          free(xbee868.packet_finished[xbee868.pos-1]);
          xbee868.packet_finished[xbee868.pos-1]=NULL;
          xbee868.pos--;
        }
      }
    }
}

void loop()
{
  sendValues(10,20,30);
  delay(1000);
}


