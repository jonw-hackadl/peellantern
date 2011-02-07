/*
    This modification of the Matrix example program is modified to use a shift register 
    for row selection.  This register is connected to pins A0 and A5 of the arduino

    -Joanthan Wheare 2011
    
    based on an earlier program by Alex Leone, 2009-04-30
*/

#define  NUM_TLCS  8
#define  NUM_ROWS  8
#include "Tlc5940Mux.h"
#define data 14
#define clock 19

volatile uint8_t isShifting;
uint8_t shiftRow=0;
uint8_t trueRow=0;

ISR(TIMER1_OVF_vect)
{
  if (!isShifting) {
    disable_XLAT_pulses();
    isShifting = 1;
    sei();
    
    if (shiftRow >= NUM_ROWS) {
      shiftRow = 0;
    }
    if (shiftRow>4)
    {
      trueRow=shiftRow-4;
    }
    else
    {
      trueRow=shiftRow+4;
    }
    //DDRC = DDRC | B10000100;

    for (int i=1;i<9;i++)
    {
     
      if(i==trueRow)
      {
        //PORTC &= ~_BV(PORTC0);
        PORTC =B00100000;
      }
      else
      {
        //PORTC |= _BV(PORTC0);
        PORTC =B00100001;
      }  
      PORTC &= ~_BV(PORTC5);
      PORTC |= _BV(PORTC5);
    }
    TlcMux_shiftRow(shiftRow++);
    /*PORTC = shiftRow++;*/
    //shiftRow++;
    enable_XLAT_pulses();
    isShifting = 0;
  }
}

void setup()
{
  DDRC |= _BV(PC0) | _BV(PC1) | _BV(PC5);
  TlcMux_init();
    
  pinMode(clock, OUTPUT); // make the clock pin an output
  pinMode(data , OUTPUT); // make the data pin an output
}

uint8_t color;
void loop()
{
  for (uint8_t col = 0; col < NUM_TLCS * 16; col++) 
  {
    TlcMux_clear();

    TlcMux_set(1, col, 4095);
    TlcMux_set(2, col, 4095);
    TlcMux_set(3, col, 4095);
    TlcMux_set(4, col, 4095);
    TlcMux_set(5, col, 4095);
    TlcMux_set(6, col, 4095);
    TlcMux_set(7, col, 4095);
    TlcMux_set(8, col, 4095);
    delay(100);
  }
  for (uint8_t row = 0; row < NUM_ROWS; row++) 
  {
    TlcMux_clear();
    for (uint8_t col = 0; col < NUM_TLCS * 16; col++) 
    {
      TlcMux_set(row, col, 4095);
    }
    delay(100);
  }
}
