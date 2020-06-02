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
        double _checkpoints;
        double _points;
        double _priceCheckpoint;
        bool ModifyPosition(ulong orderId, double sl, double tp);    
    public:
        ATTPosition();
        ~ATTPosition();
        void TrailStop();
        void SetTrailStopLoss(double, double);
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

void ATTPosition::SetTrailStopLoss(double value, double points) {
    ATTPosition::_priceCheckpoint = 0;
    ATTPosition::_checkpoints = value;
    ATTPosition::_points = points;
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
    if (_checkpoints > 0) {   
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
                    
                        if (_priceCheckpoint == 0) {
                            _priceCheckpoint = _ATTPrice.Sum(priceDeal, _checkpoints);
                        }
                        
                        price = _ATTSymbol.Ask();
                        if (price > _priceCheckpoint) {
                            _priceCheckpoint = _ATTPrice.Sum(_priceCheckpoint, _checkpoints);
                            priceLoss = _ATTPrice.Sum(priceLoss, _points);
                            ATTPosition::ModifyPosition(ticketId, priceLoss, priceProfit);
                        }
                        
                    } else {               

                        if (_priceCheckpoint == 0) {
                            _priceCheckpoint = _ATTPrice.Subtract(priceDeal, _checkpoints);
                        }
                        
                        price = _ATTSymbol.Bid();
                        if (price < _priceCheckpoint) {
                            _priceCheckpoint = _ATTPrice.Subtract(_priceCheckpoint, _checkpoints);
                            priceLoss = _ATTPrice.Subtract(priceLoss, _points);
                            ATTPosition::ModifyPosition(ticketId, priceLoss, priceProfit);
                        }
                    }
                }                
            }
        }
    }
}