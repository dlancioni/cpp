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
input string symbolCode = "EURUSD";
input double numberOfContracts = 3;
input double shortAvarage = 5;
input double longAvarage = 15;

// Initialize class instances
ATTTrade _ATTTrade;
ATTPrice _ATTPrice;
ATTIndicator _ATTIndicator;

// On start
int OnInit() 
{

   double price = _ATTPrice.GetBid(symbolCode);
   double stopLoss = _ATTPrice.GetStopLoss(price, 50);
   double takeProfit = _ATTPrice.GetTakeProfit(price, 50);
   //_ATTTrade.Buy(symbolCode, numberOfContracts, stopLoss, takeProfit);   
   
   return(INIT_SUCCEEDED);
}

// On stop
void OnDeinit(const int reason)
{

}

// Main loop
void OnTick()
{

   double avg1 = _ATTIndicator.CalculateMovingAvarage(_Symbol, _Period, 5, 1);
   double avg2 = _ATTIndicator.CalculateMovingAvarage(_Symbol, _Period, 5, 2);
   double avg3 = _ATTIndicator.CalculateMovingAvarage(_Symbol, _Period, 5, 3);
   double avg4 = _ATTIndicator.CalculateMovingAvarage(_Symbol, _Period, 5, 4);
   double avg5 = _ATTIndicator.CalculateMovingAvarage(_Symbol, _Period, 5, 5);
   
   
   Comment("Moving avarage: ", avg1, "---", avg2, "---", avg3, "---", avg4, "---", avg5);
   
   
   //Comment("Local time is ", TimeLocal());
   //Comment("Sell trade value: ", price, "within stop loss at ", stopLoss, " and stop gain ", stopGain);   
}
