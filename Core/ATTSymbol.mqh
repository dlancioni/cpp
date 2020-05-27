#include <Trade\Trade.mqh>

#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

class ATTSymbol {
   private:
   public:
      double Bid();
      double Ask();   
};

double ATTSymbol::Bid(void) {
   return SymbolInfoDouble(Symbol(),SYMBOL_BID);
}

double ATTSymbol::Ask(void) {
   return SymbolInfoDouble(Symbol(),SYMBOL_ASK);
}