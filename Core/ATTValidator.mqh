#include <Trade\Trade.mqh>
#include "ATTDef.mqh"

//+------------------------------------------------------------------+
//|                                                     ATTPrice.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Pricing related methods (bid/ask, gain/loss, etc                 |
//+------------------------------------------------------------------+
class ATTValidator {
   private:
   public:
      string validateAmount(double);
      string validateStops(_TRAIL_STOP, double, double);  
};

string ATTValidator::validateAmount(double amount) {

   string value = "";
   
   if (amount > 1)
      value = "This service is free for small investments, to trade unlimited contracts consider support this project. Email dlancioni@gmail.com for details ";
      
   if (amount <= 0)
      value = "Must inform number of contracts (amount)";

   return value;
}

string ATTValidator::validateStops(_TRAIL_STOP trailStop, double stopLoss, double takeProfit) {
   return "";
}
