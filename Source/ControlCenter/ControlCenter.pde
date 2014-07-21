/* +----------------------------------------------------------------+
   + Networked Embedded Flower Pot - Control Center
   + 
   + The control center is responsible for receiving the sensor data
   + from the sensor node. With this data it calculates the uptime
   + for the two actuators, the light and the pump. After that it
   + delegates the sensor node to go into the fast mode to meter
   + its sensors continuously during the pouring process. Then 
   + the control center sends an ON-Signal to the actuator node. 
   + The actuator node switches on the light and the pump for 
   + the calculated time. The control center counts the same timer
   + for generating a timeout and sends an OFF-signal to the pump. 
   + In case there went something wrong and the actuator node could 
   + not switch off the pump the control center sends an OFF-Signal. 
   + If the pump is switched-off the control center delegates 
   + the sensor node to stop the fast mode.
   + The control center is ready for receiving the next sensor data.
   +
   +-----------------------------------------------------------------+
*/


 #define NOSENDRETRIES 7
 #define DELAY 100
       
// --- Global variables
packetXBee* paq_sent;
char* data = "jkjhljhjhlhjgl";
long currentIter = 0;
long valveStop = 0; // Valve Timer for counting in valveTimer();
long timeStamp = 0;
int receivedFrom = 0; // 1 = SensorNode; 2 = ActuatorNode
int needWater = 0; // 0 = don't need water; 1 = need Water
bool actionOn = false;

// --- Sensor values
const int numberVal = 3;
int sensorValueArr[numberVal];
int temp, humi, light, moistVal = 0;

// --- Retry
int sendingStatus = 0;
int retries = 0;

// --- Ranges
int tempRange[2] = {0, 100};
int humRange[2] = {0, 60};
int lightRange[2] = {0, 1000};
int moistRange[2] = {700, 800};
 
// --- Actuator Values
int valveValue = 1;
int valveTimeout = 3;
int lightValue = 1;
int lightTimeout = 5;

// --- User Interface Inputs
int targetMoist = 0;
bool rangesChanged = true;
 
// --- Fast mode 
int criticalMoistValue = 0;


void setup()
{
	// Inits the XBee 868 library
	xbee868.init(XBEE_868,FREQ868M,NORMAL,UART0);

	// Powers XBee
	xbee868.ON();

USB.begin();

}






void initXbeePacket() {
	paq_sent=(packetXBee*) calloc(1,sizeof(packetXBee)); 
	paq_sent->mode=UNICAST;
	paq_sent->MY_known=0;
	paq_sent->packetID=0x52;
	paq_sent->opt=0; 
	xbee868.hops=0;
	xbee868.setOriginParams(paq_sent, "0101", MY_TYPE);
}

// --- Send ranges to sensor node
void sendRanges() {
        
	initXbeePacket();
	
        sprintf(data, "b%d;%d;%d;%d;%d;%d;%d;%d", tempRange[0], tempRange[1], humRange[0], humRange[1], lightRange[0], lightRange[1], moistRange[0], moistRange[1]);  

	xbee868.setDestinationParams(paq_sent, "0013A2004078407E", data, MAC_TYPE, DATA_ABSOLUTE);
	xbee868.sendXBee(paq_sent);
	
	if( !xbee868.error_TX ) {
	  XBee.println("Control Center: Sensor ranges sent.");
          Utils.blinkLEDs(500);
	}
	else {
	  XBee.println("Control Sender: Error while transmitting sensor ranges.");
	}
	free(paq_sent);
	paq_sent = NULL;
  
}
// --- Send action to actuator node
int sendAction(int actionType, int criticalMoistValue){
  
  int status = 0;
  int fastMode = 0;
  initXbeePacket();


  // --- ON-Signal valve actuator node
  if(actionType == 1) {
    sprintf(data, "e%d;%d;%d;%d;", valveValue, valveTimeout, lightValue, lightTimeout);
    xbee868.setDestinationParams(paq_sent, "0013A2004078407E", data, MAC_TYPE, DATA_ABSOLUTE);
  }
  // --- Switch-on fast mode sensor node
  else if(actionType == 2) {
    fastMode = 1; // because sensor node expects 1 for going to fast mode
    sprintf(data, "h%d;%d;", fastMode, criticalMoistValue);
    xbee868.setDestinationParams(paq_sent, "0013A2004078408E", data, MAC_TYPE, DATA_ABSOLUTE);
  }
  // --- Switch-off fast mode sensor node
  else if(actionType == 3) {
    fastMode = 0; // because sensor node expects 0 for going out of fast mode
    sprintf(data, "h%d;%d;", fastMode, criticalMoistValue);
    xbee868.setDestinationParams(paq_sent, "0013A2004078408E", data, MAC_TYPE, DATA_ABSOLUTE);
  }
  // --- OFF-Signal valve actuator node
  else if(actionType == 4) {
    sprintf(data, "j");
    xbee868.setDestinationParams(paq_sent, "0013A2004078407E", data, MAC_TYPE, DATA_ABSOLUTE);
  }
  actionType = 0;
  
  xbee868.sendXBee(paq_sent);
  
  if( !xbee868.error_TX )
  {
    XBee.println("Control Center: Action sent.");
    Utils.blinkLEDs(500);
  }
  else {
    
    XBee.println("Control Center: Error while sending action.");
    status = 1;
  }
  free(paq_sent);
  paq_sent=NULL;
  
  return status;
}

int startFastMode(){
              
  XBee.println("Control Center -> Sensor Node: Start fast mode");
               // --- Put sensor node to fast mode --> sendAction(2, x)
                 int sendingStatus = sendAction(2, 500);
                  
                  if(sendingStatus == 1) {
                    for(int retries = 0; retries <= NOSENDRETRIES; retries++) {
                      XBee.println("Trying again... ");
                      delay(DELAY);
                      sendingStatus = sendAction(2, 500);
                      if(sendingStatus == 0 ) { 
                        xbee868.flush();
                        return sendingStatus;
                      }
                    }
                    XBee.println("Control Center -> Sensor Node: Start fast mode not successful");
                    return sendingStatus;
                  }
                  else { 
                    actionOn = true; 
                    return sendingStatus;  
                  }
              }

int stopFastMode(){
        
  XBee.println("Control Center -> Sensor Node: Stop fast mode");
           // --- When timer expires switch-off the fast mode in sensor node --> sendAction(3, x)
                              int sendingStatus = sendAction(3, 0);
                              if(sendingStatus == 1) {
                                for(int retries = 0; retries <= NOSENDRETRIES; retries++) {
                                  XBee.println("Trying again... ");
                                  delay(DELAY);
                                  sendingStatus = sendAction(3, 0);
                                  if(sendingStatus == 0 ) {
                                    actionOn = false; 
                                    xbee868.flush();
                                    return sendingStatus;
                                  }
                                }
                                XBee.println("Control Center -> Sensor Node: Stop fast mode not successful");
                                return sendingStatus;
                              }
                              else { 
                              
                              return sendingStatus;  
                          }
}

 int startPump(){
                  
   XBee.println("Control Center -> Actuator Node: Start valve");
                     // --- ON-Signal for valve on actuator node --> sendAction(1, 0)
                  int sendingStatus = sendAction(1, 0);
                  if(sendingStatus == 1) {
                    for(int retries = 0; retries <= NOSENDRETRIES; retries++) {
                      XBee.println("Trying again... ");
                      delay(DELAY);
                      sendingStatus = sendAction(1, 0);
                      if(sendingStatus == 0 ) { 
                        actionOn = true;
                        xbee868.flush();
                        return sendingStatus;
                      }
                    }
                    XBee.println("Control Center -> Actuator Node: Start valve not successful");
                    return sendingStatus;
                  }
                  else { 
                    actionOn = true; 
                    return sendingStatus;  
                  }
              
 }
 int stopPump(){
                  
   XBee.println("Control Center -> Actuator Node: Stop pump");
                      // --- When timer expires switch-off the valve in actuator node --> sendAction(4, x)
                          int sendingStatus = sendAction(4, 0);
                          if(sendingStatus == 1) {
                            for(int retries = 0; retries <= NOSENDRETRIES; retries++) {
                              XBee.println("Trying again... ");
                              delay(DELAY);
                              sendingStatus = sendAction(4, 0);
                              if(sendingStatus == 0 ) {
                                actionOn = false;
                                xbee868.flush();
                                return sendingStatus;
                              }
                            }
                            XBee.println("Control Center -> Actuator Node: Stop pump not successful");
                            return sendingStatus;
                          }
                          else { 
                          actionOn = false;
                          return sendingStatus;  
                      }
                  
                  }

// --- Wait for incoming packet
void receivePacket() {

	// --- Wait for two seconds
	//currentIter = millis();
	//while( (millis() - currentIter) < 2000 ) {
	
		if( XBee.available() )
		{
                        XBee.println("Control Center: Waiting for reply.");
			xbee868.treatData();
			if( !xbee868.error_RX )
			{
				// Writing the parameters of the packet received
				while(xbee868.pos>0)
				{
                                        // --- Print the packet content
					XBee.println("Control Center: Packet received.");
					
                                        // --- Look what message type it is
                                        // 'a' = Incoming values from sensor node "a;temp;humi;light;moistVal;"
                                        // 'j' = Incoming emergency stop from sensor node "j"
                                        if(xbee868.packet_finished[xbee868.pos-1]->data[0] == 'a') {
                                          
                                                char* payload = "";
                                                int i = 0;
                                                int j = 0;
                                                int k = 0;
                                                int end = 0;
                                                char* tmp = "";
                                                
                                                receivedFrom = 1;
                                                
                                                // --- Loop starting from 1 to skip the command char
                                                for(i=1; i < xbee868.packet_finished[xbee868.pos-1]->data_length; i++) {
                                                        payload[i-1] = xbee868.packet_finished[xbee868.pos-1]->data[i];
                                                        XBee.print(payload[i-1]);
                                                }
                                                end = i-1;
                                                // --- process the temp buffer
                                                for(i=0; i < end; i++) {
                                                        
                                                        // --- If there is not the delimiter fill buffer 
                                                        if(payload[i] != ';') {
                                                                tmp[j] = payload[i];
                                                                j++;
                                                        }
                                                        
                                                        else {
                                                                tmp[j] = '\0';
                                                                sensorValueArr[k] = atoi(tmp);
                                                                k++;
                                                                j=0;
                                                        }
                                                }
                                                  
                                               
                                        }
                                        
                                        // --- emergency stop message
                                        if(xbee868.packet_finished[xbee868.pos-1]->data[0] == 'j') {
                                          
                                          XBee.println("Emergency stop received.");
                                        
                                        }
                                        
                                        // --- Memory Management
					free(xbee868.packet_finished[xbee868.pos-1]);
					xbee868.packet_finished[xbee868.pos-1]=NULL;
					xbee868.pos--;
				}
                                //currentIter = millis();
			}
			else {
				XBee.println("Control Center: Error while receiving packet.");
			}
		}     
	//}
}


// --- Calculate uptime of the actuators
int calcUptime() {
  
        needWater = 0; 
        
        for(int i=0; i<=numberVal; i++) {
        
                XBee.print("Sensor value: "); XBee.print(i); XBee.print(": ");
                XBee.println(sensorValueArr[i]);
        }

        valveValue = 1;
        lightValue = 1;
        
        targetMoist = (moistRange[0] + moistRange[1]) /2;
        int diff = moistVal - targetMoist;
        int range = moistRange[1] - targetMoist;
        diff = diff - range;
        
        if(diff <= 0) {
          valveTimeout = 0;
        }
        else if(diff <= 100 && diff > 0) {
          valveTimeout = 3;
          needWater = 1;
        }
        else if(diff <= 200 && diff > 100) {
          valveTimeout = 6;
          needWater = 1;
        }
        else if(diff <= 400 && diff > 200) {
          valveTimeout = 9;
          needWater = 1;
        }
        else if (diff > 400){
          valveTimeout = 12;
          needWater = 1;
        }
        
        XBee.print("Timeout: ");
        XBee.println(valveTimeout);
        XBee.print("Need water: ");
        XBee.println(needWater);
        return needWater;
}


// --- Start timer with the uptime buffer as limit
bool valveTimer() {
  
      bool timerExp = false;
      
      valveStop = millis();
      if( (millis()-valveStop) < valveTimeout ) {
      
              timerExp = true;
      }
      return timerExp;
}

void print2UI(){

  // --- SENSOR
  for(int i=0; i <= 3; i++) {
    sprintf(data, "S:CC:SENSOR:%d:%d:E", i+1, sensorValueArr[i]);
	USB.println(data);
	delay(100);
  }

  // --- RANGE
  USB.print("S:CC:RANGE:");
  USB.print(tempRange[0]);
  USB.print(":");
  USB.print(tempRange[1]);
  USB.print(":");
  USB.print(humRange[0]);
  USB.print(":");
  USB.print(humRange[1]);
  USB.print(":");
  USB.print(lightRange[0]);
  USB.print(":");
  USB.print(lightRange[1]);
  USB.print(":");
  USB.print(moistRange[0]);
  USB.print(":");
  USB.print(moistRange[1]);
  USB.println(":E");
   
}

void print2UIactuator() {

    // --- ACTUATOR (Pump)
  USB.print("S:CC:ACTUATOR:1:");
  USB.print(millis()-timeStamp); // timeStamp needs to be global now
  USB.print(":");
  USB.print(valveTimeout*1000); 
  USB.println(":E");
  
  // --- ACTUATOR (Light)
  USB.print("S:CC:ACTUATOR:2:");
  USB.print(millis()-timeStamp); // timeStamp needs to be global now
  USB.print(":");
  USB.print(lightTimeout*1000); 
  USB.println(":E"); 
}

void loop() {

	receivePacket();

        // --- Packet received from Sensor Node
        if(receivedFrom == 1) {
          
          
              print2UI();
              
              
              // --- Did ranges change through UI or the first time Sensor sends data to Control Center
              if(rangesChanged == true) {
                sendRanges();
                rangesChanged = false;
              }
              
              needWater = calcUptime();
              int ret = 1;
              if(needWater == 1) { // Plant needs water
                  
               ret = startFastMode();
             
                 
                
                  if(ret == 1){ // fastmode probably not active
                    
                  }
                  else{// fastmode probably active
                  
                    ret = startPump();
                    if(ret == 1){ //  pump probably not active
                        
                      stopFastMode();
                      //go back to start
                    }
                    else{ // pump probably active
                    
                   
                      timeStamp = millis();
                      long currentTime = 0;
                      int timegap = 2000;
                        
                      while( actionOn == true && (millis()-timeStamp) < valveTimeout*1000 ){
                      
                         receivePacket();
                         
                            if(millis()-timeStamp > timegap) {
                               print2UIactuator();
                               timegap += 2000;
                            }
                         }                        
                         
                      }
                      stopPump(); //timeout exp
                      stopFastMode();
                    }
                  }
              } 
          
          
        receivedFrom = 0;
}

