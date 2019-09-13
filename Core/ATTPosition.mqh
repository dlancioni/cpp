#include <Trade\Trade.mqh>
#include "ATTPrice.mqh"
#include "ATTSymbol.mqh"
#include "ATTOrder.mqh"
#include "ATTDef.mqh"
// https://www.mql5.com/pt/docs/standardlibrary/tradeclasses/ctrade
// https://www.youtube.com/watch?v=VL1_NGaAOaU

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
class ATTPosition : public CPositionInfo {
   private:
      bool ModifyPosition(ulong orderId, double sl, double tp);    
   public:
      ATTPosition();
      ~ATTPosition();
      ulong ticketTrailing;   
      void CloseAllPositions();
      void TrailingStop(double _contracts, double trailingPoints);
};

//+------------------------------------------------------------------+
//| Constructor/Destructor                                        |
//+------------------------------------------------------------------+
ATTPosition::ATTPosition() {
   ATTPosition::ticketTrailing = 0;
}
ATTPosition::~ATTPosition() {
   ATTPosition::ticketTrailing = 0;
}

//+------------------------------------------------------------------+
//| Delete all pending orders                                        |
//+------------------------------------------------------------------+
void ATTPosition::CloseAllPositions() {

    // General Declaration
    CTrade trade;   
    ulong id = 0;

    // Close open positions
     for (int i=PositionsTotal()-1; i>=0; i--) {
	      id = PositionGetTicket(i);
	      trade.PositionClose(id);
     }
}

//+------------------------------------------------------------------+
//| Modify existing order                                            |
//+------------------------------------------------------------------+
bool ATTPosition::ModifyPosition(ulong id=0, double sl=0.0, double tp=0.0) {
    CTrade trade;
    bool status = false;    
    status = trade.PositionModify(id, sl, tp);
    return status;
}

//+------------------------------------------------------------------+
//| Handle dinamic stops                                             |
//+------------------------------------------------------------------+
void ATTPosition::TrailingStop(double contracts = 0, double trailingPoints = 0) {

   // General Declaration
   ulong ticketId = 0;
   double priceDeal = 0.0;
   double stopLoss = 0.0;
   double takeProfit = 0.0;
   ulong dealType = 0.0;
   double pointsTrade = 0.0;
      
   ATTSymbol _ATTSymbol;
   ATTPrice _ATTPrice;
   ATTOrder _ATTOrder;
   
   // Close open positions
   for (int i=PositionsTotal()-1; i>=0; i--) {   

      // Get current deal
      if (SelectByIndex(i)) {
   
         // Make sure we are at same symbol as chart
         if (PositionGetSymbol(i) == Symbol()) {

            // Get deal info
            ticketId = PositionGetInteger(POSITION_TICKET);
            priceDeal = PositionGetDouble(POSITION_PRICE_OPEN);
            stopLoss = PositionGetDouble(POSITION_SL);
            takeProfit = PositionGetDouble(POSITION_TP);
            dealType = PositionGetInteger(POSITION_TYPE);

            // Set default checkpoint value
            pointsTrade = MathAbs(_ATTPrice.GetPoints(stopLoss, priceDeal));

            // Move the stops higher or lowers
            if (dealType == ENUM_POSITION_TYPE::POSITION_TYPE_BUY) {

               // Decrease stop loss
               if (stopLoss < priceDeal) {
                  if (_ATTSymbol.Bid() > _ATTPrice.Sum(stopLoss, (pointsTrade + trailingPoints))) {
                     ATTPosition::ModifyPosition(ticketId, _ATTPrice.Sum(stopLoss, trailingPoints), takeProfit);
                  }
               }
               
               // Increase profit after 50% profit
               if (_ATTSymbol.Bid() > _ATTPrice.Sum(takeProfit/2, trailingPoints)) {
                  if (ATTPosition::ticketTrailing == 0) {
                     ATTPosition::ticketTrailing = _ATTOrder.Sell(_ORDER_TYPE::LIMIT, Symbol(), contracts, _ATTSymbol.Bid(), 0, 0);
                  } else {
                     if (!_ATTOrder.AmmendOrder(ATTPosition::ticketTrailing, _ATTSymbol.Bid(), 0, 0)) {
                        ATTPosition::CloseAllPositions();
                     }
                  }   
               }

            } else {
                        
               // Decrease stop loss            
               if (stopLoss > priceDeal) {
                  if (_ATTSymbol.Ask() < _ATTPrice.Subtract(stopLoss, (pointsTrade + trailingPoints))) {
                     ATTPosition::ModifyPosition(ticketId, _ATTPrice.Subtract(stopLoss, trailingPoints), takeProfit);
                  }               
               }
               
               // Decrease profit after 50% profit
               if (_ATTSymbol.Ask() < _ATTPrice.Subtract(takeProfit/2, trailingPoints)) {
                  if (ATTPosition::ticketTrailing == 0) {
                     ATTPosition::ticketTrailing = _ATTOrder.Buy(_ORDER_TYPE::LIMIT, Symbol(), contracts, _ATTSymbol.Ask(), 0, 0);
                  } else {
                     if (!_ATTOrder.AmmendOrder(ATTPosition::ticketTrailing, _ATTSymbol.Ask(), 0, 0)) {
                        ATTPosition::CloseAllPositions();
                     }
                  }
               }
            }
         }
      }
   }
}      