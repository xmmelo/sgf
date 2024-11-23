Sets
       i   loads         / 1*5 /
       t   period        / 1*24 / ;

** Node demand in m^3/h
Table Pd(i,t) "Power demand (kW)"
       1      2       3     4      5      6      7      8      9      10     11     12    13    14    15    16    17     18     19     20     21     22     23     24
   1  144.0  145.8  147.6  140.4  133.2  117.0  100.8  91.8   82.8   75.6   69.6   63.6  57.6  55.8  54.0  61.2  68.4   80.4   92.4   104.4  115.2  126.0  136.8  147.6
   2  219.6  223.2  226.8  217.8  208.8  180.0  151.2  136.8  122.4  111.6  104.4  97.2  90.0  84.6  79.2  90.0  100.8  118.8  136.8  154.8  174.6  194.4  214.2  234.0
   3  219.6  223.2  226.8  217.8  208.8  180.0  151.2  136.8  122.4  111.6  104.4  97.2  90.0  84.6  79.2  90.0  100.8  118.8  136.8  154.8  174.6  194.4  214.2  234.0
   4  194.4  198.0  201.6  190.8  180.0  158.4  136.8  122.4  108.0  100.8  93.6   86.4  79.2  75.6  72.0  81.0  90.0   106.8  123.6  140.4  154.8  169.2  183.6  198.0
   5  64.8   64.8   64.8   61.2   57.6   50.4   43.2   37.8   32.4   28.8   27.6   26.4  25.2  25.2  25.2  27.0  28.8   32.4   36.0   39.6   47.7   55.8   63.9   72.0

Table DeltaP(i,t) "Demand Flexibility (%)"
       1     2     3     4     5     6     7     8     9     10    11    12    13    14    15    16    17    18    19    20    21    22    23    24
   1  0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.05  0.1   0.1   0.1   0.1   0.1
   2  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05
   3  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0     0     0     0     0     0     0     0
   4  0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25
   5  0.2   0.2   0.2   0.2   0.2   0.2   0.2   0.1   0.1   0.2   0.2   0.2   0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.1   0.1   0.1   0.1
;


Scalar
         Pmax    "kW"            / 850 /
         latePmax    "kW"         / 700 /

;

** cost in � KWH per hour
Parameter
 cost(t)
/ 1 0.016, 2 0.016, 3 0.018, 4 0.018, 5 0.021, 6 0.021, 7 0.022, 8 0.022,
  9 0.023, 10 0.023, 11 0.024, 12 0.024, 13 0.025, 14 0.025, 15 0.029, 16 0.029,
 17 0.031, 18 0.031, 19 0.035, 20 0.035, 21 0.0325, 22 0.0325, 23 0.03, 24 0.03/
;
* STEP 1
* Variables declaration (Variables; Positive variables; Binary variables)
Variables
z total costs
Pload(i,t) actual load
FlexUp(i,t)
FlexDown(i,t)
sumPload(t)
binFlex(i,t)
binaryFlex;


Positive variable Pload(i,t);
Positive variable FlexUp(i,t);
Positive Variable FlexDown(i,t);
Binary Variable binaryFlex;

* STEP 2
* Equations declaration
Equations
BalanceEquation(i)
calcLoad(i,t)
totalCosts
calcFlexUp(i,t)
calcFlexDown(i,t)
forceFlexUp(i,t)
forceFlexDown(i,t)
sumConsumption(t)
maxConsumption(t)
lateMaxConsumption(t);
* STEP 3
* Equations description

calcFlexUp(i,t)$((ord(t) < 19))  .. FlexUp(i,t) =l= DeltaP(i,t);
calcFlexDown(i,t)$((ord(t) < 19)) .. FlexDown(i,t) =l= DeltaP(i,t);


forceFlexDown(i,t)$((ord(t) >= 19)) .. FlexDown(i,t) =e= DeltaP(i,t);
forceFlexUp(i,t)$((ord(t) >= 19)) .. FlexUp(i,t) =e= 0;
 


sumConsumption(t) .. sumPload(t) =e= sum(i,Pload(i,t));

maxConsumption(t)$((ord(t) < 19)) .. sumPload(t) =l= Pmax;
lateMaxConsumption(t)$((ord(t) >= 19)) .. sumPload(t) =l= latePmax;


calcLoad(i,t) ..  Pload(i,t) =e= Pd(i,t)+Pd(i,t)*FlexUp(i,t)-Pd(i,t)*FlexDown(i,t);

BalanceEquation(i) .. sum(t,Pd(i,t)) =e= sum(t,Pload(i,t)) ;

totalCosts .. z =e= sum((i,t),Pload(i,t)*cost(t));




* STEP 4
* "Model" definition
Model Case_Data /all/ ;

* STEP 5
* "Solve" definition
solve Case_Data using rmip minimizing z  

* STEP 6
* "Display" results
display z.l, Pload.l, sumPload.l;
