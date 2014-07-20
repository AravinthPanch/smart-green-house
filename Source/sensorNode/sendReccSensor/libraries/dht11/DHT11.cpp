/*
 * DH11.cpp
 *
 *  Created on: 2012. 12. 12.
 *      Author: dalxx
 */

#include "DHT11.h"



unsigned long microS = 0;
unsigned long width = 0; // keep initialization out of time critical area

unsigned long micros(){
		
		
	// convert the reading to microseconds. The loop has been determined
	// to be 10 clock cycles long and have about 12 clocks between the edge
	// and the start of the loop. There will be some error introduced by
	// the interrupt handlers.
	return clockCyclesToMicroseconds(width * 10 + 12); 

}

DHT11::DHT11(int pin_number) {
	this->pin=pin_number;
	this->last_read_time=0;
	pinMode(pin,INPUT);
	digitalWrite(pin, HIGH);

}
//wait for target status
//parameters
//  target : target status waiting for
//  time_out_us : time out in microsecond.
unsigned long DHT11::waitFor(uint8_t target, unsigned long time_out_us) {
	unsigned long start=micros();
	unsigned long time_out=start+time_out_us;
	
	uint8_t bit = digitalPinToBitMask(pin);
	uint8_t port = digitalPinToPort(pin);
	uint8_t stateMask = (target ? bit : 0);
	
	while ((*portInputRegister(port) & bit) != stateMask) width++;
	
	/*
	while(digitalRead(this->pin)!=target)
	{
		width++;
		//if(time_out<micros()) return -1;
	}
	*/
	return micros()-start;
}

//wait for target status.
void DHT11::waitFor(uint8_t target) {
	while(digitalRead(this->pin)!=target);
}

//read one bye
byte DHT11::readByte() {
	int i=0;
	byte ret=0;
	for(i=7;i>=0;i--)
	{
		waitFor(HIGH); //wait for 50us in LOW status
		delayMicroseconds(30); //wait for 30us
		if(digitalRead(this->pin)==HIGH) //if HIGH status lasts for 30us, the bit is 1;
		{
			ret|=1<<(i);
			waitFor(LOW); //wait for rest time in HIGH status.
		}
	}
	return ret;
}

DHT11::~DHT11() {
	// TODO Auto-generated destructor stub
}
//parameters
//	temperature : temperature to read.
//	humidity : humidity to read.
//return -1 : read too shortly. retry latter .
//		  0 : read successfully
//        1 : DHT11 not ready.
//		  4 : Checksum Error
int DHT11::read(int& humidity, int& temperature) {
	width = 0;
	if((millis()-this->last_read_time<DHT11_RETRY_DELAY)&&this->last_read_time!=0)	return -1;

	pinMode(pin,OUTPUT);
	digitalWrite(pin, LOW);
	delay(18);
	digitalWrite(pin, HIGH);
	pinMode(pin,INPUT);

	if(waitFor(LOW, 40)<0)	return 1; //waiting for DH11 ready
	if(waitFor(HIGH, 90)<0)	return 1; //waiting for first LOW signal(80us)
	if(waitFor(LOW, 90)<0)	return 1; //waiting for first HIGH signal(80us)

	byte hI=this->readByte();
	byte hF=this->readByte();
	byte tI=this->readByte();
	byte tF=this->readByte();
	byte cksum=this->readByte();
	if(hI+hF+tI+tF!=cksum)
		return 4;


	humidity=(float)hI+(((float)hF)/100.0F);
	temperature=(float)tI+(((float)tF)/100.0F);
	this->last_read_time=millis();
	return 0;
}


