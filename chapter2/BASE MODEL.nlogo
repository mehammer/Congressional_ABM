breed [resident residents]
breed [candidate candidates]


globals [
  starting-seed

  voters
  %voters
  cohort1d
  cohort2d
  cohort1r
  cohort2r
  mean_all1d
  mean_all2d
  prag1d
  prag2d
  prag1r
  prag2r

]

resident-own [
;most of these attributes aren't used now but are there for future reference.
  party
  voter ;whether or not the agent turnsout to vote
  poll ;voter preference during campaign rounds
  choice ;the actual choice on election day
  nominate_dim1
  nominate_dim2
  neighborhood ;congressional district
  c1_distance
  c2_distance
  c3_distance
  c4_distance
  alienation
]

candidate-own [
  party
  nominate_dim1
  nominate_dim2
  adaptation
]


to setup ;initial population and environment setup

  clear-all
  set starting-seed new-seed
  random-seed starting-seed

   ;random-seed 42
   ask patches [set pcolor white]
   create-candidate 2
   create-resident 62148
   population-attributes
   group
   nominate
   politicians

   reset-ticks
   end


to population-attributes

   ; set initial population characteristics

  ask resident
    [ set neighborhood 1
      set party "none"
      set voter 0
      set nominate_dim1 0
      set nominate_dim2 0
      set alienation random-float 1.0
  ]

end

  to group

    if scenario = "balance-ind"
    [ask n-of 20716 resident with [party = "none"] [set party "Democrat"]
    ask n-of 20716 resident with [party = "none"] [set party "Independents"]
    ask n-of 20716 resident with [party = "none"] [set party "Republican"]]

    if scenario = "dem-lean-ind"
    [ask n-of 31074 resident with [party = "none"] [set party "Democrat"]
    ask n-of 20716 resident with [party = "none"] [set party "Independents"]
    ask n-of 10358 resident with [party = "none"] [set party "Republican"]]

    if scenario = "rep-lean-ind"
    [ask n-of 10358 resident with [party = "none"] [set party "Democrat"]
    ask n-of 20716 resident with [party = "none"] [set party "Independents"]
    ask n-of 31074 resident with [party = "none"] [set party "Republican"]]

    if scenario = "dem-lean"
    [ask n-of 41018 resident with [party = "none"] [set party "Democrat"]
    ask n-of 21130 resident with [party = "none"] [set party "Republican"]]

    if scenario = "rep-lean"
    [ask n-of 21130 resident with [party = "none"] [set party "Democrat"]
    ask n-of 41018 resident with [party = "none"] [set party "Republican"]]



end

  to nominate

  ask resident with [party = "Democrat"]
  [set nominate_dim1 random-normal -0.377 0.2 set nominate_dim2 random-normal 0.0 0.33]

  ask resident with [party = "Independent"]
  [set nominate_dim1 random-normal 0.0 0.33 set nominate_dim2 random-normal 0.0 0.33]

  ask resident with [party = "Republican"]
  [set nominate_dim1 random-normal 0.377 0.2 set nominate_dim2 random-normal 0.0 0.33]


end


to politicians

  ask candidates 0 [ ;DEMOCRAT
    set party  "democrat"
    set shape "star"
    set label "democrat"
    set color red
    set size 5
    set xcor -5
    set ycor 5
    set nominate_dim1 random-normal -0.377 0.2
    set nominate_dim2 random-normal 0.0 0.33
    set adaptation strategy1
  ]

  ask candidates 1  [ ;REPUBLICAN
    set party "republican";
    set shape "star"
    set label "republican"
    set color blue
    set size 5
    set xcor 5
    set ycor 5
    set nominate_dim1 random-normal 0.377 0.2
    set nominate_dim2 random-normal 0.0 0.33
    set adaptation strategy2
  ]

end

to go

  if ticks < 12
    [ campaign ]

  if ticks = 12
    [ elect ]

  tick
end

to campaign

  set cohort1d mean [nominate_dim1] of resident with [party = "Democrat"]
  set cohort2d mean [nominate_dim2] of resident with [party = "Democrat"]
  set cohort1r mean [nominate_dim1] of resident with [party = "Republican"]
  set cohort2r mean [nominate_dim2] of resident with [party = "Republican"]

  set mean_all1d mean [nominate_dim1] of resident
  set mean_all2d mean [nominate_dim2] of resident

  ask resident with [neighborhood = 1] [
    set c1_distance sqrt(((nominate_dim1 - [nominate_dim1] of candidates 0) * (nominate_dim1 - [nominate_dim1] of candidates 0)) +
            ((nominate_dim2 - [nominate_dim2] of candidates 0) * (nominate_dim2 - [nominate_dim2] of candidates 0)))

    set c2_distance sqrt(((nominate_dim1 - [nominate_dim1] of candidates 1) * (nominate_dim1 - [nominate_dim1] of candidates 1)) +
            ((nominate_dim2 - [nominate_dim2] of candidates 1) * (nominate_dim2 - [nominate_dim2] of candidates 1)))

  ]

  ;count the vote

    ask resident with [neighborhood = 1]
  [ifelse c1_distance < c2_distance
    [set poll "C1"]
    [set poll "C2"]
  ]

  set prag1r count resident with [poll = "C1"]
  set prag1d count resident with [poll = "C2"]
  ;set prag1r mean [c1_distance] of resident ;current distance between voters and candidate 1
  ;set prag1d mean [c2_distance] of resident ;current distance between voters and candidate 2

  let messaging random-float 0.05

 ask candidates 0
        [if strategy1 = "Fundamentalist"
            [set nominate_dim1 cohort1d
             set nominate_dim2 cohort2d]
        if strategy1 = "Hunter"
              [set nominate_dim1 mean_all1d
               set nominate_dim2 mean_all2d]
        if strategy1 = "Pragmatist"
            [if prag1r < prag1d
              [ifelse nominate_dim1 < [nominate_dim1] of candidates 1
                [set nominate_dim1 nominate_dim1 + messaging]
                [set nominate_dim1 nominate_dim1 - messaging]

              ifelse nominate_dim2 < [nominate_dim2] of candidates 1
                [set nominate_dim2 nominate_dim2 + 0.01]
                [set nominate_dim2 nominate_dim2 - 0.01]
              ]
            ]
  ]

ask candidates 1
        [if strategy2 = "Fundamentalist"
            [set nominate_dim1 cohort1r
             set nominate_dim2 cohort2r ]
        if strategy2 = "Hunter"
              [set nominate_dim1 mean_all1d
               set nominate_dim2 mean_all2d]
        if strategy2 = "Pragmatist"
            [if prag1d < prag1r
              [ifelse nominate_dim1 < [nominate_dim1] of candidates 1
                [set nominate_dim1 nominate_dim1 + messaging]
                [set nominate_dim1 nominate_dim1 - messaging]

              ifelse nominate_dim2 < [nominate_dim2] of candidates 1
                [set nominate_dim2 nominate_dim2 + 0.01]
                [set nominate_dim2 nominate_dim2 - 0.01]
              ]
            ]
  ]
end


to elect

  ;determines which voters actually go to vote on election day
  ;provides the calculation for the actual vote

 ;distance calculation
  ask resident with [neighborhood = 1] [
    set c1_distance sqrt(((nominate_dim1 - [nominate_dim1] of candidates 0) * (nominate_dim1 - [nominate_dim1] of candidates 0)) +
            ((nominate_dim2 - [nominate_dim2] of candidates 0) * (nominate_dim2 - [nominate_dim2] of candidates 0)))

    set c2_distance sqrt(((nominate_dim1 - [nominate_dim1] of candidates 1) * (nominate_dim1 - [nominate_dim1] of candidates 1)) +
            ((nominate_dim2 - [nominate_dim2] of candidates 1) * (nominate_dim2 - [nominate_dim2] of candidates 1)))

  ]

 ;determine turnout
   ask resident with [neighborhood = 1 ]
    [if (c1_distance < alienation) or (c2_distance < alienation)
    [set voter 1]
  ]

;count the vote

    ask resident with [neighborhood = 1 and voter = 1]
  [ifelse c1_distance < c2_distance
    [set choice "C1"]
    [set choice "C2"]
  ]

 ;
end
@#$#@#$#@
GRAPHICS-WINDOW
14
574
66
627
-1
-1
1.26
1
10
1
1
1
0
1
1
1
-17
17
-17
17
1
1
1
Campaign/Election
30.0

BUTTON
27
10
93
43
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
103
10
166
43
go
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
27
52
177
70
Basic setup info
11
0.0
1

MONITOR
480
45
589
90
VA01
count resident with [neighborhood = 1]
17
1
11

MONITOR
479
107
589
152
Democrats
count resident with [party = \"Democrat\"]
17
1
11

MONITOR
480
168
589
213
Republicans
count resident with [party = \"Republican\"]
17
1
11

MONITOR
825
95
887
140
Rashid
count resident with [choice = \"C1\"]
17
1
11

MONITOR
828
152
887
197
Wittman
count resident with [choice = \"C2\"]
17
1
11

MONITOR
479
229
590
274
Independents
count resident with [party = \"Independents\"]
17
1
11

MONITOR
250
46
444
91
NIL
[nominate_dim1] of candidates 0
3
1
11

MONITOR
252
108
446
153
NIL
[nominate_dim2] of candidates 0
3
1
11

MONITOR
250
194
443
239
NIL
[nominate_dim1] of candidates 1
3
1
11

MONITOR
251
252
445
297
NIL
[nominate_dim2] of candidates 1
3
1
11

SLIDER
4
70
176
103
Democrat
Democrat
0
62148
10358.0
1
1
NIL
HORIZONTAL

SLIDER
3
120
175
153
Independent
Independent
0
62418
20716.0
1
1
NIL
HORIZONTAL

SLIDER
3
167
175
200
Republican
Republican
0
62418
31074.0
1
1
NIL
HORIZONTAL

MONITOR
679
475
742
520
NIL
cohort1d
5
1
11

MONITOR
681
414
741
459
NIL
cohort1r
5
1
11

MONITOR
634
282
812
327
NIL
mean [alienation] of resident
5
1
11

MONITOR
636
345
817
390
NIL
median [alienation] of resident
5
1
11

MONITOR
626
130
776
175
Democratic Voters
count resident with [party = \"Democrat\" and voter = 1]
5
1
11

MONITOR
627
182
776
227
Republican Voters
count resident with [party = \"Republican\" and voter = 1]
5
1
11

MONITOR
627
80
776
125
Independent Voters
count resident with [party = \"Independents\" and voter = 1]
5
1
11

PLOT
168
329
601
479
campaign_candidate1
NIL
NIL
0.0
20.0
-1.0
1.0
true
false
"" ""
PENS
"default" 0.1 0 -16777216 true "" "plot [nominate_dim1] of candidates 0"
"pen-1" 1.0 0 -7500403 true "" "plot [nominate_dim2] of candidates 0"

MONITOR
841
249
1009
294
NIL
count resident with [voter = 1]
17
1
11

MONITOR
769
417
826
462
NIL
prag1r
17
1
11

MONITOR
772
476
829
521
NIL
prag1d
17
1
11

PLOT
187
532
387
682
campaign_candidate2
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 0.1 0 -16777216 true "" "plot [nominate_dim1] of candidates 1"
"pen-1" 0.1 0 -7500403 true "" "plot [nominate_dim2] of candidates 1"

CHOOSER
11
226
149
271
strategy1
strategy1
"Fundamentalist" "Pragmatist" "Hunter"
2

CHOOSER
13
282
151
327
strategy2
strategy2
"Fundamentalist" "Pragmatist" "Hunter"
2

CHOOSER
9
349
147
394
scenario
scenario
"balance-ind" "dem-lean-ind" "rep-lean-ind" "dem-lean" "rep-lean"
4

@#$#@#$#@
## WHAT IS IT?


## HOW TO USE IT

Each pass through the Slumulate function represents a year in the time scale of this model.

The POPGROWTHRATE slider sets the monthly population growth rate.

The PERCENT-PRIME-LAND slider sets the percentage prime land in the city core.  The model is initialized to have a total number of rich households equal to number of prime land parcels. 

The PERCENT-INAPPROPRIATE-LAND slider sets the percentage inadequate land in the city core. The model is initialized to have a total number of poor households equal to number of inappropriate land parcels.

The DIFFUSION-RATE slider sets how fast the price diffusion occurs in the landscape. Higher the diffusion-rate, faster the price diffuses.

The PRICE-SENSITIVITY slider determines how early a turtle 'senses' approaching prices that it can not afford whereas STAYING-POWER slider determines how long a turtle can stay before it actively starts searching for a new location that it can afford. Together they provide shorter or longer 'window of period' to find partners to share the facility.

The INFORMAL-FORMAL-ECONOMY slider determines if informal sector is growing or formal sector is growing. if informal sector is growing, it increases income of low-income households proportionately more compared to high-income families. Conversely when formal economy is growing, it makes rich households rich faster than it increases income of poor households. When formal economy is growing, housing prices also rise more than when informal economy is growing. 

The GDP display the sum of the incomes of all households in the city. POPULATION display the total number of households in the city. 

LIG POPULATION, MIG POPULATION and HIG POPULATION  monitors display the number of lower-income households ,middle-income households and higher-income households respectively.

The LIG-DENSITY MIG-DENSITY, HIG-DENSITY and SLUM-DENSITY monitors dispay the density of housing for LIG, MIg,HIG and SLUMS respectively.

HOUSING DENSITY plots the housing density for slums and different income-groups over simulation time.

SLUM SIZE DISTRIBUTION plots the histogram of slum size.

NO. OF SLUMS, SLUM POPULATION, % SLUM POPULATION, SLUM DENSITY, % SLUM AREA is displayed for the overall city, central city and peripheral parts of the city.

The SLUMULATE! button runs the model.  A running plot is also displayed of the red-density, blue-density and green-density over time.

The SIMULATIONRUNTIME stops the simulation at the specified number of ticks in that box.


## THINGS TO NOTICE

How does different percent of prime land affects density of slums?

Does the formal growth rate give rise to higher densities of slums  (less affordable hosuing for poor)?

Does the poor always end up with slums?

## THINGS TO TRY

Try running different experiments with different values on sliders and see if poor remain in formal housing?

## EXTENDING THE MODEL

Extension with introduction of more active political and developer agents with an ability to bid for specific sites for eviction or retention.

## CREDITS AND REFERENCES

To refer to this model in academic publications, please use:  Patel, A. Crooks, A. Koizumi, A (2012). Slumulation Netlogo Model, George Mason Univerity, USA.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="14"/>
    <metric>count resident with [neighborhood = 1]</metric>
    <metric>[nominate_dim1] of candidates 0</metric>
    <metric>[nominate_dim2] of candidates 0</metric>
    <metric>[nominate_dim1] of candidates 1</metric>
    <metric>[nominate_dim2] of candidates 1</metric>
    <metric>count resident with [voter = 1]</metric>
    <metric>count resident with [choice = "C1"]</metric>
    <metric>count resident with [choice = "C2"]</metric>
    <metric>cohort1r</metric>
    <metric>cohort1d</metric>
    <metric>prag1r</metric>
    <metric>prag1d</metric>
    <metric>[strategy1] of candidates 0</metric>
    <metric>[strategy2] of candidates 1</metric>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;balance-ind&quot;"/>
      <value value="&quot;dem-lean-ind&quot;"/>
      <value value="&quot;rep-lean-ind&quot;"/>
      <value value="&quot;dem-lean&quot;"/>
      <value value="&quot;rep-lean&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="strategy1">
      <value value="&quot;Fundamentalist&quot;"/>
      <value value="&quot;Pragmatist&quot;"/>
      <value value="&quot;Hunter&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="strategy2">
      <value value="&quot;Fundamentalist&quot;"/>
      <value value="&quot;Pragmatist&quot;"/>
      <value value="&quot;Hunter&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-10run" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="14"/>
    <metric>count resident with [neighborhood = 1]</metric>
    <metric>[nominate_dim1] of candidates 0</metric>
    <metric>[nominate_dim2] of candidates 0</metric>
    <metric>[nominate_dim1] of candidates 1</metric>
    <metric>[nominate_dim2] of candidates 1</metric>
    <metric>count resident with [voter = 1]</metric>
    <metric>count resident with [choice = "C1"]</metric>
    <metric>count resident with [choice = "C2"]</metric>
    <metric>cohort1r</metric>
    <metric>cohort1d</metric>
    <metric>prag1r</metric>
    <metric>prag1d</metric>
    <metric>[strategy1] of candidates 0</metric>
    <metric>[strategy2] of candidates 1</metric>
    <metric>starting-seed</metric>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;balance-ind&quot;"/>
      <value value="&quot;dem-lean-ind&quot;"/>
      <value value="&quot;rep-lean-ind&quot;"/>
      <value value="&quot;dem-lean&quot;"/>
      <value value="&quot;rep-lean&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="strategy1">
      <value value="&quot;Fundamentalist&quot;"/>
      <value value="&quot;Pragmatist&quot;"/>
      <value value="&quot;Hunter&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="strategy2">
      <value value="&quot;Fundamentalist&quot;"/>
      <value value="&quot;Pragmatist&quot;"/>
      <value value="&quot;Hunter&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment-5irun" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="14"/>
    <metric>count resident with [neighborhood = 1]</metric>
    <metric>[nominate_dim1] of candidates 0</metric>
    <metric>[nominate_dim2] of candidates 0</metric>
    <metric>[nominate_dim1] of candidates 1</metric>
    <metric>[nominate_dim2] of candidates 1</metric>
    <metric>count resident with [voter = 1]</metric>
    <metric>count resident with [choice = "C1"]</metric>
    <metric>count resident with [choice = "C2"]</metric>
    <metric>cohort1r</metric>
    <metric>cohort1d</metric>
    <metric>prag1r</metric>
    <metric>prag1d</metric>
    <metric>[strategy1] of candidates 0</metric>
    <metric>[strategy2] of candidates 1</metric>
    <metric>starting-seed</metric>
    <enumeratedValueSet variable="scenario">
      <value value="&quot;balance-ind&quot;"/>
      <value value="&quot;dem-lean-ind&quot;"/>
      <value value="&quot;rep-lean-ind&quot;"/>
      <value value="&quot;dem-lean&quot;"/>
      <value value="&quot;rep-lean&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="strategy1">
      <value value="&quot;Fundamentalist&quot;"/>
      <value value="&quot;Pragmatist&quot;"/>
      <value value="&quot;Hunter&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="strategy2">
      <value value="&quot;Fundamentalist&quot;"/>
      <value value="&quot;Pragmatist&quot;"/>
      <value value="&quot;Hunter&quot;"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
