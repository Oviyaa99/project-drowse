#include<SoftwareSerial.h>
SoftwareSerial bci(2,3); 
#define BAUDRATE 57600
#define LED 13

byte payloadData[32] = {0};
byte Attention[5]={0};
byte checksum=0;
byte generatedchecksum=0;
int  Plength,Temp;
int  Att_Avg=0,On_Flag=1,Off_Flag=0;
int  k=0;
signed int  j=0;


void setup() 
{
  Serial.begin(9600); 
  bci.begin(BAUDRATE);           // USB
  pinMode(8, OUTPUT);
  pinMode(9, OUTPUT);
  pinMode(10, OUTPUT);
  pinMode(11, OUTPUT);
  pinMode(6,OUTPUT);
}

byte ReadOneByte()           // One Byte Read Function
{
  int ByteRead;
  while(!bci.available());
  ByteRead = bci.read();
//  Serial.println(ByteRead);
  return ByteRead;
}

void loop()                     // Main Function
{
  digitalWrite(6,HIGH);
  while (1)
  {
    if(ReadOneByte() == 170)        // AA 1 st Sync data
    {
      if(ReadOneByte() == 170)      // AA 2 st Sync data
      {
//        Serial.println("IN");
        Plength = ReadOneByte();
        if(Plength == 32)   // Big Packet
        { 
//          Serial.println("IN1");
          generatedchecksum = 0;
          for(int i = 0; i < Plength; i++) 
          {  
            payloadData[i]     = ReadOneByte();      //Read payload into memory
            generatedchecksum  += payloadData[i] ;
          } 
          generatedchecksum = 255 - generatedchecksum;
          checksum  = ReadOneByte();
        
          if(checksum == generatedchecksum)        // Varify Checksum
          {             
            if (payloadData[28]==4)
            { 
              if (j<4)
               {
                 Attention [k] = payloadData[29];
                 Temp += Attention [k];
                 j++;
               }
               else
               {
                 Att_Avg = Temp/4;
                 Serial.print("avg att:");
                 Serial.println(Att_Avg);
                 if (Att_Avg<50)
                 {
                      digitalWrite(8, HIGH);
                     digitalWrite(9, LOW);
                     delay(5000);                   
                  
                 }
                 else
                 {
                   digitalWrite(8, LOW);
                     digitalWrite(9, HIGH);
                     delay(5000);
                 }
                 j=0;
                 Temp=0;
               }
               Serial.print("att:");
               Serial.println(Attention[k]);
            }
           } 
         }
       }
     }         
   } 
}
