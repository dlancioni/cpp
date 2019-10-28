# Welcome to Atom project

Atom is a trading bot (algorithm or computer program) coded in C++ that is able to trade different asset classes (Stocks, Forex, etc) based on statitics and technical analysis (indicators).

# How it works

It uses the financial libs and connectivity provided by MT5 (Meta Trader 5). MT5 is one of the most popular and easy to use trading platforms around the globe. Basically you connect to your broker account using MT5 client and the tool provides many functionalities like online charts in different timeframes, indicators to analise charts, interface to open and close positions, manage risk, etc. 

What differentiate MT5 from its competitors is the ability to create computer programs that inherits MT5's libraries and let us automate trading routines like track online chart/price or indicators (many possibilities here) and use C++ language to create algorithms that based available information let us interact with current market by open and close positions, trail stops based on specific logics and any other functionality avaiable in the platform.

# Input parameters<br>
Risk Info<br>
dailyLoss = 100;              // Daily loss limit per contract<br>
dailyProfit = 500;            // Daily profit limit per contract<br>

#TradeInfo<br>
chartTime = 5;                // Chart time<br>
contracts = 1;                // Number of Contracts<br>
pointsTrade = 100;            // Points after current price to open trade<br>
pointsLoss = 200;             // Points stop loss<br>
pointsProfit = 1000;          // Points stop profit<br>
tralingProfit = 200;          // Points to trigger dinamic stop profit<br>
tralingProfitStep = 50;       // Points to trail take profit<br>
trailingLoss = 50;            // Points to trail stop loss<br>

#CrossoverInfo<br>
period1 = 0;                  // Cross period over short and long <br>
period2 = 0;                  // Short period<br>
period3 = 0;                  // Long period<br>

#RSIInfo<br>
lineUpRSI = 70;               // Up line<br>
lineDnRSI = 30;               // Dn Line<br>
periodRSI = 14;               // Periods<br>

#Williams % Range<br>
lineUpWPR = 90;               // Up line<br>
lineDnWPR = 10;               // Dn Line<br>
periodWPR = 14;               // Periods<br>

#MFI specific parameters<br>
lineUpMFI = 80;               // Up line<br>
lineDnMFI = 20;               // Dn Line<br>
periodMFI = 14;               // Periods<br>

# Page under construction

