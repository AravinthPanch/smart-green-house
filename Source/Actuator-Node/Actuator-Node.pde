/*
* author: Florian Roubal, Alexander Platz, Sven Jiroschewski
* July 2014
* last update: 21 July 2014
* Programm receives packets to control a water pump
* and a light bulb via a relay board independently
*/
 
 // XBee packet
 packetXBee* paq_sent;
 int8_t state=0;
 char*  data="Thatisaverylongmessagetoallocatememorythismessageistreallyreallylong";
 
 // receiving messages
 int received = 0;
 int messagecounter = 0;
 
 // received values
 int valveValue = 0;
 int valveTimeout = 0;
 int lightValue = 0;
 int lightTimeout = 0;
 
 // timer
 unsigned long receivingtime = 0;
 unsigned long valveTimer;
 unsigned long lightTimer;
 
 boolean valveON = false;
 boolean lightON = false; 

 // some definitions
 int relay1 = DIGITAL1;   // relay1 is connected to DIGITAL1
 int relay2 = DIGITAL3;   // relay2 is connected to DIGITAL3
 int redLED = LED0;
 int greenLED = LED1;
  
void setup()
{
  xbee868.init(XBEE_868,FREQ868M,NORMAL);  
  xbee868.ON();
  
  pinMode(relay1, OUTPUT); // relay1
  digitalWrite(relay1,HIGH); // relay1 off
  pinMode(relay2, OUTPUT); // relay2
  digitalWrite(relay2,HIGH); // relay2 off
  PWR.setSensorPower(SENS_5V,SENS_OFF);// relay board off: saves energy

  USB.begin();
  USB.println("Programm to control 2 relays wireless");
  USB.println("Project: Networked Embedded Flowerpot, July 2014");
  USB.println("------------------------------------\n");
  
}

/*
* Function
* Receiving a packet from the control center
* reading the data
* matches the received data to some global variables
* retuns 1 if packet was succesfully received
*/
int receiveAction(){
  
  int output = 0;
  //checking for messages
  if( XBee.available() )
  {
    xbee868.treatData();
    if( !xbee868.error_RX )
    {
      XBee.println("Packet was received! ");
      output = 1; // the return value
      
      while(xbee868.pos>0)
      {
        
        uint16_t length =  xbee868.packet_finished[xbee868.pos-1]->data_length;
        if(length > 0)
        {
          int f = 0;
          //receive Range
          if((xbee868.packet_finished[xbee868.pos-1]->data[f]) == 'e')
         {              
            f++;
            int i = 0;
            char* tmp;
            char* start = tmp;
            //Receive Temp Range
            while(i < 4 && f < length)
            {
              start = "Hallo Welt";
              tmp = start;
             
             // XBee.println(start);
              while((xbee868.packet_finished[xbee868.pos-1]->data[f]) != ';' && f < length)
              {
                *tmp = (xbee868.packet_finished[xbee868.pos-1]->data[f]);               
                // XBee.print(xbee868.packet_finished[xbee868.pos-1]->data[f]);
                tmp++;
                f++;                  
              }
              
              tmp++;
              //XBee.println("--");
              *tmp = 0;
            
              if(i == 0)
              {
               //XBee.print("Valve value (string):");
               //XBee.println(start);
               valveValue = atoi(start);
               //XBee.print("valveValue (integer): ");
               //XBee.println(valveValue);
              }
              else if(i == 1)
              {
                 valveTimeout = atoi(start);
              }
              else if(i == 2)
              {
                 lightValue = atoi(start);
              }
              else if(i ==3)
              {
                 lightTimeout = atoi(start);
              }   
                i++;
                f++;
             }
           
         }
         
         // ALARM OFF
         else if((xbee868.packet_finished[xbee868.pos-1]->data[f]) == 'j')
         { 
           digitalWrite(relay1,HIGH); //Relay1 off
  	   Utils.setLED(greenLED,LED_OFF); // green led off
  	   valveON = false; 
           valveTimeout = 0;
           valveValue = 0;
           XBee.println("Valve emergency stop.");
         }
           
            
        }
        free(xbee868.packet_finished[xbee868.pos-1]);
        xbee868.packet_finished[xbee868.pos-1]=NULL;
        xbee868.pos--;
      }
    }
  }
  
 return output;

}

void loop()
{
  /* 
  * goes through the void loop and checks new messages everytime
  * if new message arrived: old values will be overwrite
  * alarm stops are possible (timeOut = 0)
  * it is be possible to control the acuators independently
  * if i only want to set the timer for one actuator I set only one Value to 1  
  */
  
  received = receiveAction(); // checks if packet was received
     
  if(received == 1)
  { 
    messagecounter++;
    XBee.println("-----------------------------------");
    XBee.print("Messages received:");
    XBee.println(messagecounter);
    XBee.print("valveValue= ");
    XBee.println(valveValue);
    XBee.print("valveTimeout= ");
    XBee.println(valveTimeout);
    XBee.print("lightValue= ");
    XBee.println(lightValue);
    XBee.print("lightTimeout= ");
    XBee.println(lightTimeout);
   }    
    // some error detection    
    if( 0 > valveValue || valveValue > 1) // all other integers in valveValue are not allowed
    {
      Utils.setLED(redLED,LED_ON); // error led switches on 
      XBee.println("\n------------------------------------");
      XBee.println("Wrong entry for valveValue !!! Please try again :-)");
      XBee.println("\n------------------------------------");
      XBee.flush();
      delay(1000);
      Utils.setLED(redLED,LED_OFF);
    }
    if( 0 > lightValue || lightValue > 1) // all other integers in lightValue are not allowed
    {
      Utils.setLED(redLED,LED_ON); // error led switches on 
      XBee.println("\n------------------------------------");
      XBee.println("Wrong entry for lightValue !!! Please try again :-)");
      XBee.println("\n------------------------------------");
      XBee.flush();
      delay(1000);
      Utils.setLED(redLED,LED_OFF);
     }
    
     
    // activating deactivating power supply for relayboard
    if(lightValue == 1)
    {    
      PWR.setSensorPower(SENS_5V,SENS_ON);// 5V supply voltage for relay board
    }
    if(valveValue == 1)
    {    
      PWR.setSensorPower(SENS_5V,SENS_ON);// 5V supply voltage for relay board
    }
    if(lightValue == 0 && valveValue == 0) // Power Saving Mode
    {
      PWR.setSensorPower(SENS_5V,SENS_OFF);// saves energy 
    }
     
    // Checking or setting timer 
    if(valveValue == 1){
		if(valveON == false)
		{
			valveTimer = millis(); // set valveTimer
			digitalWrite(relay1, LOW); //Relay1 on     
			Utils.setLED(greenLED, LED_ON);
			valveON = true;
			XBee.println("valveTimer set");
		}
		else if(valveON == true && (millis() - valveTimer >= valveTimeout) ) // in Milliseconds
		{
			digitalWrite(relay1,HIGH); //Relay1 off
			Utils.setLED(greenLED,LED_OFF);
			valveON = false;
			valveValue = 0;
			valveTimeout = 0;
			XBee.println("valveTimer expired");
		}
    }
      
    if(lightValue == 1){
		if(lightON == false)
		{
		      lightTimer = millis(); //set lighttimer
		      digitalWrite(relay2, LOW); //Relay2 on     
		      Utils.setLED(redLED, LED_ON);  // red led on
		      lightON =true;
		      XBee.println("lightTimer set");
		}
		else if(lightON == true && (millis() - lightTimer >= lightTimeout)) // in Milliseconds
		{
		      digitalWrite(relay2,HIGH); //Relay2 off
		      Utils.setLED(redLED,LED_OFF); // red led off
		      lightON = false;
		      lightValue = 0;
		      lightTimeout = 0;
		      XBee.println("lightTimer expired");
      }
    }     
     
}
