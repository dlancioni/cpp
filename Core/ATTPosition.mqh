#include <Trade\Trade.mqh>
#include "ATTPrice.mqh"
#include "ATTSymbol.mqh"
#include "ATTOrder.mqh"
#include "ATTDef.mqh"

#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

class ATTPosition : public CPositionInfo {
    private:
        bool ModifyPosition(ulong orderId, double sl, double tp);    
        double pointsTrailLoss;
        double pointsTrailProfit;
    public:
        ATTPosition();
        ~ATTPosition();
        void TrailStop();
        void SetTrailStopLoss(double);
        void SetTrailStopProfit(double);           
        void CloseAllPositions();
};

//
// Constructors
//
ATTPosition::ATTPosition() {
}
ATTPosition::~ATTPosition() {
}

//
// Close all positions
//
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

//
// Modify stops in existing open position
//
bool ATTPosition::ModifyPosition(ulong id=0, double sl=0.0, double tp=0.0) {
    CTrade trade;
    bool status = false;    
    status = trade.PositionModify(id, sl, tp);
    return status;
}

void ATTPosition::SetTrailStopLoss(double value) {
    ATTPosition::pointsTrailLoss = value;
}

void ATTPosition::SetTrailStopProfit(double value) {
    ATTPosition::pointsTrailProfit = value; 
}

//
// Trail stops
//
void ATTPosition::TrailStop() {

    // General Declaration
    ulong ticketId = 0;
    double priceDeal = 0;
    double priceLoss = 0;
    double priceProfit = 0;
    ulong dealType = 0;
    double contracts = 0;
    double pointsLoss = 0;
      
    ATTSymbol _ATTSymbol;
    ATTPrice _ATTPrice;
    ATTOrder _ATTOrder;   
    
    // Check if need trail
    if (ATTPosition::pointsTrailLoss > 0) {   
        // Iterate over open positions
        for (int i=PositionsTotal()-1; i>=0; i--) {
            // Get current deal
            if (SelectByIndex(i)) {            

                // Make sure we are at same symbol as chart
                if (PositionGetSymbol(i) == Symbol()) {                
                    // Get deal info
                    ticketId = PositionGetInteger(POSITION_TICKET);
                    priceDeal = PositionGetDouble(POSITION_PRICE_OPEN);
                    priceLoss = PositionGetDouble(POSITION_SL);
                    priceProfit = PositionGetDouble(POSITION_TP);
                    dealType = PositionGetInteger(POSITION_TYPE);
                    contracts = PositionGetDouble(POSITION_VOLUME);
                    
                    
                    //_ATTPrice.GetPoints(_ATTSymbol.Ask, priceDeal);
                    
                    
                    // Recalculate the price
                    if (dealType == ENUM_POSITION_TYPE::POSITION_TYPE_BUY) {
                        priceLoss = _ATTPrice.Sum(priceLoss, 10 );
                    } else {               
                        priceLoss = _ATTPrice.Subtract(priceLoss, 10);
                    }
                    
                    // Channge position by adding new stop loss
                    ATTPosition::ModifyPosition(ticketId, priceLoss, priceProfit);
                }                
            }
        }
    }
}