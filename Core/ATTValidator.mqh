#include <Trade\Trade.mqh>
#include "ATTDef.mqh"

#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

class ATTValidator {
   private:
      string ValidateExpired();
      string ValidateAmount(double);
      string ValidatePointsToTrade(double);
      string ValidateStops(double);
      string ValidateDailyLimits(double, double);
      string ValidateAverages(double, double, double);
   public:
      string ValidateParameters(double, double, double, double, double, double, double, double, double, double);

};

string ATTValidator::ValidateParameters(double dailyLoss, 
                                        double dailyProfit,
                                        double contracts, 
                                        double pointsTrade, 
                                        double pointsLoss,
                                        double pointsProfit, 
                                        double trailingLoss, 
                                        double mavgShort,
                                        double mavgLong,
                                        double tradingLevel) {
   
   string value = "";

   // Validate the ammount
   if (value == "") value = ATTValidator::ValidateExpired();
   if (value == "") value = ValidateDailyLimits(dailyLoss, dailyProfit);   
   if (value == "") value = ATTValidator::ValidateAmount(contracts);
   if (value == "") value = ATTValidator::ValidatePointsToTrade(pointsTrade);
   if (value == "") value = ATTValidator::ValidateStops(trailingLoss);
   if (value == "") value = ATTValidator::ValidateAverages(mavgShort, mavgLong, tradingLevel);
   
   return value;
}

string ATTValidator::ValidateExpired() {

   string value = "";
   datetime currentDate = TimeLocal();
   datetime expireDate = TimeLocal();
   
   // Next expire date (each 3 months)
   expireDate = StringToTime("2020.06.31");
   
   Print("currentDate: ", currentDate);
   Print("expireDate: ", expireDate);
   
   if (currentDate > expireDate) {
      value = "This version of Atom has expired. Get latest version at github.com/dlancioni/atom";
   }   
   return value;
}

string ATTValidator::ValidateAmount(double amount) {

   string value = "";
      
   if (amount <= 0)
      value = "Must inform number of contracts (amount)";

   return value;
}

string ATTValidator::ValidatePointsToTrade(double pointsToTrade) {

   string value = "";
      
   if (pointsToTrade < 0)
      value = "Points to trade cannot be negative";

   return value;
}

string ATTValidator::ValidateStops(double trailingLoss) {

   string value = "";
      
   if (trailingLoss < 0) {
      value = "Points stop loss is mandatory";
   }

   return value;
}

string ATTValidator::ValidateDailyLimits(double loss, double profit) {

   string value = "";
      
   if (loss <= 0)
      value = "Daily loss value is mandatory";
      
   if (profit <= 0)
      value = "Daily profit value is mandatory";

   return value;
}

string ATTValidator::ValidateAverages(double shortAvg, double longAvg, double tradingLevel) {

   string value = "";
      
   if (shortAvg <= 0)
      value = "Short avarage is mandatory";
      
   if (longAvg <= 0)
      value = "Long avarage is mandatory";
      
   if (longAvg < 0)
      value = "Trading level cannot be negative";

   return value;
}
