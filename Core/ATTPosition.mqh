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
        double _pointsTrailLoss;
        double _priceTrailLoss;
        bool ModifyPosition(ulong orderId, double sl, double tp);    
    public:
        ATTPosition();
        ~ATTPosition();
        void TrailStop();
        void SetTrailStopLoss(double);
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
    ATTPosition::_priceTrailLoss = 0;
    ATTPosition::_pointsTrailLoss = value;
}

//
// Trail stops
//
void ATTPosition::TrailStop() {

    // General Declaration
    ulong ticketId = 0;
    double price = 0;
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
    if (_pointsTrailLoss > 0) {   
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
                    
                    // Recalculate the price
                    if (dealType == ENUM_POSITION_TYPE::POSITION_TYPE_BUY) {
                    
                        // Accumulate points on break
                        if (_priceTrailLoss == 0) {
                            _priceTrailLoss = _ATTPrice.Sum(priceDeal, _pointsTrailLoss);
                        }
                        
                        price = _ATTSymbol.Ask();
                        if (price > _priceTrailLoss) {
                            _priceTrailLoss = _ATTPrice.Sum(_priceTrailLoss, _pointsTrailLoss);
                            priceLoss = _ATTPrice.Sum(priceLoss, _pointsTrailLoss);
                            ATTPosition::ModifyPosition(ticketId, priceLoss, priceProfit);
                        }
                        
                    } else {               
                        // Accumulate points on break
                        if (_priceTrailLoss == 0) {
                            _priceTrailLoss = _ATTPrice.Subtract(priceDeal, _pointsTrailLoss);
                        }
                        
                        price = _ATTSymbol.Bid();
                        if (price < _priceTrailLoss) {
                            _priceTrailLoss = _ATTPrice.Subtract(_priceTrailLoss, _pointsTrailLoss);
                            priceLoss = _ATTPrice.Subtract(priceLoss, _pointsTrailLoss);
                            ATTPosition::ModifyPosition(ticketId, priceLoss, priceProfit);
                        }
                    }
                }                
            }
        }
    }
}