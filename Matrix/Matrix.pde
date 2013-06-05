/*
    This modification of the Matrix example program is modified to use a shift register 
    for row selection.  This register is connected to pins A0 and A5 of the arduino

    -Joanthan Wheare 2011
    
    based on an earlier program by Alex Leone, 2009-04-30
*/

#define  NUM_TLCS  3
#define  NUM_ROWS  8
#include "Tlc5940Mux.h"

#define  WIDTH     16
#define  HEIGHT    8

#define data A0
#define clock A3

volatile uint8_t isShifting;
uint8_t shiftRow=0;

ISR(TIMER1_OVF_vect)
{
  if (!isShifting) {
    disable_XLAT_pulses();
    isShifting = 1;
    sei();
    
    if (shiftRow >= NUM_ROWS) {
      shiftRow = 0;
    }

    for (int i=0;i<8;i++)
    {
     
      if(i==shiftRow)
      {
        digitalWrite(data,LOW);
      }
      else
      {
        digitalWrite(data,HIGH);
      }  
      // pulse clock
      digitalWrite(clock,HIGH);
      digitalWrite(clock,LOW);
      
      
    }
    TlcMux_shiftRow(shiftRow++);
    enable_XLAT_pulses();
    isShifting = 0;
  }
}

void setup()
{
  //Serial.begin(9600); 
  
  pinMode(clock, OUTPUT); // make the clock pin an output
  pinMode(data , OUTPUT); // make the data pin an output

  TlcMux_init();

  //TlcMux_clear();
}

int BLUE=0;
int GREEN=1;
int RED=2;

void setPixel(int column, int row, int intensity, int colour) {
  TlcMux_set(row, column*3+colour, intensity);
}

void setRGBPixel(int column, int row, int red, int green, int blue) {
  setPixel(column,row,blue,BLUE);
  setPixel(column,row,green,GREEN);
  setPixel(column,row,red,RED);
}

int getPixel(int column, int row, int colour) {
  return TlcMux_get(row, column*3+colour);
}

void scroll(int xDelta, int yDelta, int colour, int edgeIntensity) {
  int ix,iy,x,y;
  for(iy=0; iy<HEIGHT; iy++) {
    if(yDelta>=0) {
      y=iy;
    } else {
      y=HEIGHT-(iy+1);
    }
    for(ix=0; ix<WIDTH; ix++) {
      if(xDelta>=0) {
        x=ix;
      } else {
        x=WIDTH-(ix+1);
      }
      int sx = x+xDelta;
      int sy = y+yDelta;
      int si = edgeIntensity;
      if (sx>=0 && sx<WIDTH && sy>=0 && sy<HEIGHT) {
        si = getPixel(sx,sy,colour);
      }
      setPixel(x,y,si,colour);
    }
  }
}

void rows(int colour, int frameDelay) {
  int x,y;
  for (x = 0; x < WIDTH; x++) {
    TlcMux_clear();
    for (y = 0; y < HEIGHT; y++) {
      setPixel(x, y, 4095, colour);
    }
    delay(frameDelay);  
  }
}

void columns(int colour, int frameDelay) {
  int x,y;
  for (y = 0; y < HEIGHT; y++) {
    TlcMux_clear();
    for (x = 0; x < WIDTH; x++) {
      setPixel(x, y, 4095, colour);
    }
    delay(frameDelay);  
  }  
}

void allOn(int colour) {
  int x,y;
  TlcMux_clear();
  for (x = 0; x < WIDTH; x++) {
    for (y = 0; y < HEIGHT; y++) {
      setPixel(x, y, 4095, colour);
    }
  }
}

void swap(int *a, int *b) {
  int t;
  t = *a;
  *a = *b;
  *b = t;
}

void randomLines() {
  //int colour = random(3);
  static int rdx = 1;
  static int rdy = 0;
  static int ri = 4095;

  static int gdx = -1;
  static int gdy = 0;
  static int gi = 4095;
  
  static int bdx = 0;
  static int bdy = 1;
  static int bi = 4095;
  
  if(!random(4)) ri = random(2)?0:4095;
  if(!random(4)) gi = random(2)?0:4095;
  if(!random(4)) bi = random(2)?0:4095;
  
  if(!random(100)) { 
    rdx = -rdx;
    rdy = -rdy;
  }
  if(!random(100)) {
    swap(&rdx,&rdy);
  }

  if(!random(100)) { 
    gdx = -gdx;
    gdy = -gdy;
  }
  if(!random(100)) {
    swap(&gdx,&gdy);
  }
  
  if(!random(100)) { 
    bdx = -bdx;
    bdy = -bdy;
  }
  if(!random(100)) {
    swap(&bdx,&bdy);
  }

  scroll(rdx,rdy,RED,ri);
  scroll(gdx,gdy,GREEN,gi);
  scroll(bdx,bdy,BLUE,bi);
  
  //setPixel(8,4,colour,4095);
}

void loop()
{
  randomLines();
  //Serial.println(random(100)); 
  delay(50);
}
