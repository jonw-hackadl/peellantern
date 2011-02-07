/*
    Analog 0-2 (PORTC) is hooked to a 3:8 line decoder (74LS138) which pull the
    Base of a PNP darlington (MPSA63) low through a 10k resistor for each row.
    +5V is connected to the Emitter of the PNP's, and all the anodes (+) of the
    leds for each row are connected to the Collector.
    
    Currently I'm trying to fix timing issues by putting some D-type positive
    edge triggered latches between PORTC and the 3:8 line decoder, clocked on
    the rising edge of XLAT, but this doesn't seem to help.  I'm bringing the
    circuit in to the logic analyzer this weekend to see exactly when the ISR
    runs and how long it takes to shift in the GS data.
    
    Alex Leone, 2009-04-30
*/

#define  NUM_TLCS  1
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
    for (uint8_t col = 0; col < 8; col++) {
    TlcMux_clear();

    TlcMux_set(col, 1, 4095);
    TlcMux_set(7-col, 2, 4095);
    delay(100);
  }
  TlcMux_clear();
  TlcMux_set(7, 4, 4095);
  TlcMux_set(0, 5, 4095);
  delay(100);
  TlcMux_clear();
  TlcMux_set(0, 8, 4095);
  TlcMux_set(7, 7, 4095);
  delay(100);  

  for (uint8_t col = 0; col < 8; col++) {
    TlcMux_clear();
    TlcMux_set(7-col, 10, 4095);
    TlcMux_set(col, 11, 4095);
    delay(100);
  }
  TlcMux_clear();
  TlcMux_set(7, 8, 4095);
  TlcMux_set(0, 7, 4095);
  delay(100);
  TlcMux_clear();
  TlcMux_set(7, 5, 4095);
  TlcMux_set(0, 4, 4095);
  delay(100);  

  
}
