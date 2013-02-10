/*
    This modification of the Matrix example program is modified to use a shift register 
    for row selection.  This register is connected to pins A0 and A5 of the arduino

    -Joanthan Wheare 2011
    
    based on an earlier program by Alex Leone, 2009-04-30
*/

#define  NUM_TLCS  3
#define  NUM_ROWS  8
#include "Tlc5940Mux.h"

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
    
  pinMode(clock, OUTPUT); // make the clock pin an output
  pinMode(data , OUTPUT); // make the data pin an output

  TlcMux_init();

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

void rows(int colour, int frameDelay) {
  int x,y;
  for (x = 0; x < 16; x++) {
    TlcMux_clear();
    for (y = 0; y < 8; y++) {
      setPixel(x, y, 4095, colour);
    }
    delay(frameDelay);  
  }
}

void columns(int colour, int frameDelay) {
  int x,y;
  for (y = 0; y < 8; y++) {
    TlcMux_clear();
    for (x = 0; x < 16; x++) {
      setPixel(x, y, 4095, colour);
    }
    delay(frameDelay);  
  }  
}

void allOn(int colour) {
  int x,y;
  TlcMux_clear();
  for (x = 0; x < 16; x++) {
    for (y = 0; y < 8; y++) {
      setPixel(x, y, 4095, colour);
    }
  }
}

void loop()
{
  for(int colour=0;colour<3;colour++) {
    rows(colour,100);
    columns(colour,100);
    
    allOn(colour);
    delay(1000);  
  }
}
