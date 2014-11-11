/*
 * DH11.h
 *
 *  Created on: 2012. 12. 12.
 *      Author: dalxx
 *      Version : 0.8
 */

#ifndef DHT11_H_
#define DHT11_H_

#include <Wire.h>


#include "WaspClasses.h"
#include "wiring_private.h"
#include "pins_waspmote.h"

#define DHT11_RETRY_DELAY 2000  // 1000ms

class DHT11 {
	int pin;
	unsigned long last_read_time;
protected:

	byte readByte();
	unsigned long waitFor(uint8_t target, unsigned long time_out_us);
	void waitFor(uint8_t target);
public:
	DHT11(int pin_number);
	~DHT11();
	int read( int& humidity, int& temperature);



};


#endif /* DHT11_H_ */
