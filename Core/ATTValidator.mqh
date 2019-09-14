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
      string ValidateAmount(double);
      string ValidatePointsToTrade(double);
      string ValidateStops(_TRAIL_STOP, double, double);
      string ValidateDailyLimits(double, double);      
   public:
      string ValidateParameters(double, double, double, double, _TRAIL_STOP, double, double);   

};

//+------------------------------------------------------------------+
//| Validate all input parameter                                     |
//+------------------------------------------------------------------+
string ATTValidator::ValidateParameters(double amount, double pointsToTrade, double stopLoss, double takeProfit, _TRAIL_STOP trailStop, double loss, double profit) {
   
   string value = "";
   
   // Validate the ammount
   value = ATTValidator::ValidateAmount(amount);

   // Validate the ammount
   value = ATTValidator::ValidatePointsToTrade(pointsToTrade);
  
   // Validate the stops
   value = ATTValidator::ValidateStops(trailStop, stopLoss, takeProfit);
   
   return value;
}

//+------------------------------------------------------------------+
//| Validate the amount                                              |
//+------------------------------------------------------------------+
string ATTValidator::ValidateAmount(double amount) {

   string value = "";
   
   if (amount > 1)
      value = "This service is free for small investments, to trade unlimited contracts consider support this project. Email dlancioni@gmail.com for details ";
      
   if (amount <= 0)
      value = "Must inform number of contracts (amount)";

   return value;
}

//+------------------------------------------------------------------+
//| Validate the amount                                              |
//+------------------------------------------------------------------+
string ATTValidator::ValidatePointsToTrade(double pointsToTrade) {

   string value = "";
      
   if (pointsToTrade < 0)
      value = "Points to trade cannot be negative";

   return value;
}

//+------------------------------------------------------------------+
//| Validate the stops                                               |
//+------------------------------------------------------------------+
string ATTValidator::ValidateStops(_TRAIL_STOP trailStop, double stopLoss, double takeProfit) {

   string value = "";
      
   if (stopLoss <= 0)
      value = "StopLoss is mandatory";
      
   if (takeProfit < 0)
      value = "TakeProfit cannot be negative";
      
   if (trailStop == _TRAIL_STOP::PROFIT || trailStop == _TRAIL_STOP::BOTH) {
      if (takeProfit > stopLoss) {
         value = "Trailing stop profit is selected, take profit value must be smaller than stop loss";
      }
   }

   return value;
}

//+------------------------------------------------------------------+
//| Validate the stops                                               |
//+------------------------------------------------------------------+
string ATTValidator::ValidateDailyLimits(double loss, double profit) {

   string value = "";
      
   if (loss <= 0)
      value = "Daily loss value is mandatory";
      
   if (profit <= 0)
      value = "Daily profit value is mandatory";

   return value;
}