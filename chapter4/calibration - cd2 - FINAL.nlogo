breed [resident residents]
breed [candidate candidates]


globals [

  starting-seed

  ;;POPULATION TOTALS
  voters
  %voters
  tot_vap
  white_vap
  minority_vap


  ;;GROUPS OF SUPPORTERS
  cohort1d
  cohort2d
  cohort1r
  cohort2r
  mean_all1d
  mean_all2d
  cohort_cand1
  cohort_cand2
  cohort01 ;first digit - candidate number  second digit - NOMINATE dimension
  cohort02
  cohort11
  cohort12
  cohort21
  cohort22
  cohort31
  cohort32
  cohort41
  cohort42
  cohort51
  cohort52

  ;voter NOMINATE ranges + weights
;  sd ;for the random-normal distributions of dim1
;  col ;weight for the influence of college education
;  w ;weight for the gender gap
;  race1 ;weight for the influence of race
;  dem_dim1 ;BASE
;  rep_dim1 ;BASE

  ;CAMPAIGN VARIABLES
  ;strategy
  ;messaging

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
  c5_distance
  c6_distance
  age
  alienation
  race
  gender
  education
  group
  voter_type ;one of the 16 groups to which the voter may belong


]

candidate-own [
  party
  nominate_dim1
  nominate_dim2
  adaptation
  incumbent
  polling
  dim1_diff
  dim2_diff
]


to setup ;initial population and environment setup

  clear-all
  set starting-seed new-seed
  random-seed starting-seed
   ;random-seed 42

   ask patches [set pcolor white]
   create-candidate 2
   create-resident 557735
   population-attributes
   groups
   nominate
   politicians

   set tot_vap 557735


   reset-ticks
   end


to population-attributes

   ; set initial population characteristics



  ask resident
    [ set neighborhood 1
      set party "none"
      set voter 0
      set nominate_dim1 0
      set nominate_dim2 random-normal 0.0 0.33
      set alienation random-float 1.0
      set race "none"
      set gender "none"
      set education "none"

  ]

end

to groups
;;SETS THE AGENT'S VOTER TYPE
;;THE n-of VALUE IS THE REAL ESTIMATED SUBPOPULATION NUMBER FOR THE DISTRICT FROM THE POP_DISTRIBUTION FILE
  ask n-of 46568 resident with [race = "none"][set race "white" set voter_type "WMHD"]
  ask n-of 19958 resident with [race = "none"][set race "white" set voter_type "WMCD"]
  ask n-of 42577 resident with [race = "none"][set race "white" set voter_type "WFHD"]
  ask n-of 23949 resident with [race = "none"][set race "white" set voter_type "WFCD"]
  ask n-of 58607 resident with [race = "none"][set race "minority" set voter_type "MMHD"]
  ask n-of 25117 resident with [race = "none"][set race "minority" set voter_type "MMCD"]
  ask n-of 53584 resident with [race = "none"][set race "minority" set voter_type "MFHD"]
  ask n-of 30141 resident with [race = "none"][set race "minority" set voter_type "MFCD"]
  ask n-of 82788 resident with [race = "none"][set race "white" set voter_type "WMHR"]
  ask n-of 35481 resident with [race = "none"][set race "white" set voter_type "WMCR"]
  ask n-of 75692 resident with [race = "none"][set race "white" set voter_type "WFHR"]
  ask n-of 42577 resident with [race = "none"][set race "white" set voter_type "WFCR"]
  ask n-of 6585 resident with [race = "none"][set race "minority" set voter_type "MMHR"]
  ask n-of 2822 resident with [race = "none"][set race "minority" set voter_type "MMCR"]
  ask n-of 6623 resident with [race = "none"][set race "minority" set voter_type "MMHR"]
  ask n-of 3725 resident with [race = "none"][set race "minority" set voter_type "MFHR"]

end

to nominate

ask resident [

    if voter_type = "WMHD" [set nominate_dim1 dem_dim1];
    if voter_type = "WMCD" [set nominate_dim1 dem_dim1 + col]
    if voter_type = "WFHD" [set nominate_dim1 dem_dim1 + w]
    if voter_type = "WFCD" [set nominate_dim1 dem_dim1 + w + col]
    if voter_type = "MMHD" [set nominate_dim1 dem_dim1 + race1]
    if voter_type = "MMCD" [set nominate_dim1 dem_dim1 + race1 + col]
    if voter_type = "MFHD" [set nominate_dim1 dem_dim1 + race1 + w]
    if voter_type = "MFCD" [set nominate_dim1 dem_dim1 + race1 + w + col]
    if voter_type = "WMHR" [set nominate_dim1 rep_dim1]
    if voter_type = "WMCR" [set nominate_dim1 rep_dim1 + col]
    if voter_type = "WFHR" [set nominate_dim1 rep_dim1 + w]
    if voter_type = "WFCR" [set nominate_dim1 rep_dim1 + w + col]
    if voter_type = "MMHR" [set nominate_dim1 rep_dim1 + race1]
    if voter_type = "MMCR" [set nominate_dim1 rep_dim1 + race1 + col]
    if voter_type = "MFHR" [set nominate_dim1 rep_dim1 + race1]
    if voter_type = "MFCR" [set nominate_dim1 rep_dim1 + race1 + col]

  ]

end


to politicians

  ask candidates 0 [ ;Elaine Luria
    set party  "democrat"
    set shape "star"
    set label "democrat"
    set color red
    set size 5
    set xcor -5
    set ycor 5
    set nominate_dim1 -0.206
    set nominate_dim2 0.426
    set adaptation strategy1
  ]

  ask candidates 1  [ ;Scott Taylor
    set party "republican";
    set shape "star"
    set label "republican"
    set color blue
    set size 5
    set xcor 5
    set ycor 5
    set nominate_dim1 0.067
    set nominate_dim2 0.069
    set adaptation strategy2
  ]

end

to go

  if ticks < 4
    [ campaign ]

  if ticks >= 4
    [ elect ]

  tick
end

to campaign


  ;messaging creates the distance that candidates are willing to move
  ;let messaging random-float 0.1

  ;voters assess their distance
  ask resident with [neighborhood = 1] [
    set c1_distance sqrt(((nominate_dim1 - [nominate_dim1] of candidates 0) * (nominate_dim1 - [nominate_dim1] of candidates 0)) +
            ((nominate_dim2 - [nominate_dim2] of candidates 0) * (nominate_dim2 - [nominate_dim2] of candidates 0)))

    set c2_distance sqrt(((nominate_dim1 - [nominate_dim1] of candidates 1) * (nominate_dim1 - [nominate_dim1] of candidates 1)) +
            ((nominate_dim2 - [nominate_dim2] of candidates 1) * (nominate_dim2 - [nominate_dim2] of candidates 1)))

  ]

  ;count the vote / take the poll numbers

  ask resident with [neighborhood = 1]
  [ifelse c1_distance < c2_distance
    [set poll "C1"]
    [set poll "C2"]
  ]


  ;this section creates the voter blocs that candidates poll/care about
  ;MEAN OF ALL VOTERS -- FOR HUNTERS
  set mean_all1d mean [nominate_dim1] of resident
  set mean_all2d mean [nominate_dim2] of resident

  ;COUNT OF VOTER SUPPORT DURING CAMPAIGN STEPS
  set cohort_cand1 count resident with [poll = "C1"]
  set cohort_cand2 count resident with [poll = "C2"]

  ;NOMINATE SCORES OF VOTER GROUPS
  ifelse count resident with [poll = "C1"] > 0
    [set cohort01 mean [nominate_dim1] of resident with [poll = "C1"]]
    [set cohort01 "null"]
  ifelse count resident with [poll = "C1"] > 0
    [set cohort02 mean [nominate_dim2] of resident with [poll = "C1"]]
    [set cohort02 "null"]
  ifelse count resident with [poll = "C2"] > 0
  [set cohort11 mean [nominate_dim1] of resident with [poll = "C2"]]
    [set cohort11 "null"]
  ifelse count resident with [poll = "C2"] > 0
  [set cohort12 mean [nominate_dim2] of resident with [poll = "C2"]]
    [set cohort12 "null"]

 ;Candidate 0 adaptation
 ask candidates 0 [

  let old-dim1 nominate_dim1
  let old-dim2 nominate_dim2

        if adaptation = "Partisan"
          [if cohort_cand1 > 0 ;if there are any supporters, adjust to their mean
            [set nominate_dim1 cohort01
             set nominate_dim2 cohort02
             set dim1_diff (nominate_dim1 - old-dim1)
             set dim2_diff (nominate_dim2 - old-dim2)]
    ]

        if adaptation = "Hunter"
              [set nominate_dim1 mean_all1d - 0.01
              set nominate_dim2 mean_all2d - 0.01
              set dim1_diff (nominate_dim1 - old-dim1)
              set dim2_diff (nominate_dim2 - old-dim2)]

        if adaptation = "Pragmatist"
            [if cohort_cand1 > 0
             [if cohort_cand1 < cohort_cand2
              [ifelse cohort01 < [nominate_dim1] of candidates 1
                [set nominate_dim1 nominate_dim1 + messaging]
                [set nominate_dim1 nominate_dim1 - messaging]

              ifelse cohort02 < [nominate_dim2] of candidates 1
                [set nominate_dim2 nominate_dim2 + 0.01]
                [set nominate_dim2 nominate_dim2 - 0.01]
              ]

              set dim1_diff (nominate_dim1 - old-dim1)
              set dim2_diff (nominate_dim2 - old-dim2)
            ]
    ]
         if strategy1 = "Sticker"
              [set nominate_dim1 [nominate_dim1] of candidates 0
              set nominate_dim2 [nominate_dim2] of candidates 0]
      ]


ask candidates 1 [

      let old-dim1 nominate_dim1
      let old-dim2 nominate_dim2

        if adaptation = "Partisan"
          [if cohort_cand2 > 0
            [set nominate_dim1 cohort11
             set nominate_dim2 cohort12
             set dim1_diff (nominate_dim1 - old-dim1)
             set dim2_diff (nominate_dim2 - old-dim2)]
    ]

        if adaptation = "Hunter"
              [set nominate_dim1 mean_all1d - 0.01
              set nominate_dim2 mean_all2d - 0.01
              set dim1_diff (nominate_dim1 - old-dim1)
              set dim2_diff (nominate_dim2 - old-dim2)]

        if adaptation = "Pragmatist"
            [if cohort_cand2 > 0
             [if cohort_cand2 < cohort_cand1
              [ifelse cohort11 < [nominate_dim1] of candidates 0
                [set nominate_dim1 nominate_dim1 + messaging]
                [set nominate_dim1 nominate_dim1 - messaging]

              ifelse cohort12 < [nominate_dim2] of candidates 0
                [set nominate_dim2 nominate_dim2 + 0.01]
                [set nominate_dim2 nominate_dim2 - 0.01]
              ]

              set dim1_diff (nominate_dim1 - old-dim1)
              set dim2_diff (nominate_dim2 - old-dim2)
            ]
    ]
         if strategy1 = "Sticker"
              [set nominate_dim1 [nominate_dim1] of candidates 1
              set nominate_dim2 [nominate_dim2] of candidates 1]
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
191
10
300
55
VA01
count resident with [neighborhood = 1]
17
1
11

MONITOR
853
84
915
129
Rashid
count resident with [choice = \"C1\"]
17
1
11

MONITOR
856
141
915
186
Wittman
count resident with [choice = \"C2\"]
17
1
11

MONITOR
213
100
407
145
NIL
[nominate_dim1] of candidates 0
3
1
11

MONITOR
215
162
409
207
NIL
[nominate_dim2] of candidates 0
3
1
11

MONITOR
213
248
406
293
NIL
[nominate_dim1] of candidates 1
3
1
11

MONITOR
214
306
408
351
NIL
[nominate_dim2] of candidates 1
3
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

PLOT
229
367
389
487
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
630
223
798
268
NIL
count resident with [voter = 1]
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
32
98
170
143
strategy1
strategy1
"Partisan" "Pragmatist" "Hunter" "Sticker"
0

CHOOSER
34
154
172
199
strategy2
strategy2
"Partisan" "Pragmatist" "Hunter" "Sticker"
1

MONITOR
322
10
415
55
NIL
tot_vap
17
1
11

MONITOR
598
160
807
205
NIL
count resident with [race = \"none\"]
17
1
11

MONITOR
611
40
822
85
NIL
count resident with [race = \"white\"]
17
1
11

MONITOR
606
100
831
145
NIL
count resident with [race = \"minority\"]
17
1
11

MONITOR
842
23
1044
68
NIL
mean [nominate_dim1] of resident
17
1
11

MONITOR
862
207
964
252
rashid - minority
count resident with [choice = \"C1\" and race = \"minority\"]
17
1
11

MONITOR
859
263
963
308
wittman - minority
count resident with [choice = \"C2\" and race = \"minority\"]
17
1
11

MONITOR
857
318
963
363
rashid - white
count resident with [choice = \"C1\" and race = \"white\"]
17
1
11

MONITOR
859
372
957
417
wittman - white
count resident with [choice = \"C2\" and race = \"white\"]
17
1
11

TEXTBOX
218
65
368
83
CANDIDATE MONITORS
11
0.0
1

MONITOR
431
39
593
84
NIL
[dim1_diff] of candidates 0
17
1
11

MONITOR
431
102
593
147
NIL
[dim1_diff] of candidates 1
17
1
11

MONITOR
447
233
571
278
NIL
cohort_cand1
17
1
11

MONITOR
448
289
572
334
NIL
cohort_cand2
17
1
11

MONITOR
462
419
762
464
NIL
mean [nominate_dim1] of resident with [poll = \"C2\"]
17
1
11

MONITOR
929
89
1298
134
NIL
count resident with [choice = \"C1\" and voter_type = \"WMCD\"]
17
1
11

MONITOR
930
140
1288
185
NIL
count resident with [choice = \"C2\" and voter_type = \"WMCD\"]
17
1
11

MONITOR
1047
231
1383
276
NIL
count resident with [voter = 1 and voter_type = \"WMCD\"]
17
1
11

MONITOR
1046
307
1420
352
NIL
median [nominate_dim1] of resident with [voter_type = \"WMCD\"]
17
1
11

MONITOR
1055
366
1311
411
NIL
count resident with [voter_type = \"WMCD\"]
17
1
11

MONITOR
1095
433
1351
478
NIL
count resident with [voter_type = \"WMHD\"]
17
1
11

SLIDER
23
213
195
246
dem_dim1
dem_dim1
-1.0
1.0
-0.363
0.001
1
NIL
HORIZONTAL

SLIDER
21
256
193
289
sd
sd
0
1.0
0.2
0.01
1
NIL
HORIZONTAL

SLIDER
16
301
188
334
col
col
-1.0
1.0
-0.1
0.1
1
NIL
HORIZONTAL

SLIDER
15
339
187
372
w
w
-1.0
1.0
-0.05
0.1
1
NIL
HORIZONTAL

SLIDER
22
415
194
448
rep_dim1
rep_dim1
0
1.0
0.397
0.001
1
NIL
HORIZONTAL

SLIDER
22
377
194
410
race1
race1
-1.0
1.0
-0.1
0.1
1
NIL
HORIZONTAL

SLIDER
29
459
201
492
messaging
messaging
0
1.0
0.05
0.01
1
NIL
HORIZONTAL

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
  <experiment name="va02 - cand sweep simple centers" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="5"/>
    <metric>count resident with [voter = 1]</metric>
    <metric>count resident with [choice = "C1"]</metric>
    <metric>count resident with [choice = "C2"]</metric>
    <metric>[dim1_diff] of candidates 0</metric>
    <metric>[dim2_diff] of candidates 0</metric>
    <metric>[dim1_diff] of candidates 1</metric>
    <metric>[dim2_diff] of candidates 1</metric>
    <metric>cohort_cand1</metric>
    <metric>cohort_cand2</metric>
    <metric>cohort01</metric>
    <metric>cohort02</metric>
    <metric>cohort11</metric>
    <metric>cohort12</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WMHD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WMHD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WMCD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WMCD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WFHD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WFHD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WFCD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WFCD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MMHD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MMHD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MMCD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MMCD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MFHD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MFHD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MFCD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MFCD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WMHR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WMHR"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WMCR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WMCR"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WFHR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WFHR"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WFCR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WFCR"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MMHR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MMHR"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MMCR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MMCR"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MFHR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MFHR"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MFCR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MFCR"]</metric>
    <metric>median [c1_distance] of resident with [voter = 1]</metric>
    <metric>median [c1_distance] of resident with [voter = 0]</metric>
    <metric>median [c2_distance] of resident with [voter = 1]</metric>
    <metric>median [c2_distance] of resident with [voter = 0]</metric>
    <enumeratedValueSet variable="strategy1">
      <value value="&quot;Partisan&quot;"/>
      <value value="&quot;Pragmatist&quot;"/>
      <value value="&quot;Sticker&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="strategy2">
      <value value="&quot;Partisan&quot;"/>
      <value value="&quot;Pragmatist&quot;"/>
      <value value="&quot;Sticker&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="messaging">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sd">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="col">
      <value value="-0.1"/>
      <value value="-0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="w">
      <value value="-0.05"/>
      <value value="-0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="race1">
      <value value="-0.1"/>
      <value value="-0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dem_dim1">
      <value value="-0.363"/>
      <value value="-0.263"/>
      <value value="-0.463"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rep_dim1">
      <value value="0.397"/>
      <value value="0.297"/>
      <value value="0.497"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="va02 - 5runs" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="5"/>
    <metric>count resident with [voter = 1]</metric>
    <metric>count resident with [choice = "C1"]</metric>
    <metric>count resident with [choice = "C2"]</metric>
    <metric>[dim1_diff] of candidates 0</metric>
    <metric>[dim2_diff] of candidates 0</metric>
    <metric>[dim1_diff] of candidates 1</metric>
    <metric>[dim2_diff] of candidates 1</metric>
    <metric>cohort_cand1</metric>
    <metric>cohort_cand2</metric>
    <metric>cohort01</metric>
    <metric>cohort02</metric>
    <metric>cohort11</metric>
    <metric>cohort12</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WMHD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WMHD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WMCD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WMCD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WFHD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WFHD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WFCD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WFCD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MMHD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MMHD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MMCD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MMCD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MFHD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MFHD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MFCD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MFCD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WMHR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WMHR"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WMCR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WMCR"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WFHR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WFHR"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WFCR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WFCR"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MMHR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MMHR"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MMCR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MMCR"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MFHR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MFHR"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MFCR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MFCR"]</metric>
    <metric>median [c1_distance] of resident with [voter = 1]</metric>
    <metric>median [c1_distance] of resident with [voter = 0]</metric>
    <metric>median [c2_distance] of resident with [voter = 1]</metric>
    <metric>median [c2_distance] of resident with [voter = 0]</metric>
    <metric>median [c1_distance] of resident with [choice = "C1"]</metric>
    <metric>median [c2_distance] of resident with [choice = "C2"]</metric>
    <metric>starting-seed</metric>
    <enumeratedValueSet variable="strategy1">
      <value value="&quot;Partisan&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="strategy2">
      <value value="&quot;Pragmatist&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="messaging">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sd">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="col">
      <value value="-0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="w">
      <value value="-0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="race1">
      <value value="-0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dem_dim1">
      <value value="-0.363"/>
      <value value="-0.263"/>
      <value value="-0.463"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rep_dim1">
      <value value="0.397"/>
      <value value="0.297"/>
      <value value="0.497"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="va02 - 10runs" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="5"/>
    <metric>count resident with [voter = 1]</metric>
    <metric>count resident with [choice = "C1"]</metric>
    <metric>count resident with [choice = "C2"]</metric>
    <metric>[dim1_diff] of candidates 0</metric>
    <metric>[dim2_diff] of candidates 0</metric>
    <metric>[dim1_diff] of candidates 1</metric>
    <metric>[dim2_diff] of candidates 1</metric>
    <metric>cohort_cand1</metric>
    <metric>cohort_cand2</metric>
    <metric>cohort01</metric>
    <metric>cohort02</metric>
    <metric>cohort11</metric>
    <metric>cohort12</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WMHD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WMHD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WMCD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WMCD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WFHD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WFHD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WFCD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WFCD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MMHD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MMHD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MMCD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MMCD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MFHD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MFHD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MFCD"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MFCD"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WMHR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WMHR"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WMCR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WMCR"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WFHR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WFHR"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "WFCR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "WFCR"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MMHR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MMHR"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MMCR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MMCR"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MFHR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MFHR"]</metric>
    <metric>count resident with [choice = "C1" and voter_type = "MFCR"]</metric>
    <metric>count resident with [choice = "C2" and voter_type = "MFCR"]</metric>
    <metric>median [c1_distance] of resident with [voter = 1]</metric>
    <metric>median [c1_distance] of resident with [voter = 0]</metric>
    <metric>median [c2_distance] of resident with [voter = 1]</metric>
    <metric>median [c2_distance] of resident with [voter = 0]</metric>
    <metric>median [c1_distance] of resident with [choice = "C1"]</metric>
    <metric>median [c2_distance] of resident with [choice = "C2"]</metric>
    <metric>starting-seed</metric>
    <enumeratedValueSet variable="strategy1">
      <value value="&quot;Partisan&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="strategy2">
      <value value="&quot;Pragmatist&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="messaging">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sd">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="col">
      <value value="-0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="w">
      <value value="-0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="race1">
      <value value="-0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dem_dim1">
      <value value="-0.363"/>
      <value value="-0.263"/>
      <value value="-0.463"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rep_dim1">
      <value value="0.397"/>
      <value value="0.297"/>
      <value value="0.497"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="va02 - candidate distance" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="5"/>
    <metric>median [c1_distance] of resident with [voter = 1]</metric>
    <metric>median [c1_distance] of resident with [voter = 0]</metric>
    <metric>median [c2_distance] of resident with [voter = 1]</metric>
    <metric>median [c2_distance] of resident with [voter = 0]</metric>
    <metric>median [c1_distance] of resident with [choice = "C1"]</metric>
    <metric>median [c2_distance] of resident with [choice = "C2"]</metric>
    <metric>min [c1_distance] of resident with [choice = "C1"]</metric>
    <metric>min [c2_distance] of resident with [choice = "C2"]</metric>
    <metric>max [c1_distance] of resident with [choice = "C1"]</metric>
    <metric>max [c2_distance] of resident with [choice = "C2"]</metric>
    <metric>mean [c1_distance] of resident with [choice = "C1"]</metric>
    <metric>mean [c2_distance] of resident with [choice = "C2"]</metric>
    <metric>standard-deviation [c1_distance] of resident with [choice = "C1"]</metric>
    <metric>standard-deviation [c2_distance] of resident with [choice = "C2"]</metric>
    <metric>starting-seed</metric>
    <enumeratedValueSet variable="strategy1">
      <value value="&quot;Partisan&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="strategy2">
      <value value="&quot;Pragmatist&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="messaging">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sd">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="col">
      <value value="-0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="w">
      <value value="-0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="race1">
      <value value="-0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dem_dim1">
      <value value="-0.363"/>
      <value value="-0.263"/>
      <value value="-0.463"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rep_dim1">
      <value value="0.397"/>
      <value value="0.297"/>
      <value value="0.497"/>
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
