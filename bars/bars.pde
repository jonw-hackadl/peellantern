/*
    This modification of the Matrix example program is modified to use a shift register 
    for row selection.  This register is connected to pins A0 and A5 of the arduino

    -Joanthan Wheare 2011
    
    based on an earlier program by Alex Leone, 2009-04-30
*/

#define  NUM_TLCS  4
#define  NUM_ROWS  8
#include "Tlc5940Mux.h"
#define data 14
#define clock 19

volatile uint8_t isShifting;
uint8_t shiftRow=0;
uint8_t trueRow=0;
uint8_t dummy_variable=0;

ISR(TIMER1_OVF_vect)
{
  if (!isShifting) {
    disable_XLAT_pulses();
    isShifting = 1;
    sei();
    shiftRow++;
    //__asm__("nop\n\t");
    //__asm__("nop\n\t");
    //__asm__("nop\n\t");
    //__asm__("nop\n\t");
    //__asm__("nop\n\t");
    if (shiftRow >= NUM_ROWS) 
    {
      shiftRow = 0;
      PORTC &= ~_BV(PORTC0);
    }
    __asm__("nop\n\t"); 
    PORTC |= _BV(PORTC5);
    //__asm__("nop\n\t");  
    PORTC |= _BV(PORTC0);
    PORTC &= ~_BV(PORTC5);
    //__asm__("nop\n\t");

    /*if (shiftRow >= NUM_ROWS) {
      shiftRow = 0;
    }
    if (shiftRow>4)
    {
      trueRow=shiftRow-5;
    }
    else
    {
      trueRow=shiftRow+3;
    }
    //DDRC = DDRC | B10000100;


      
    for (int i=0;i<8;i++)
    {
      PORTC |= _BV(PORTC5);

      
      if(i==trueRow)
      {
        PORTC &= ~_BV(PORTC0);
        //PORTC =B00100000;
      }
      else
      {
        PORTC |= _BV(PORTC0);
        //PORTC =B00100001;
      }  

      PORTC &= ~_BV(PORTC5);
      

      
    }*/
    TlcMux_shiftRow(shiftRow);

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

void setColour(int x, int y, int r, int g, int b) {
  int group = x/4;
  int col = x%4;
        TlcMux_set(y, (col*3)+(group*16)+1, b*16);
        TlcMux_set(y, (col*3)+(group*16)+2, g*16);
        TlcMux_set(y, (col*3)+(group*16)+3, r*16);
}

uint8_t color;
void loop()
{

/*  for (uint8_t group = 0; group < NUM_TLCS ; group++) 
  {
    for (uint8_t col = 0; col < 12; col++) 
    {
      TlcMux_clear();
  
      TlcMux_set(1, col+(group*16)+1, 4095);
      TlcMux_set(2, col+(group*16)+1, 4095);
      TlcMux_set(3, col+(group*16)+1, 4095);
      TlcMux_set(4, col+(group*16)+1, 4095);
      TlcMux_set(5, col+(group*16)+1, 4095);
      TlcMux_set(6, col+(group*16)+1, 4095);
      TlcMux_set(7, col+(group*16)+1, 4095);
      TlcMux_set(0, col+(group*16)+1, 4095);
      delay(100);
    }
  }
*/  


/*for (int y = 0; y < 8; y++) 
  {
    TlcMux_clear();
    for (int x = 0; x < 10 ; x++) 
    {
      //setColour((x+0)%16,(y+x)%8,255,0,0);
      //setColour((x+1)%16,(y+x)%8,0,255,0);
      //setColour((x+2)%16,(y+x)%8,0,0,255);
      //setColour((x)%16,(y+x)%8,255,255,255);
      //setColour((x+3)%16,(y+x)%8,0,0,255);
      //setColour((x+4)%16,(y+x)%8,255,0,0);
      //setColour((x+5)%16,(y+x)%8,0,255,0);
      //setColour((x+6)%16,(y+x)%8,0,0,255);
      //setColour((x+2)%16,(y+x)%8,255,255,255);
      //setColour((x+1)%16,(y+x)%8,255,255,255);
      //setColour((x+7)%16,(y+x)%8,0,0,255);
      setColour((x)%16,(y+x)%8,255,255,255);
      setColour((x+1)%16,(y+x)%8,255,255,255);
      setColour((x+2)%16,(y+x)%8,255,255,255);
      setColour((x+3)%16,(y+x)%8,255,255,255);
      setColour((x+4)%16,(y+x)%8,255,255,255);
      setColour((x+5)%16,(y+x)%8,255,255,255);
      setColour((x+6)%16,(y+x)%8,255,255,255);
      

    }
    delay(500);
  }
*/


for (int y=0; y <7; y++)
{
  TlcMux_clear();
  for (int x=0; x<16; x++)
  {
    setColour(x,y,255,255,255);
  }
  delay(500);
}

  TlcMux_clear();
  for (int x=0; x<16; x++)
  {
    setColour(x,7,255,255,255);
  }
  delay(500);


/*
for (uint8_t row = 0; row < NUM_ROWS; row++) 
  {
    TlcMux_clear();
    for (uint8_t group = 0; group < NUM_TLCS ; group++) 
    {
      for (uint8_t col = 0; col < 4; col++) 
      {
        TlcMux_set(row, (col*3)+(group*16)+3, 4095);
      }
    }
    delay(300);
  }
*/
/*  for (uint8_t row = 0; row < NUM_ROWS; row++) 
  {
    TlcMux_clear();
    for (uint8_t group = 0; group < NUM_TLCS ; group++) 
    {
      for (uint8_t col = 0; col < 4; col++) 
      {
        TlcMux_set(row, (col*3)+(group*16)+2, 4095);
      }
    }
    delay(200);
  }*/
  /*for (uint8_t group = 0; group < NUM_TLCS ; group++) 
  {
    for (uint8_t row = 0; row < NUM_ROWS; row++) 
    {
    
  
      for (uint8_t col = 0; col < 4; col++) 
      {
        TlcMux_clear();
        TlcMux_set(row, (col*3)+(group*16)+3
        , 4095);
        delay(200);
      }
      
    }
    
  }*/
}

