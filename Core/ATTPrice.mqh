#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

class ATTPrice {
   private:
   public:
       double Sum(double value, double pts);
       double Subtract(double value, double pts);
       double GetPoints(double price1, double price2);
       double GetAverage(double price1, double price2);
};

double ATTPrice::Sum(double price=0.0, double points=0.0) {

   // General declaration   
   int digits = Digits();
   double tickSize = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   double point = SymbolInfoDouble(Symbol(), SYMBOL_POINT);

   // Price must end in 0 or 5 (b3 futures)   
   if (points > 0) {
      price = (double) NormalizeDouble((price + (points * point)), digits);
      if (tickSize == 0.5 || tickSize == 5.0) {
         while (MathMod(price, tickSize) > 0) {
            price = NormalizeDouble(price + point, digits);
         }
      }
   }
   
   return price;
}

double ATTPrice::Subtract(double price=0.0, double points=0.0) {

   // General declaration   
   int digits = Digits();
   double tickSize = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   double point = SymbolInfoDouble(Symbol(), SYMBOL_POINT);

   // Price must end in 0 or 5 (b3 futures)  
   if (points > 0) {
      price = (double) NormalizeDouble((price - (points * point)), digits);      
      if (tickSize == 0.5 || tickSize == 5.0) {
         while (MathMod(price, tickSize) > 0) {
            price = NormalizeDouble(price - point, digits);
         }
      }
   }
   
   return price;
}

double ATTPrice::GetPoints(double price1, double price2) {

   // General declaration   
   double value = 0.0;
   ulong digits = SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);

   // Normalize the final value according to the tick size   
   if (digits == 0) {
      value = MathAbs(price1 - price2) * Point();
   }
   
   if (digits == 5) {
      value = MathAbs(price1 - price2) / Point();
   }   
   
   value = NormalizeDouble(value, Digits());
   
   // Just return
   return value;
}

double ATTPrice::GetAverage(double price1, double price2) {
   double value = 0.0;
   value = (price1 + price2) / 2;  
   value = NormalizeDouble(value, Digits());   
   return value;
}
