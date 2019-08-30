#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//|                                                     ATTTrade.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Provide methods do open and close deals                          |
//+------------------------------------------------------------------+
class ATTTrade {
   private:
       ulong TradeAtMarketPrice(const string bs, const string symbol, double qtt, double sl, double tp);
     
   public:
       int openPosition;
       ulong Buy(const string symbol, double qtt, double sl, double tp);
       ulong Sell(const string symbol, double qtt, double sl, double tp);
       void CloseAllPositions();
};

//+------------------------------------------------------------------+
//| Open or close position at market price                           |
//+------------------------------------------------------------------+
ulong ATTTrade::Buy(const string symbol=NULL, double qtt=0.0, double sl=0.0, double tp=0.0) {
   return ATTTrade::TradeAtMarketPrice("BUY", symbol, qtt, sl, tp);
}
ulong ATTTrade::Sell(const string symbol=NULL, double qtt=0.0, double sl=0.0, double tp=0.0) {
   return ATTTrade::TradeAtMarketPrice("SELL", symbol, qtt, sl, tp);
}

//+------------------------------------------------------------------+
//| Core logic to open and close positions at market price           |
//+------------------------------------------------------------------+
ulong ATTTrade::TradeAtMarketPrice(const string bs, const string symbol=NULL, double qtt=0.0, double sl=0.0, double tp=0.0) {

   // General Declaration
   CTrade trade;   
   bool result = false;
   ulong ticketId = 0;
   string comment = "Pending comment yet";
   
   // Trade when 1(buy) or 2(Sell), otherwise reteurn zero  
   if (bs=="BUY" || bs=="SELL") {
   
      // Buy or sell according
      if (bs=="BUY") {
         result = trade.Buy(qtt, symbol, 0.0, sl, tp, comment);
      } else {
         result = trade.Sell(qtt, symbol, 0.0, sl, tp, comment);
      }

      // Check trading action
      if (result) {
         if (trade.ResultRetcode()==TRADE_RETCODE_DONE) {   
            ticketId = trade.ResultDeal();
         }
      }
   }
   
   // Return ticket id or zeros
   return ticketId;
}

//+------------------------------------------------------------------+
//| Close all open positions at market price                         |
//+------------------------------------------------------------------+
void ATTTrade::CloseAllPositions() {

    // General Declaration
    CTrade trade;   
    ulong id = 0;
    ulong ticketId = 0;

    // Close open positions
     for (int i=PositionsTotal()-1; i>=0; i--) {
	      id = PositionGetTicket(i);
	      ticketId = trade.PositionClose(id);
     }   
}