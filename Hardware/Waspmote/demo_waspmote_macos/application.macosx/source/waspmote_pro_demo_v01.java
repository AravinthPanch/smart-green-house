import processing.core.*; 
import processing.xml.*; 

import processing.serial.*; 
import fullscreen.*; 
import shapes3d.utils.*; 
import shapes3d.*; 
import sprites.*; 
import guicomponents.*; 
import gifAnimation.*; 

import java.applet.*; 
import java.awt.*; 
import java.awt.image.*; 
import java.awt.event.*; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class waspmote_pro_demo_v01 extends PApplet {

/**
 *  ------Waspmote Demo------ 
 * 
 *  Explanation: Waspmote Demo for accelerometer, gases, and events sensor boards
 * 
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
 *  Version:           0.1 
 *  Design:            David Gasc\u00f3n 
 *  Implementation:    Alberto Bielsa, Marcos Yarza, Yuri Carmona
 */

/******************************
 *          IMPORTS           *
 ******************************/


Serial[] myPort = new Serial[5];
int inByte = -1;
 






/******************************
 *          VARIABLES         *
 ******************************/

Gif gif_liquid;
Gif gif_liquid2;

Gif gif_hall;
Gif gif_hall2; 

Gif gif_pir;
Gif gif_pir2;

// ACC VARIABLES
float valx = 0;
float valy = 0;
float valz = 1124;

float valx_old = 0;
float valy_old = 0;
float valz_old = 0;

int acc_x=0;
int acc_y=0;
int acc_z=0; 
int acc_signal=0;
int bat_signal=0;

int ACC_FLAG_X=1;
int ACC_FLAG_Y=2;
int ACC_FLAG_Z=4; 

Box box;

// GASES VARIABLES
float temp_signal=0;
float hum_signal=0;
float press_signal=0;
float o2_signal=0; 
int o2_max=52;
int co_min=50;
float co_signal=0;

// Sprite that has been clicked on
Sprite[] selSprite = new Sprite[2];

// EVENTS VARIABLES
//int BEND_FLAG = 2; 
int LIGHT_FLAG = 2;
int PRESS_FLAG = 16;
int HALL_FLAG = 32; 
int PIR_FLAG = 64;
int LIQ_FLAG = 128;

float light_signal = 0;
float bend_signal = 0;
float press2_signal = 0;
float pir_signal = 0;
int flag_event = 0; 

int light_act = 0;
int press_act = 0;
int pir_act = 0;
int liq_act = 0;
int bend_act = 0;
int hall_act = 0;

int liq_ant=0;
int hall_ant=0;
int pir_ant=0;

boolean hall_open=false;
int hall_time=0;
int hall_first=1;

// ACTUATOR VARIABLES
int[] mensaje_green = {  
  0x7E,0x00,0x0C,0x00,0x52,0x00,0x00,0x00,0x00,0x00,0x00,0xFF,0xFF,0x00,0x01,0xAE};
int[] mensaje_red = { 
  0x7E,0x00,0x0C,0x00,0x52,0x00,0x00,0x00,0x00,0x00,0x00,0xFF,0xFF,0x00,0x00,0xAF}; 
int actuator_act=2;
int actuator_change=0;

// GLOBAL VARIABLES
int RSSI=0;
int i=0;
char[] readByte = new char[150];
String[] selectPort;
String[] list_port;
int continue_pressed = 0;
int port_picked = 0;
String trama1;
String trama2;
String trama3;

int num = 0;
int wichKey = -1;
int second_free = 0;
int selected=0;
int init_screen=1;
int init_first=1;
int[] init_counter = {
  100,100,100,100};
int counter_port=0;
int counter_port2=0;
int press_box=0;
int data_in=0;
int r=0;
float previous=0.0f;
int program_state=0; // begin in manual MODE!!!
int next_program_state=0;
int inside_looking_usb=0;
int drawing_auto=0;
int counter_auto=0;

String[] n1;
String[] n2;
String[] n3;
String[] list1;
String[] list2;
String[] list3;
float[] acc;
float[] gas;
float[] eve;

String[] ports_usb = new String[] {
  "USB0", "USB1", "USB2", "USB3"};

String[] ports_com = new String[] {
  "COM0","COM1","COM2","COM3","COM4","COM5","COM6","COM7","COM8","COM9","COM10","COM11","COM12","COM13","COM14","COM15","COM16","COM17","COM18","COM19","COM20","COM21","COM22"
    ,"COM23","COM24","COM25","COM26","COM27","COM28","COM29","COM30","COM31","COM32","COM33","COM34","COM35","COM36","COM37","COM38","COM39","COM40","COM41","COM42","COM43"
    ,"COM44","COM45","COM46","COM47","COM48","COM49","COM50"};

String[] ports_com_10 = new String[] {
  "10", "11", "12", "13", "14", "15", "16", "17", "18", "19"};
String[] ports_com_20 = new String[] {
  "20", "21", "22", "23", "24", "25", "26", "27", "28", "29"};
String[] ports_com_30 = new String[] {
  "30", "31", "32", "33", "34", "35", "36", "37", "38", "39"};
String[] ports_com_40 = new String[] {
  "40", "41", "42", "43", "44", "45", "46", "47", "48", "49"};   


int act=0;
String portName;

PFont fontA;

FullScreen fs; 

/******************************
 *          IMAGES            *
 ******************************/

PImage bg;
PImage bg1;
PImage com_0; 
PImage com_1; 
PImage com_2; 
PImage com_3; 
PImage com_4; 
PImage com_5; 
PImage com_6; 
PImage com_7; 
PImage com_8; 
PImage com_9; 
PImage com_10; 
PImage com_11; 
PImage com_12; 
PImage com_13; 
PImage com_14; 
PImage com_15; 
PImage com_16; 
PImage com_17; 
PImage com_18; 
PImage com_19; 
PImage com_20;
PImage com_21;
PImage com_22;
PImage com_23;
PImage com_24;
PImage com_25;
PImage com_26;
PImage com_27;
PImage com_28;
PImage com_29;
PImage com_30;
PImage com_31;
PImage com_32;
PImage com_33;
PImage com_34;
PImage com_35;
PImage com_36;
PImage com_37;
PImage com_38;
PImage com_39;
PImage com_40;
PImage com_41;
PImage com_42;
PImage com_43;
PImage com_44;
PImage com_45;
PImage com_46;
PImage com_47;
PImage com_48;
PImage com_49;
PImage com_50;
PImage usb_0; 
PImage usb_1; 
PImage usb_2; 
PImage usb_3; 
PImage tick; 
PImage but_con; 
PImage screen1;
PImage screen2; 
PImage working; 
PImage manual_usb; 
PImage auto_usb;  
PImage screen3;  
PImage countdown;  
PImage countdown1;  
PImage countdown2;  
PImage countdown3;  
PImage countdown4;  
PImage countdown5;  
PImage screen4;  

PImage image_x;
PImage image_y;
PImage image_z;
PImage free_x;
PImage free_y;
PImage free_z;
PImage temp_ind;
PImage o2_ind;
PImage co_ind;
PImage light_0;
PImage light_10;
PImage light_20;
PImage light_30;
PImage light_40;
PImage light_50;
PImage light_60;
PImage light_70;
PImage light_80;
PImage light_90;
PImage light_100;
PImage press_0;
PImage press_10;
PImage press_20;
PImage press_30;
PImage press_40;
PImage press_50;
PImage press_60;
PImage press_70;
PImage press_80;
PImage press_90;
PImage press_100;
PImage bend_0;
PImage bend_10;
PImage bend_20;
PImage bend_30;
PImage bend_40;
PImage bend_50;
PImage bend_60;
PImage bend_70;
PImage bend_80;
PImage bend_90; 
PImage hall1; 
PImage hall2;  
PImage press_red;  
PImage press_green;  
PImage bend_red;  
PImage bend_green;  
PImage liq_red; 
PImage pir_red; 
PImage hall_red; 
PImage cob_0;  
PImage cob_1;  
PImage cob_2;  
PImage cob_3;  
PImage cob_4;  
PImage bat_0;  
PImage bat_1;  
PImage bat_2;  
PImage bat_3;  
PImage bat_4;  
PImage act_on;  
PImage act_off;  

/******************************
 *           SETUP            *
 ******************************/

public void setup()
{

  println("This is the waspmote-pro DEMO");

  size(1024,769,P3D);

  // Load the font. Fonts must be placed within the data 
  // directory of your sketch. A font must first be created
  // using the 'Create Font...' option in the Tools menu.
  fontA = loadFont("LucidaSans-48.vlw");
  textAlign(CENTER);

  // Set the font and its size (in units of pixels)
  textFont(fontA, 16);

  // 5 fps
  frameRate(5);

  // Create the fullscreen object
  fs = new FullScreen(this); 

  // enter fullscreen mode
  fs.enter(); 

  // Program Background
  bg = loadImage("demo_waspmote_1024.png");
  bg1 = loadImage("portada.png");

  // Select Port
  com_0 = loadImage("com_0.png");
  com_1 = loadImage("com_1.png");
  com_2 = loadImage("com_2.png");
  com_3 = loadImage("com_3.png");
  com_4 = loadImage("com_4.png");
  com_5 = loadImage("com_5.png");
  com_6 = loadImage("com_6.png");
  com_7 = loadImage("com_7.png");
  com_8 = loadImage("com_8.png");
  com_9 = loadImage("com_9.png");
  com_10 = loadImage("com_10.png");
  com_11 = loadImage("com_11.png");
  com_12 = loadImage("com_12.png");
  com_13 = loadImage("com_13.png");
  com_14 = loadImage("com_14.png");
  com_15 = loadImage("com_15.png");
  com_16 = loadImage("com_16.png");
  com_17 = loadImage("com_17.png");
  com_18 = loadImage("com_18.png");
  com_19 = loadImage("com_19.png");
  com_20 = loadImage("com_20.png");
  com_21 = loadImage("com_21.png");
  com_22 = loadImage("com_22.png");
  com_23 = loadImage("com_23.png");
  com_24 = loadImage("com_24.png");
  com_25 = loadImage("com_25.png");
  com_26 = loadImage("com_26.png");
  com_27 = loadImage("com_27.png");
  com_28 = loadImage("com_28.png");
  com_29 = loadImage("com_29.png");
  com_30 = loadImage("com_30.png");
  com_31 = loadImage("com_31.png");
  com_32 = loadImage("com_32.png");
  com_33 = loadImage("com_33.png");
  com_34 = loadImage("com_34.png");
  com_35 = loadImage("com_35.png");
  com_36 = loadImage("com_36.png");
  com_37 = loadImage("com_37.png");
  com_38 = loadImage("com_38.png");
  com_39 = loadImage("com_39.png");
  com_40 = loadImage("com_40.png");
  com_41 = loadImage("com_41.png");
  com_42 = loadImage("com_42.png");
  com_43 = loadImage("com_43.png");
  com_44 = loadImage("com_44.png");
  com_45 = loadImage("com_45.png");
  com_46 = loadImage("com_46.png");
  com_47 = loadImage("com_47.png");
  com_48 = loadImage("com_48.png");
  com_49 = loadImage("com_49.png");
  com_50 = loadImage("com_50.png");
  usb_0 = loadImage("usb_0.png");
  usb_1 = loadImage("usb_1.png");
  usb_2 = loadImage("usb_2.png");
  usb_3 = loadImage("usb_3.png");
  tick = loadImage("tick.png");
  but_con = loadImage("boton_continuar.png");
  screen1 = loadImage("portada_2.png");
  screen2 = loadImage("portada_3.png");
  working = loadImage("punto.png");
  manual_usb = loadImage("manual.png");
  auto_usb = loadImage("automatic.png");
  screen3 = loadImage("portada_4.png");
  countdown = loadImage("countdown_0.png");
  countdown1 = loadImage("countdown_1.png");
  countdown2 = loadImage("countdown_2.png");
  countdown3 = loadImage("countdown_3.png");
  countdown4 = loadImage("countdown_4.png");
  countdown5 = loadImage("countdown_5.png");
  screen4 = loadImage("portada_5.png");

  // Axis Acceleration Images
  image_x = loadImage("acceleracion_barra_x.png");
  image_y = loadImage("acceleracion_barra_y.png");
  image_z = loadImage("acceleracion_barra_z.png");

  // Acceleration Free Falls Examples
  free_x = loadImage("alarmas_x.png");
  free_y = loadImage("alarmas_y.png");
  free_z = loadImage("alarmas_z.png");  

  // Accelerometer Box
  box = new Box(this);
  String[] faces = new String[] {
    "back_waspmote.png", "front_waspmote.png", "short_side_wasp.png",
    "short_side_wasp.png", "long_side_wasp.png", "long_side_wasp.png"      };
  box.setTextures(faces);
  box.setSize(140, 84, 5);

  // Gases Images
  selSprite[0] = new Sprite(this, "aguja_indicadora.png", 10);
  selSprite[0].setXY(395, 655);

  selSprite[1] = new Sprite(this, "aguja_indicadora.png", 10);
  selSprite[1].setXY(395, 485);

  temp_ind = loadImage("mercurio.png");
  o2_ind = loadImage("oxigeno2.png");
  co_ind = loadImage("oxigeno.png");

  // Events Images
  light_0 = loadImage("bombilla_luz_00.png");
  light_10 = loadImage("bombilla_luz_10.png");
  light_20 = loadImage("bombilla_luz_20.png");
  light_30 = loadImage("bombilla_luz_30.png");
  light_40 = loadImage("bombilla_luz_40.png");
  light_50 = loadImage("bombilla_luz_50.png");
  light_60 = loadImage("bombilla_luz_60.png");
  light_70 = loadImage("bombilla_luz_70.png");
  light_80 = loadImage("bombilla_luz_80.png");
  light_90 = loadImage("bombilla_luz_90.png");
  light_100 = loadImage("bombilla_luz_100.png");

  press_0 = loadImage("presion_dedo_0.png");
  press_10 = loadImage("presion_dedo_1.png");
  press_20 = loadImage("presion_dedo_2.png");
  press_30 = loadImage("presion_dedo_3.png");
  press_40 = loadImage("presion_dedo_4.png");
  press_50 = loadImage("presion_dedo_5.png");
  press_60 = loadImage("presion_dedo_6.png");
  press_70 = loadImage("presion_dedo_7.png");
  press_80 = loadImage("presion_dedo_8.png");
  press_90 = loadImage("presion_dedo_9.png");
  press_100 = loadImage("presion_dedo_10.png");

  bend_0 = loadImage("bendings_0.png");
  bend_10 = loadImage("bendings_1.png");
  bend_20 = loadImage("bendings_2.png");
  bend_30 = loadImage("bendings_3.png");
  bend_40 = loadImage("bendings_4.png");
  bend_50 = loadImage("bendings_5.png");
  bend_60 = loadImage("bendings_6.png");
  bend_70 = loadImage("bendings_7.png");
  bend_80 = loadImage("bendings_8.png");
  bend_90 = loadImage("bendings_9.png");  

  gif_liquid = new Gif(this, "liquido_in.gif");
  gif_liquid2 = new Gif(this, "liquido_out.gif");

  gif_hall = new Gif(this, "hall_effect_open.gif");
  gif_hall2 = new Gif(this, "hall_effect_close.gif");

  gif_pir = new Gif(this, "pir_on.gif");
  gif_pir2 = new Gif(this, "pir_off.gif");

  hall1 = loadImage("hall_effect_cerrado.png");
  hall2 = loadImage("hall_effect_abierto.png");

  press_green = loadImage("pressure_verde.png");
  press_red = loadImage("pressure_rojo.png");

  bend_green = loadImage("bending_verde.png");
  bend_red = loadImage("bending_rojo.png");

  liq_red = loadImage("liquid_rojo.png");

  pir_red = loadImage("pir_rojo.png");

  hall_red = loadImage("hall_rojo.png");

  cob_0 = loadImage("cobertura_0.png");
  cob_1 = loadImage("cobertura_1.png");
  cob_2 = loadImage("cobertura_2.png");
  cob_3 = loadImage("cobertura_3.png");
  cob_4 = loadImage("cobertura_4.png");

  bat_0 = loadImage("bateria_0.png");
  bat_1 = loadImage("bateria_1.png");
  bat_2 = loadImage("bateria_2.png");
  bat_3 = loadImage("bateria_3.png");
  bat_4 = loadImage("bateria_4.png");

  act_on = loadImage("green_actuator.png");
  act_off = loadImage("red_actuator.png");
}

/******************************
 *             LOOP           *
 ******************************/

public void draw()
{

  delay(10);

  switch( program_state )
  {
  case 0:   
    initial_screen();
    break;
  case 1:  
    automaticDetection();
    break;
  case 2:  
    drawManualDetection();
    break;
  case 3:  
    selectSerialPort();
    break;
  case 4:  
    drawAutoDetection();
    break;
  case 5:  
    getSerialData(myPort[r]);
    demo();
    break;
  case 6:  
    error_screen();
    break;
  }

}

/******************************
 *    INTERNAL FUNCTIONS      *
 ******************************/

/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void initial_screen()
{
  background(screen1);
  image(manual_usb,250,300);
  image(auto_usb,250,400);
  if(next_program_state==4)
  {
    image(tick,440,400);
    image(but_con,250,650);
  }
  if(next_program_state==2)
  {
    image(tick,440,300);
    image(but_con,250,650);
  }
}

/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void error_screen()
{
  background(screen4);   
}

/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void demo()
{
  background(bg);
  fill(0);

  // Drawing Accelerometer Section
  drawAccelerometer();

  // Drawing Gases Section
  drawGases();

  // Drawing Events Section
  drawEvents();

  // Drawing RSSI
  drawRSSI();

  // Drawing Battery Level
  drawBattery();

  // Drawing Actuator
  drawActuator();

}

/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void automaticDetection()
{
  background(screen2);
  image(working,360,198);
  image(working,370,198);
  image(working,380,198);


  if(inside_looking_usb==0){
    if(r>=Serial.list().length) program_state=6;
    else{
      portName = Serial.list()[r];
      myPort[r] = new Serial(this, portName, 115200);
      myPort[r].bufferUntil('$');
      r++;
      previous=millis();
    }
  }
  checkTimeAuto();      
}

/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void checkTimeAuto()
{
  if( (millis()-previous)>1000 ){
    inside_looking_usb=0;
    myPort[r-1].stop();
  }
  else inside_looking_usb=1;
  if(data_in==1) program_state=5;
}

/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void checkTimeDrawAuto()
{
  if( (millis()-previous)>1000){
    drawing_auto=0;
    counter_auto++;
  }
  else drawing_auto=1;
}

/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void drawManualDetection()
{
  background(screen2);
  image(working,360,198);
  image(working,370,198);
  image(working,380,198);
  program_state=3;
}

/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void drawAutoDetection()
{
  background(screen3);
  switch( counter_auto )
  {
  case 0: 
    image(countdown5,300,400);
    break;
  case 1: 
    image(countdown4,300,400);
    break;
  case 2: 
    image(countdown3,300,400);
    break;
  case 3: 
    image(countdown2,300,400);
    break;
  case 4: 
    image(countdown1,300,400);
    break;
  case 5: 
    program_state=1;
    image(countdown,300,400);
    break;
  }
  if(drawing_auto==0) previous=millis();
  checkTimeDrawAuto();  
}


/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void selectSerialPort()
{
  background(bg1);

  // Drawing the serial port buttons
  if(init_first==1){
    counter_port=0;
    while(counter_port<Serial.list().length){
      drawPort(counter_port);
      counter_port++;
      if(counter_port==3) break;
    }
    init_first=0;
  }

  if(init_counter[3]==100) program_state=6;

  counter_port2=0;
  while(counter_port2<counter_port){
    drawPort_internal(counter_port2,init_counter[counter_port2],init_counter[3]);
    counter_port2++;
  }

  if(press_box==1){
    image(tick,405,348);
    image(but_con,250,650);
  }

  if(press_box==2){
    image(tick,405,448);
    image(but_con,250,650);
  }

  if(press_box==3){
    image(tick,405,548);
    image(but_con,250,650);
  }

  if(continue_pressed==1)
  {
    portName = Serial.list()[port_picked];
    myPort[r] = new Serial(this, portName, 115200);
    myPort[r].bufferUntil('$');
    program_state=5;
  }

}

/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void drawPort(int counter){
  String[] aux;
  int match_found=0;
  int counter_int=0;

  while( counter_int<4  && match_found==0){
    aux = match(Serial.list()[counter],ports_usb[counter_int]);
    if(aux!=null) match_found=1;
    else counter_int++;
  }

  if( match_found==1 )
  {
    init_counter[counter]=counter_int;
    init_counter[3]=0;
  }
  else
  {     
    counter_int=0;
    while( counter_int<50 && match_found==0 ){       
      aux = match(Serial.list()[counter],ports_com[counter_int]);
      if(counter_int==1){
        i=0;
        while(i<10 && match_found==0){
          aux = match(Serial.list()[counter],ports_com_10[i]);
          if(aux!=null) match_found=1;
          else i++;
        } 
        if(match_found==0){
          aux = match(Serial.list()[counter],ports_com[counter_int]);
        }
        else counter_int=counter_int+9+i;
        i=0;
      }
      if(counter_int==2){
        i=0;
        while(i<10 && match_found==0){
          aux = match(Serial.list()[counter],ports_com_20[i]);
          if(aux!=null) match_found=1;
          else i++;
        } 
        if(match_found==0){
          aux = match(Serial.list()[counter],ports_com[counter_int]);
        }
        else counter_int=counter_int+19+i;
        i=0;
      }
      if(counter_int==3){
        i=0;
        while(i<10 && match_found==0){
          aux = match(Serial.list()[counter],ports_com_30[i]);
          if(aux!=null) match_found=1;
          else i++;
        } 
        if(match_found==0){
          aux = match(Serial.list()[counter],ports_com[counter_int]);
        }
        else counter_int=counter_int+29+i;
        i=0;
      }
      if(counter_int==4){
        i=0;
        while(i<10 && match_found==0){
          aux = match(Serial.list()[counter],ports_com_40[i]);
          if(aux!=null) match_found=1;
          else i++;
        } 
        if(match_found==0){
          aux = match(Serial.list()[counter],ports_com[counter_int]);
        }
        else counter_int=counter_int+39+i;
        i=0;
      }
      if(aux!=null) match_found=1;
      else counter_int++;
    }

    if( match_found==1 )
    {
      init_counter[counter]=counter_int;
      init_counter[3]=1;
    }
  }

}

/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void drawPort_internal(int pos, int port, int type)
{
  if( type==0 ) // USB PORTS
  {
    switch( port )
    {
    case 0:  
      image(usb_0,250,350+pos*100);
      break;
    case 1:  
      image(usb_1,250,350+pos*100);
      break;
    case 2:  
      image(usb_2,250,350+pos*100);
      break;
    case 3:  
      image(usb_3,250,350+pos*100);
      break;
    }
  }
  else if( type==1 )
  {
    switch( port )
    {
    case 0:  
      image(com_0,250,350+pos*100);
      break;
    case 1:  
      image(com_1,250,350+pos*100);
      break;
    case 2:  
      image(com_2,250,350+pos*100);
      break;
    case 3:  
      image(com_3,250,350+pos*100);
      break;
    case 4:  
      image(com_4,250,350+pos*100);
      break;
    case 5:  
      image(com_5,250,350+pos*100);
      break;
    case 6:  
      image(com_6,250,350+pos*100);
      break;
    case 7:  
      image(com_7,250,350+pos*100);
      break;
    case 8:  
      image(com_8,250,350+pos*100);
      break;
    case 9:  
      image(com_9,250,350+pos*100);
      break;
    case 10: 
      image(com_10,250,350+pos*100);
      break;
    case 11: 
      image(com_11,250,350+pos*100);
      break;
    case 12: 
      image(com_12,250,350+pos*100);
      break;
    case 13: 
      image(com_13,250,350+pos*100);
      break;
    case 14: 
      image(com_14,250,350+pos*100);
      break;
    case 15: 
      image(com_15,250,350+pos*100);
      break;
    case 16: 
      image(com_16,250,350+pos*100);
      break;
    case 17: 
      image(com_17,250,350+pos*100);
      break;
    case 18: 
      image(com_18,250,350+pos*100);
      break;
    case 19: 
      image(com_19,250,350+pos*100);
      break;
    case 20: 
      image(com_20,250,350+pos*100);
      break;
    case 21: 
      image(com_21,250,350+pos*100);
      break;
    case 22: 
      image(com_22,250,350+pos*100);
      break;
    case 23: 
      image(com_23,250,350+pos*100);
      break;
    case 24: 
      image(com_24,250,350+pos*100);
      break;
    case 25: 
      image(com_25,250,350+pos*100);
      break;
    case 26: 
      image(com_26,250,350+pos*100);
      break;
    case 27: 
      image(com_27,250,350+pos*100);
      break;
    case 28: 
      image(com_28,250,350+pos*100);
      break;         
    case 29: 
      image(com_29,250,350+pos*100);
      break;
    case 30: 
      image(com_30,250,350+pos*100);
      break;
    case 31: 
      image(com_31,250,350+pos*100);
      break;
    case 32: 
      image(com_32,250,350+pos*100);
      break;
    case 33: 
      image(com_33,250,350+pos*100);
      break;
    case 34: 
      image(com_34,250,350+pos*100);
      break;
    case 35: 
      image(com_35,250,350+pos*100);
      break;
    case 36: 
      image(com_36,250,350+pos*100);
      break;
    case 37: 
      image(com_37,250,350+pos*100);
      break;
    case 38: 
      image(com_38,250,350+pos*100);
      break;
    case 39: 
      image(com_39,250,350+pos*100);
      break;
    case 40: 
      image(com_40,250,350+pos*100);
      break;
    case 41: 
      image(com_41,250,350+pos*100);
      break;
    case 42: 
      image(com_42,250,350+pos*100);
      break;
    case 43: 
      image(com_43,250,350+pos*100);
      break;
    case 44: 
      image(com_44,250,350+pos*100);
      break;
    case 45: 
      image(com_45,250,350+pos*100);
      break;
    case 46: 
      image(com_46,250,350+pos*100);
      break;
    case 47: 
      image(com_47,250,350+pos*100);
      break;
    case 48: 
      image(com_48,250,350+pos*100);
      break;
    case 49: 
      image(com_49,250,350+pos*100);
      break;
    case 50: 
      image(com_50,250,350+pos*100);
      break;
    }
  }
}


/***********************************************************
 * serialEvent
 *
 * Reading Received Data by XBee. Possible frames:
 * - Accelerometer --> "ACC***%u,%u,%s,%s,%s,$"
 * - Events --> "EVE***%s,%s,%s,$"
 * -
 * - 
 *
 ***********************************************************/
//void serialEvent(Serial myPort) 
public void getSerialData(Serial port) 
{  
  drawLight(3.3f);
  // get all data and store it in 'readByte'
  while (port.available() > 0) 
  {
    readByte[i] = port.readChar();
    i++;  
  }
  // Clear the buffer, or available() will still be > 0:
  port.clear();

  int j=0;
  int aux_rssi=0;
  boolean rssi_start=false;

  aux_rssi=(int) readByte[j];

  while( !rssi_start )
  {
    if( aux_rssi==0x7E ) 
    {
      rssi_start=true;
    }
    else
    {
      j++;
      aux_rssi=(int) readByte[j];
      if(j>=100) rssi_start=true;
    }
  }

  if(j<100 && i>20) RSSI = (int) readByte[13+j];
  i=0;

  String mensaje = new String(readByte);

  //println(mensaje);

  // Check the kind of data
  n1 = match(mensaje,"ACC");
  if (n1 != null )
  { 
    list1 = split(mensaje,"***"); 
    trama1 = list1[1];

    acc = PApplet.parseFloat(split(trama1,','));
    bat_signal=PApplet.parseInt(acc[0]);
    acc_signal= PApplet.parseInt(acc[1]);
    valx = acc[2];
    valy = acc[3];
    valz = acc[4];  
  }
  else n2 = match(mensaje,"GAS");

  if (n2 != null )
  {    
    list2 = split(mensaje,"***"); 
    trama2 = list2[1];

    gas = PApplet.parseFloat(split(trama2,','));
    temp_signal = gas[0];
    hum_signal = gas[1];
    press_signal = gas[2];
    o2_signal = gas[3];
    co_signal = gas[4];
  }
  else n3 = match(mensaje,"EVE");

  if (n3 != null )
  { 
    list3 = split(mensaje,"***"); 
    trama3 = list3[1];

    eve = PApplet.parseFloat(split(trama3,','));
    flag_event= PApplet.parseInt(eve[0]);
    if( (flag_event & HALL_FLAG)>0 )
    {
      // except for the first time wait a period of time
      // before changing the hall effect image
      if( hall_first==1 )
      {
        hall_open= !(hall_open);
        hall_first=0;
      }
      else if( (millis()-hall_time)>=2000 ) hall_open= !(hall_open);

      hall_time=millis();   
    } 
    light_signal = eve[1];
    press2_signal = eve[2];
    pir_signal = eve[3];
  }

  if( n1!=null || n2!=null || n3!=null )
  {
    data_in=1;
  }
  n1=null;
  n2=null;
  n3=null;

}



/***********************************************************
 * 
 * Reset Free Fall Counter
 *
 ***********************************************************/
public void keyPressed()
{

  if (key == 'r'){
    num=0;
    acc_x=0;
    acc_y=0;
    acc_z=0;      
    pir_act=0;
    press_act = 0;
    liq_act = 0;
    bend_act = 0;
    hall_act = 0;
    hall_ant=0;
    pir_ant=0;
    liq_ant=0;
    hall_first=1;
    hall_open=false;
    gif_hall.stop();
    gif_hall2.stop();
    gif_pir.stop();
    gif_liquid.stop();
    gif_hall.jump(0);
    gif_hall2.jump(0);
    gif_pir.jump(0);
    gif_liquid.jump(0);
  }

  if( key=='q' ){
    program_state=0;
    next_program_state=0;
    counter_port=0;
    counter_port2=0;
    press_box=0;
    data_in=0;
    previous=0.0f;
    program_state=0;
    next_program_state=0;
    drawing_auto=0;
    counter_auto=0;
    if(continue_pressed==1){
      continue_pressed=0;
      myPort[r].stop();
    }
    init_first=1;   
    if(inside_looking_usb==1){ 
      inside_looking_usb=0;
      myPort[r-1].stop();
    }
    r=0;
    init_counter[0]=100;
    init_counter[1]=100;
    init_counter[2]=100;
    init_counter[3]=100;      
  }

}



/***********************************************************
 * 
 * Drawing Accelerometer Section
 * 
 * 
 *
 ***********************************************************/
public void drawAccelerometer()
{
  stroke(0);
  noFill();

  // Capturing interruptions
  if ( acc_signal > 0 )
  {
    // draw red circle
    image(free_x,350,196);
  }

  fill(0);

  // Drawing Axis Acceleration
  drawAxis();

  textAlign(RIGHT);
  fill(255,0,0);
  //text(num, 415,227,0);


  // Drawing 3D Box
  pushMatrix();

  translate(165, 210, 0);

  // rotate-X
  if ((valz<=1024.0f)&&(valz>=-1024.0f)) 
  {
    rotateX(asin(valz/1000.0f));
  }
  else 
  {
    rotateX(asin(valz_old/1124.0f));
  }

  // rotate-Z
  if ((valy<=1024)&&(valy>=-1024)) 
  {
    // dependiendo del eje x
    if ((valx<=1024)&&(valx>0)) 
    {      
      if ((valy<=1024)&&(valy>0)) 
      {        
        rotateZ((-asin(valy/1000.0f)-2*asin(valx/1000.0f))); 
      }
      else
      {
        rotateZ((-asin(valy/1000.0f)+2*asin(valx/1000.0f))); 
      }
    }
    else
    {      
      rotateZ(-asin(valy/1000.0f)); 
    }
  }
  else 
  {
    rotateZ(-asin(valy_old/1124.0f));  
  }

  box.draw();

  popMatrix();

  // Storing Previous Acceleration Values
  valx_old = valx;
  valy_old = valy;
  valz_old = valz;
}





/***********************************************************
 * 
 * Drawing Gas Section
 *
 ***********************************************************/
public void drawGases()
{ 
  stroke(0);

  int hum,press,o2,temp,co=0;

  textAlign(RIGHT);

  // temperature
  noFill();
  fill(0);  
  temp=PApplet.parseInt(temp_signal);
  if( temp<0 ) temp=0;
  text(temp,85,702);
  drawTemp(temp);

  // humidity
  noFill();
  fill(0);
  hum=(int) (hum_signal);
  if( hum<0 ) hum=0;  
  text(hum,415,694);
  drawHum(hum);

  // pressure
  noFill();
  fill(0);  
  press=PApplet.parseInt(press_signal);
  if( press<0 ) press=0;  
  text(press,410,526);
  drawPressAtm(press);

  // O2 
  noFill();
  fill(0);
  //o2=int(o2_signal*21/o2_max);  
  o2=PApplet.parseInt(o2_signal);
  if( o2<0 ) o2=0;  
  else if( o2>25 ) o2=25;
  text(o2,270,702);
  drawO2(o2);

  // CO
  noFill();
  fill(0);
  //co=int((co_signal-co_min)*100/(330-co_min));  
  co=PApplet.parseInt(co_signal);  
  if( co<0 ) co=0;  
  else if( co>100 ) o2=100;
  text(co,180,702);
  drawCO(co);

  noFill();

}




/***********************************************************
 * 
 * Drawing Events Section
 *
 ***********************************************************/
public void drawEvents()
{ 
  stroke(0);
  int bending=0;

  if ((flag_event & PRESS_FLAG)>0)
  {
    press_act = 1;
  }
  else
  {
    press_act = 0;
  }
  
  // update pir actuation from frame
  pir_act = (int)pir_signal;
  
  if ((flag_event & LIQ_FLAG)>0)
  {
    liq_act = 1;
  }
  ///// DEPRECATED
  //  if ((flag_event & BEND_FLAG)>0)
  //  {
  //    bend_act = 1;
  //  }
  if ((flag_event & HALL_FLAG)>0)
  {
    hall_act = 1;
    println("\n-----------------------> hall activated!");
  }

  textAlign(CENTER);
  noFill();
  fill(0);
  if( light_signal<0 ) light_signal=0;
  text(PApplet.parseInt(light_signal*100/33),680,405);  
  drawLight(light_signal);
  
  noFill();
  fill(0);
  if( press2_signal<0 ) press2_signal=0;
  text(PApplet.parseInt((press2_signal/10)*4.54f),680,227);
  drawPress(press2_signal);

  noFill();
  fill(0);

  drawLiquid();
  drawHall();
  drawPIR();



}




/***********************************************************
 * 
 * Drawing Acceleration on 3 Axis
 *
 ***********************************************************/
public void drawAxis(){

  int number=0;
  int aux_x,aux_y,aux_z=0;

  aux_x = (int)valx/256;
  aux_y = (int)valy/256;
  aux_z = (int)valz/256;  


  drawAxis_internal(aux_x,120,0);

  drawAxis_internal(aux_y,146,1);

  drawAxis_internal(aux_z,171,2);

}






/***********************************************************
 * 
 * Internal function to draw the acc on 3 axis
 *
 ***********************************************************/
public void drawAxis_internal(int number, int Y, int axis){
  pushMatrix();

  switch(number){

  case 0:  
    translate(405,Y);
    break;
  case 1:  
    translate(405,Y);
    scale(3,1);
    break;
  case 2:  
    translate(405,Y);
    scale(4,1);
    break;
  case 3:  
    translate(405,Y);
    scale(5,1);
    break;
  case 4:  
    translate(405,Y);
    scale(6,1);
    break;
  case 5:  
    translate(405,Y);
    scale(7,1);
    break;
  case 6:  
    translate(405,Y);
    scale(8,1);
    break;
  case 7:  
    translate(405,Y);
    scale(9,1);
    break;        
  case -1: 
    translate(393,Y);
    scale(3,1);
    break;
  case -2: 
    translate(385,Y);
    scale(4,1);
    break;
  case -3: 
    translate(377,Y);
    scale(5,1);
    break;
  case -4: 
    translate(369,Y);
    scale(6,1);
    break;
  case -5: 
    translate(361,Y);
    scale(7,1);
    break;
  case -6: 
    translate(353,Y);
    scale(8,1);
    break;
  case -7: 
    translate(345,Y);
    scale(9,1);
    break;         
  }

  if( axis==0 ) image(image_x,0,0);
  else if( axis==1 ) image(image_y,0,0);
  else if( axis==2 ) image(image_z,0,0);

  popMatrix();
}




/***********************************************************
 * 
 * drawHum
 *
 ***********************************************************/
public void drawHum(int hum){

  int ang=230;

  ang+=(int) ((hum/2)*5.2f);

  pushMatrix();

  selSprite[0].setRot(radians(ang));
  S4P.drawSprites();
  imageMode(CORNER);

  popMatrix();


}




/***********************************************************
 * 
 * drawPressAtm
 *
 ***********************************************************/
public void drawPressAtm(int press){

  int ang=230;

  if( (press>=90) && (press<98) ) ang+=(int) ( (press-90)*12.5f );
  else if( (press>=98) && (press<104) ) ang+=(int) ( (press-90)*13 );
  else if( (press>=104) && (press<108) ) ang+=(int) ( (press-90)*13.3f );
  else if( (press>=108) ) ang+=(int) ( (press-90)*13.1f );

  pushMatrix();

  selSprite[1].setRot(radians(ang));
  S4P.drawSprites();
  imageMode(CORNER);

  popMatrix();


}




/***********************************************************
 * 
 * drawO2
 *
 ***********************************************************/
public void drawO2(int o2){

  int ax_x,esc_o2=0;
  int pixel_start=643;
  float pixel_o2 = 15.3f;
  float o2_int=o2-15;

  if(o2_int<0) o2_int=0;

  float parte1 = (o2_int/2);
  int parte2 = (int) ( parte1*pixel_o2 );
  ax_x = ( pixel_start - parte2 ) + 1;
  esc_o2 = (int) ( (o2_int/2)*pixel_o2 );

  if( (ax_x+esc_o2)>(pixel_start+1) ){
    ax_x=pixel_start;
    esc_o2=1;
  }

  pushMatrix();
  translate(244,ax_x);
  imageMode(CENTER);   
  scale(1,esc_o2);
  image(o2_ind,0,0);
  imageMode(CORNER);   
  popMatrix();

}




/***********************************************************
 * 
 * drawCO
 *
 ***********************************************************/
public void drawCO(int co){

  int ax_x,esc_o2=0;
  int pixel_start=643;
  float pixel_o2 = 1.53f;
  float o2_int=co;

  if(o2_int<0) o2_int=0;

  float parte1 = (o2_int/2);
  int parte2 = (int) ( parte1*pixel_o2 );
  ax_x = ( pixel_start - parte2 ) + 1;
  esc_o2 = (int) ( (o2_int/2)*pixel_o2 );

  if( (ax_x+esc_o2)>(pixel_start+1) ){
    ax_x=pixel_start;
    esc_o2=1;
  }

  pushMatrix();
  translate(150,ax_x);
  imageMode(CENTER);   
  scale(1,esc_o2);
  image(co_ind,0,0);
  imageMode(CORNER);   
  popMatrix();

}



/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void drawTemp(int temp){
  int ax_x,esc_temp=0;
  int pixel_start=640;
  float pixel_celsius = 3.75f;

  ax_x = ( pixel_start - (int) ( (temp/2)*pixel_celsius ) ) + 1;
  esc_temp = (int) ( (temp/2)*pixel_celsius );

  if( (ax_x+esc_temp)>(pixel_start+1) ){
    ax_x=pixel_start;
    esc_temp=1;
  }

  pushMatrix();
  translate(75,ax_x);
  imageMode(CENTER);   
  scale(1,esc_temp);
  image(temp_ind,0,0);
  imageMode(CORNER);   
  popMatrix();
}



/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void drawLight(float light_signal){

  int light=0;

  light=(int) ((light_signal*10)/33);

  switch( light ){

  case 0: 
    image(light_0,615,285);
    break;
  case 1: 
    image(light_10,615,285);
    break;
  case 2: 
    image(light_20,615,285);
    break;
  case 3: 
    image(light_30,615,285);
    break;
  case 4: 
    image(light_40,615,285);
    break;
  case 5: 
    image(light_50,615,285);
    break;
  case 6: 
    image(light_60,615,285);
    break;
  case 7: 
    image(light_70,615,285);
    break;
  case 8: 
    image(light_80,615,285);
    break;
  case 9: 
    image(light_90,615,285);
    break;
  case 10:
    image(light_100,615,285);
    break;  
  }     

}



/***********************************************************
 * 
 * drawPress
 *
 ***********************************************************/
public void drawPress(float press)
{
  float press2=0;

  press2=press/10;

  if( press_act==1 ) image(press_red,590,80);
  //else if( press_act==0 && press2>0.4) image(press_green,590,80);     

  if( press2<0.5f ) image(press_0,620,130);
  else if( (press2>=0.5f)&&(press2<0.78f) ) image(press_10,620,130);
  else if( (press2>=0.78f)&&(press2<1.06f) ) image(press_20,620,130);
  else if( (press2>=1.06f)&&(press2<1.34f) ) image(press_30,620,130);
  else if( (press2>=1.34f)&&(press2<1.62f) ) image(press_40,620,130);
  else if( (press2>=1.62f)&&(press2<1.9f) ) image(press_50,620,130);
  else if( (press2>=1.9f)&&(press2<2.18f) ) image(press_60,620,130);
  else if( (press2>=2.18f)&&(press2<2.46f) ) image(press_70,620,130);
  else if( (press2>=2.46f)&&(press2<2.74f) ) image(press_80,620,130);
  else if( (press2>=2.74f)&&(press2<3.02f) ) image(press_90,620,130);
  else if( (press2>=3.02f)&&(press2<3.3f) ) image(press_100,620,130);

  tint(255,255,255);

}



/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void drawBend(float bend){

  float bend2=0;

  bend2=bend/10;

  if( bend_act==1 ) image(bend_red,590,437);
  else if( bend_act==0 && bend2>1 ) image(bend_green,590,437);

  if( bend2<0.25f ) image(bend_0,615,490);
  else if( (bend2>=0.25f)&&(bend2<0.5f) ) image(bend_10,615,490);
  else if( (bend2>=0.5f)&&(bend2<0.75f) ) image(bend_20,615,490);
  else if( (bend2>=0.75f)&&(bend2<1) ) image(bend_30,615,490);
  else if( (bend2>=1)&&(bend2<1.25f) ) image(bend_40,615,490);
  else if( (bend2>=1.25f)&&(bend2<1.5f) ) image(bend_50,615,490);
  else if( (bend2>=1.5f)&&(bend2<1.75f) ) image(bend_60,615,490);
  else if( (bend2>=1.75f)&&(bend2<2) ) image(bend_70,615,490);
  else if( (bend2>=2)&&(bend2<2.25f) ) image(bend_80,615,490);
  else if( (bend2>=2.25f) ) image(bend_90,615,490);


  tint(255,255,255);

}



/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void drawLiquid()
{

  if( liq_act==0 ) image(gif_liquid,800,135);
  else if( liq_act==1 )
  {
    if( liq_ant==0 )
    {
      image(gif_liquid,800,135);
      image(liq_red,772,80);
      gif_liquid.play();
      liq_ant=1;
    }
    else
    {
      image(gif_liquid,800,135);
      image(liq_red,772,80);
    }
  }
}



/***********************************************************
 * 
 * drawHall - 
 *
 * 'hall_open' indicates the state of the door (true=open; false=closed)
 * 'hall_act'=1 means the interruption was activated
 *
 ***********************************************************/
public void drawHall()
{

  if( hall_open )
  {
    if( hall_act==0 )
    {
      //image(gif_hall,805,495);    
      //image(hall_red,772,437);
      gif_hall.jump(0);
      gif_hall2.jump(0);
      image(gif_hall,710,495);
    }
    else if( hall_act==1 )
    {
      image(gif_hall,710,495);
      image(hall_red,680,437);
      gif_hall.play();
      hall_act=0;
    }
  }
  else if( !hall_open )
  {
    if( hall_act==0 )
    {
      if( (gif_hall2.currentFrame()<=14) && (gif_hall2.currentFrame()>0) )
      {
        image(gif_hall2,710,495);
        image(hall_red,680,437);
      }
      else
      {
        gif_hall.jump(0);
        gif_hall2.jump(0);
        image(gif_hall,710,495);
      }
    }
    else if( hall_act==1 )
    {
      image(gif_hall2,710,495);
      image(hall_red,680,437);
      gif_hall2.play();
      hall_act=0;
    }
  }

}



/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void drawPIR()
{

  if( pir_act==0 ) 
  {
    image(gif_pir,805,312);
  }
  else if( pir_act==1 )
  {
    if( pir_ant==0 )
    {
      image(gif_pir,805,312);
      image(pir_red,772,258);
      gif_pir.play();
      pir_ant=1;
    }
    else
    {
      image(gif_pir,805,312);
      image(pir_red,772,258);
    }
  }

}



/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void drawRSSI()
{
  int value=(int) RSSI/10;

  if(value<5) value=5;

  switch( value )
  {
  case 5: 
    image(cob_4,907,15);
    break;
  case 6: 
    image(cob_3,907,15);
    break;
  case 7: 
    image(cob_3,907,15);
    break;
  case 8: 
    image(cob_2,907,15);
    break;
  case 9: 
    image(cob_2,907,15);
    break;
  case 10:
    image(cob_1,907,15);
    break;           
  }
}



/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void drawBattery()
{
  if( bat_signal <25 ) image(bat_1,955,13);
  else if( bat_signal>=25 && bat_signal<50 ) image(bat_2,955,13);
  else if( bat_signal>=50 && bat_signal<75 ) image(bat_3,955,13);
  else if( bat_signal>=75 ) image(bat_4,955,13);
}



/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void drawActuator()
{
  if( actuator_act==0 )
  {
    image(act_off,627,667);
    if( actuator_change==1 )
    {
      sendMessage_RED();
      actuator_change=0;
    }
  }
  else if( actuator_act==1 )
  {
    image(act_on,530,667);
    if( actuator_change==1 )
    {
      sendMessage_GREEN();
      actuator_change=0;
    }       
  }
}



/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void sendMessage_GREEN()
{
  for (int i = 0;i<16;i++)
  {
    myPort[r].write(mensaje_green[i]);
  } 
  delay(100); 
  for (int i = 0;i<16;i++)
  {
    myPort[r].write(mensaje_green[i]);
  } 

}



/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void sendMessage_RED()
{
  for (int i = 0;i<16;i++)
  {
    myPort[r].write(mensaje_red[i]);
  }
  delay(100);
  for (int i = 0;i<16;i++)
  {
    myPort[r].write(mensaje_red[i]);
  }
}



/***********************************************************
 * 
 * 
 *
 ***********************************************************/
public void mouseClicked()
{   
  switch( program_state )
  {
  case 0: // preparar para el tick y el boton continuar
    if( (mouseX<475 && mouseX>=440 && mouseY<340 && mouseY>=305) ){
      image(tick,440,300);
      image(but_con,250,650);
      next_program_state=2;
    }
    if( (mouseX<475 && mouseX>=440 && mouseY<440 && mouseY>=405) ){
      image(tick,440,400);
      image(but_con,250,650);
      next_program_state=4;
    }
    if( (mouseX<460 && mouseX>=250 && mouseY<705 && mouseY>=650) ){
      program_state=next_program_state;
    }
    break;
  case 3: // preparar para el tick y el boton continuar
    if( (mouseX<435 && mouseX>=405 && mouseY<385 && mouseY>=360) ){
      image(tick,405,348);
      image(but_con,250,650);
      port_picked=0;
      press_box=1;
    }

    if( (mouseX<435 && mouseX>=405 && mouseY<485 && mouseY>=460) ){
      image(tick,405,448);
      image(but_con,250,650); 
      port_picked=1;      
      press_box=2;       
    }

    if( (mouseX<435 && mouseX>=405 && mouseY<585 && mouseY>=560) ){
      image(tick,405,548);
      image(but_con,250,650); 
      port_picked=2;      
      press_box=3;       
    }

    if( (mouseX<460 && mouseX>=250 && mouseY<705 && mouseY>=650) ){
      continue_pressed=1;
    }
    break;
  case 5: 
    if( (mouseX<630 && mouseX>=560 && mouseY<735 && mouseY>=705) ){
      actuator_act=1;
      actuator_change=1;
    }
    if( (mouseX<727 && mouseX>=657 && mouseY<735 && mouseY>=705) ){
      actuator_act=0;
      actuator_change=1;
    }      
    break;   
  default: 
    break;         
  }   
}



  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#DFDFDF", "waspmote_pro_demo_v01" });
  }
}
