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
class ATTPrice {
   private:
   public:
       double Sum(double value, double pts);
       double Subtract(double value, double pts);
};

//+------------------------------------------------------------------+
//| Calculate loss or profits                                        |
//+------------------------------------------------------------------+
double ATTPrice::Sum(double price=0.0, double pts=0.0) {

   // General declaration   
   double value = 0.0;
   double tickSize = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);;
   
   // Calculate value based on given points
   value = NormalizeDouble(price + (pts * Point()), _Digits);

   // Normalize the final value according to the tick size   
   if (tickSize > 0) {
      while (MathMod(value, tickSize) > 0) {
         value = NormalizeDouble(value + Point(), _Digits);
      }
   }
   
   // Just return
   return value;
}

double ATTPrice::Subtract(double price=0.0, double pts=0.0) {

   // General declaration   
   double value = 0.0;
   double tickSize = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);;
   
   // Calculate value based on given points
   value = NormalizeDouble(price - (pts * Point()), _Digits);

   // Normalize the final value according to the tick size   
   if (tickSize > 0) {
      while (MathMod(value, tickSize) > 0) {
         value = NormalizeDouble(value - Point(), _Digits);
      }
   }
   
   // Just return
   return value;
}