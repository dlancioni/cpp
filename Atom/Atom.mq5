#include "..\Core\ATTOrder.mqh"
#include "..\Core\ATTPrice.mqh"
#include "..\Core\ATTIndicator.mqh"
#include "..\Core\ATTBalance.mqh"
#include "..\Core\ATTMath.mqh"
#include "..\Core\ATTDef.mqh"
#include "..\Core\ATTPosition.mqh"
#include "..\Core\ATTSymbol.mqh"
#include "..\Core\ATTValidator.mqh"

//+------------------------------------------------------------------------------------------------------+
//| atom.mq5                                                                                             |
//| Author David Lancioni 05/2020                                                                        |
//| https://www.mql5.com                                                                                 |
//| Crossover strategy                                                                                   |
//+------------------------------------------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

//
// Define input parameters (comments are labels)
//
input string RiskInfo = "----------";       // Risk Info
input double _dailyLoss = 0;                // Daily loss limit
input double _dailyProfit = 0;              // Daily profit limit
input string ChartInfo = "----------";      // Strategy setup for crossover
input ENUM_TIMEFRAMES _chartTime = 1;       // Chart time
input int _shortAvg = 0;                    // Short moving avarage
input int _longAvg = 0;                     // Long moving avarage
input double _diffAvg = 0;                  // Averages difference to open position
input double _limit = 0;                    // Difference between price on cross and current price
input string TradeInfo = "----------";      // Trade Info 
input double _contracts = 0;                // Number of Contracts
input double _pointsLoss = 0;               // Points stop loss (zero close on cross)
input double _pointsProfit = 0;             // Points take profit
input string Trailing = "----------";       // Trailing info 
input double _pointsTrailLoss = 0;          // Points to trigger trailing stop loss


//
// General Declaration
//
ATTOrder ATOrder;
ATTPrice ATPrice;
ATTSymbol ATSymbol;
ATTBalance ATBalance;
ATTPosition ATPosition;
ATTIndicator ATIndicator;  
ATTValidator ATValidator;
ATTMath ATMath;
string cross = "";
string lastCross = "";
double slb = 0;         // Stop loss buy
double sls = 0;         // Stop loss sell
double dailyPnL = 0;
//
// Init the values
//
int OnInit() {

   string msg = "";
   
   // Validate input parameters related to trade and abort program if something is wrong
   msg = ATValidator.ValidateParameters(_dailyLoss, 
                                        _dailyProfit,
                                        _contracts, 
                                        _pointsLoss,
                                        _pointsProfit, 
                                        _pointsTrailLoss, 
                                        _shortAvg,
                                        _longAvg,
                                        _diffAvg);
   if (msg != "") {
      Print(msg);
      Alert(msg);
      ExpertRemove();
   }
   
   // Load current PnL (very important if services go down)
   dailyPnL = ATBalance.GetDailyPnl();

   // Go ahead
   return(INIT_SUCCEEDED);
}


//
// Reload risk information after change on trading related (order, deal, etc)
//
void OnTrade() {
   dailyPnL = ATBalance.GetDailyPnl();
}

//
// Something went wrong, lets stop everything
//
void OnDeinit(const int reason) {
    Print(TimeCurrent(),": " ,__FUNCTION__," Reason code = ", reason);
}

//
// Main loop
//
void OnTick() {

   string symbol = Symbol();
   double bid = 0.0;         // Current bid price 
   double ask = 0.0;         // Current ask price
  
   // Get prices   
   bid = ATSymbol.Bid();
   ask = ATSymbol.Ask();

   // If no price, no deal (markets closed, or off-line)
   if (bid > 0 && ask > 0) {
      if (!ATBalance.IsResultOverLimits(dailyPnL, _dailyLoss, _dailyProfit)) {
         tradeCrossoverStrategy(symbol);
      }
   } else {
       Print("No price available");
   }
}

//
// Open position as indicators are attended
//
void tradeCrossoverStrategy(string symbol) {

    // General declaration
    const string UP = "UP";
    const string DN = "DN";
    
    bool buy = false;
    bool sell = false;   
    ulong orderId = 0;
    double shortAvg = 0;
    double longAvg = 0;
    double diffAvg = 0;
    double tpb = 0;
    double price = 0;
    double points = 0;
    double tps = 0;
    double ptsl = 0;
    double ptsp = 0;
      
    // Get avgs and calculate difference
    shortAvg = ATIndicator.CalculateMovingAvarage(symbol, _chartTime, _shortAvg);
    longAvg = ATIndicator.CalculateMovingAvarage(symbol, _chartTime, _longAvg);
    diffAvg = MathAbs(ATMath.Subtract(longAvg, shortAvg));
   
    // Ajust according to digits
    switch (Digits()) {
    case 3:
        diffAvg = diffAvg * 10;
        break;
    case 5:
        diffAvg = diffAvg * 100000;
        break;
    }
   
    Comment("Diff: ", diffAvg, " Cross: ", lastCross, " PnL: ", dailyPnL);

    // Calculate stop loss
    if (shortAvg > longAvg) {
       if (slb == 0.0) {
           slb = ATPrice.Subtract(shortAvg, 5);
           sls = 0;
       }
       if (diffAvg > _diffAvg) {
           cross = UP;
           buy = true;
           sell = false;
       }
       price = ATSymbol.Ask();
    }

    if (shortAvg < longAvg) {         
       if (sls == 0.0) {
           sls = ATPrice.Sum(shortAvg, 5);
           slb = 0;
       }
       if (diffAvg > _diffAvg) {
           cross = DN;
           buy = false;
           sell = true;
       }
       price = ATSymbol.Bid();
    }
   
    // Price exploded in single candle, no trade
    points = MathAbs(ATPrice.GetPoints(price, shortAvg));
    if (points > _limit) {
       buy = false;
       sell = false;      
    }   
    
    // Calculate loss if necessary
    if (_pointsLoss > 0) {
      slb = ATPrice.Subtract(price, _pointsLoss);
      sls = ATPrice.Sum(price, _pointsLoss);
    }
    
    // Calculate stop profit   
    tpb = ATPrice.Sum(price, _pointsProfit);
    tps = ATPrice.Subtract(price, _pointsProfit);   
    
    // Trade on cross only
    if (lastCross != cross) {
      lastCross = cross;
    } else {
      buy = false;
      sell = false;   
    }

    // True indicates a trade signal was identified
    if (buy || sell) {
      ATOrder.CloseAllOrders();
      ATPosition.CloseAllPositions();
    } else {
       buy = false;
      sell = false;
    }
    
    // Do not open more than one position at a time    
    if (PositionsTotal() == 0) {       
        if (buy) {        
            orderId = ATOrder.Buy(_ORDER_TYPE::MARKET, symbol, _contracts, price, slb, tpb);
        }        
        if (sell) {
            orderId = ATOrder.Sell(_ORDER_TYPE::MARKET, symbol, _contracts, price, sls, tps);
        }        
        ATPosition.SetTrailStopLoss(_pointsTrailLoss);        
    } else {
       ATPosition.TrailStop();
    }
   
}
