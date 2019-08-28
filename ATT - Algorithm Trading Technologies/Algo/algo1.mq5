#include "..\Core\ATTTrade.mqh"
#include "..\Core\ATTPrice.mqh"
#include "..\Core\ATTIndicator.mqh"

//+------------------------------------------------------------------+
//|                                                        algo1.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

// Define input parameters
input string assetCode = "WDOU19";
input double numberOfContracts = 1;
input int shortPeriod = 5;
input int longPeriod = 15;
input ENUM_TIMEFRAMES frame = 1; // Five minutes

// Initialize class instances
ATTTrade _ATTTrade;
ATTPrice _ATTPrice;
ATTIndicator _ATTIndicator;

bool bought = false;
bool sold = false;

// Main loop
void OnTick()
{
   // Calculate current prices
   double price = _ATTPrice.GetBid(assetCode);
   double stopLoss = _ATTPrice.GetStopLoss(price, 150);
   double takeProfit = _ATTPrice.GetTakeProfit(price, 50);

   // Calculate EMA for short and long period
   double shortAvg = _ATTIndicator.CalculateMovingAvarage(assetCode, frame, shortPeriod);
   double longAvg = _ATTIndicator.CalculateMovingAvarage(assetCode, frame, longPeriod);
   
   // Handle crossing up
   if (shortAvg > longAvg) {
   
      // Close current position
      if (sold == true) {
         _ATTTrade.Sell(assetCode, numberOfContracts, stopLoss, takeProfit);
         sold = false;
      }
      
      // Open long position
      if (bought == false) {
         _ATTTrade.Buy(assetCode, numberOfContracts, stopLoss, takeProfit);
         bought = true;
      }      
   } 
   
   // Handle crossing down
   if (shortAvg < longAvg) {
   
      // Close current position
      if (bought == true) {
         _ATTTrade.Sell(assetCode, numberOfContracts, stopLoss, takeProfit);
         bought = false;
      }

      // Open long position
      if (sold == false) {
         _ATTTrade.Sell(assetCode, numberOfContracts, stopLoss, takeProfit);
         sold = true;
      }
   }
   
   
   Comment("shortAvg: ", shortAvg, " longAvg: ", longAvg, " price: ", price);
   
   
}

// On start
int OnInit() 
{   
   bought = false;
   sold = false;

   return(INIT_SUCCEEDED);
}

// On stop
void OnDeinit(const int reason)
{
   
}
