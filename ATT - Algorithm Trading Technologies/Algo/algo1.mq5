#include "..\Core\ATTTrade.mqh"

//+------------------------------------------------------------------+
//|                                                        algo1.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

// Define input parameters
//input string symbolCode = "winv19";
input string symbolCode = "EURUSD";
input double numberOfContracts = 1;
input double shortAvarage = 5;
input double longAvarage = 15;

// Initialize class instances
ATTTrade atttrade;

// On start
int OnInit() 
{
   atttrade.Sell(symbolCode, numberOfContracts, 1.1200, 1.0800);
      
   return(INIT_SUCCEEDED);
}

// On stop
void OnDeinit(const int reason)
{

}

// Main loop
void OnTick()
{
   Comment("Local time is ", TimeLocal());
}
