extensions [table]

breed [resident residents]
breed [candidate candidates]


globals [

  starting-seed

  ;;POPULATION TOTALS
  ;voters
 ; %voters
  tot_vap
  white_vap
  minority_vap
  all-ranked-lists


  ;;GROUPS OF SUPPORTERS
  cohort1d
  cohort2d
  cohort1r
  cohort2r
  mean_all1d
  mean_all2d


  ;CAMPAIGN VARIABLES
  strategy
  messaging
  new-candidate ;count how many new candidates have entered the race during the campaign steps
  center-space ;measure for the space between candidates across the centerpoints of the two NOMINATE axes
  independent
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
  age
  alienation
  race
  gender
  education
  group
  voter_type ;one of the 16 groups to which the voter may belong
  cand-distance ;stores value of Euclidean distance between voter i and closest candidate
  candidate-distances  ; a list of (candidate, distance) pairs
  poll2 ;polling in second round vote
  choice2 ;vote in second round of voting
  cand-distance2 ;store distances in second round of voting
  voter2 ;voter status in second round of voting


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
  cid
  cohort-mean1
  cohort-mean2
  cohort-size
  votes ;stores the first round vote tally
  finalist ;declares the candidate to be one of the "top two"

]


to setup ;initial population and environment setup

  clear-all
  set starting-seed new-seed
  random-seed starting-seed

   random-seed 42 ;FOR REPLICATION for 5 runs
   ask patches [set pcolor white]
   create-candidate 2
   create-resident 533660
   population-attributes
   groups
   nominate
   politicians

   set tot_vap 533660
   set new-candidate 0
   set independent 0


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
  ask n-of 51358 resident with [race = "none"][set race "white" set voter_type "WMHD"]
  ask n-of 70922 resident with [race = "none"][set race "white" set voter_type "WMCD"]
  ask n-of 46466 resident with [race = "none"][set race "white" set voter_type "WFHD"]
  ask n-of 75814 resident with [race = "none"][set race "white" set voter_type "WFCD"]
  ask n-of 37489 resident with [race = "none"][set race "minority" set voter_type "MMHD"]
  ask n-of 51770 resident with [race = "none"][set race "minority" set voter_type "MMCD"]
  ask n-of 33919 resident with [race = "none"][set race "minority" set voter_type "MFHD"]
  ask n-of 55341 resident with [race = "none"][set race "minority" set voter_type "MFCD"]
  ask n-of 17119 resident with [race = "none"][set race "white" set voter_type "WMHR"]
  ask n-of 23641 resident with [race = "none"][set race "white" set voter_type "WMCR"]
  ask n-of 15489 resident with [race = "none"][set race "white" set voter_type "WFHR"]
  ask n-of 25271 resident with [race = "none"][set race "white" set voter_type "WFCR"]
  ask n-of 6103 resident with [race = "none"][set race "minority" set voter_type "MMHR"]
  ask n-of 8428 resident with [race = "none"][set race "minority" set voter_type "MMCR"]
  ask n-of 5522 resident with [race = "none"][set race "minority" set voter_type "MMHR"]
  ask n-of 9008 resident with [race = "none"][set race "minority" set voter_type "MFHR"]

end

to nominate

ask resident [

    if voter_type = "WMHD" [set nominate_dim1 dem_dim1]
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
    if voter_type = "MFHR" [set nominate_dim1 rep_dim1 + race1 + w]
    if voter_type = "MFCR" [set nominate_dim1 rep_dim1 + race1 + col]

  ]

end


to politicians

  ask candidates 0 [ ;Beyer
    set party  "democrat"
    set shape "star"
    set label "democrat"
    set color red
    set size 5
    set xcor -5
    set ycor 5
    set cid (word "C" who)
    set nominate_dim1 -0.385
    set nominate_dim2 -0.095
    set adaptation strategy1
    set finalist 0
  ]

  ask candidates 1  [ ;Jordan
    set party "republican";
    set shape "star"
    set label "republican"
    set color blue
    set size 5
    set xcor 5
    set ycor 5
    set cid (word "C" who)
    set nominate_dim1 0.268
    set nominate_dim2 0.07
    set adaptation strategy2
    set finalist 0
  ]

end


to go

  if ticks < 5
    [ campaign
  dem-entry
  rep-entry
  center
  centrist-entry]

  if ticks = 5
    [ elect-plurality ]

  if ticks > 5 ;second round of campaigning for the top two candidates
  [campaign2]

  if ticks = 8 ;single vote for one candidate that produces a majority winner
  [elect-plurality2]

  tick
end

to campaign

  ;count the vote / take the poll numbers

  ask resident with [neighborhood = 1] [
    let closest-candidate nobody
    let shortest-distance 2112

    ask candidate [
      ; Calculate Euclidean distance between resident and candidate in 2D
      let dist sqrt((nominate_dim1 - [nominate_dim1] of myself) ^ 2 + (nominate_dim2 - [nominate_dim2] of myself) ^ 2)
      if dist < shortest-distance [
        set shortest-distance dist
        set closest-candidate self
      ]
    ]

    set poll closest-candidate
  ]


  ;this section creates the voter blocs that candidates poll/care about

 ; Global ideological means
  set mean_all1d mean [nominate_dim1] of resident
  set mean_all2d mean [nominate_dim2] of resident

  ; loop through each candidate and store cohort info
  ask candidate [
    let my-id (word "C" who)  ; or use a 'cid' variable if set earlier
    let my-voters resident with [poll = myself]

    let count-my-voters count my-voters
    set cohort-size count-my-voters  ; optional: a variable to track it

    ifelse count-my-voters > 0 [
      let avg-x mean [nominate_dim1] of my-voters
      let avg-y mean [nominate_dim2] of my-voters
      ; store these values on the candidate
      set cohort-mean1 avg-x
      set cohort-mean2 avg-y
    ]
    [
      set cohort-mean1 "null"
      set cohort-mean2 "null"
    ]
  ]

ask candidate [
  let old-dim1 nominate_dim1
  let old-dim2 nominate_dim2

  ; === PARTISAN ADAPTATION ===
  if adaptation = "Partisan" [
    if cohort-size > 0 [
      set nominate_dim1 cohort-mean1
      set nominate_dim2 cohort-mean2
      set dim1_diff (nominate_dim1 - old-dim1)
      set dim2_diff (nominate_dim2 - old-dim2)
    ]
  ]

  ; === HUNTER ADAPTATION ===
  if adaptation = "Hunter" [
    set nominate_dim1 mean_all1d - 0.01
    set nominate_dim2 mean_all2d - 0.01
    set dim1_diff (nominate_dim1 - old-dim1)
    set dim2_diff (nominate_dim2 - old-dim2)
  ]

  ; === PRAGMATIST ADAPTATION ===
  if adaptation = "Pragmatist" [
    if cohort-size > 0 [
      ; find a rival with more support
      let rival max-one-of other candidate [cohort-size]

      if rival != nobody and [cohort-size] of rival > cohort-size [
        ifelse cohort-mean1 < [nominate_dim1] of rival
          [set nominate_dim1 nominate_dim1 + messaging]
          [set nominate_dim1 nominate_dim1 - messaging]

        ifelse cohort-mean2 < [nominate_dim2] of rival
          [set nominate_dim2 nominate_dim2 + 0.01]
          [set nominate_dim2 nominate_dim2 - 0.01]
      ]

      set dim1_diff (nominate_dim1 - old-dim1)
      set dim2_diff (nominate_dim2 - old-dim2)
    ]
  ]

  ; === STICKER STRATEGY ===
  if strategy1 = "Sticker" [
    set nominate_dim1 old-dim1
    set nominate_dim2 old-dim2
  ]
]
end

to dem-entry
;simulates a challenge to the "left flank" of the Democrat (candidate 0)

  let condition1? false

  ask candidates 0 [

    if cohort-mean1 != "null" and cohort-mean2 != "null" [
    if mean_all1d < cohort-mean1 and mean_all2d < cohort-mean2 [
      set condition1? true
    ]
    ]
  ]

  if condition1? and new-candidate < 3[
    generate-dem
  ]
end

to generate-dem
  if new-candidate < 3 [
  ;;;CONDITIONAL FOR WHAT TYPE OF CANDIDATE

  create-candidate 1 [
    set party "Democrat"
    set shape "star"
    set label "Democrat"
    set color green
    set size 5
    set cid (word "C" who)

    let x-mid [nominate_dim1] of candidates 0 + random-float -0.2
    let y-mid [nominate_dim2] of candidates 0 + random-float -0.2
    set nominate_dim1 x-mid
    set nominate_dim2 y-mid
    set xcor x-mid * 10
    set ycor y-mid * 10
    set adaptation "Sticker"
  ]

 set new-candidate new-candidate + 1
    show (word "New candidate dem: " new-candidate ", independent: " independent)
  ]
end


to rep-entry

  let condition1? false

  ask candidates 1 [
    ;let my-voters voters with [party = party]
    ;let my-party-pos average-position my-voters
    ;PURPOSE: if the existing Dem candidate is closer to the mean of the total electorate than the mean of their own party,
    ;a candidate appears on the left flank
    ;let dist-to-electorate distance-between nominate_dim1 nominate_dim2 item 0 electorate-pos item 1 electorate-pos
    ;let dist-to-party distance-between nominate_dim1 nominate_dim2 item 0 my-party-pos item 1 my-party-pos

    if cohort-mean1 != "null" and cohort-mean2 != "null" [
    if mean_all1d < cohort-mean1 and mean_all2d < cohort-mean2 [
      set condition1? true
    ]
  ]
  ]

  if condition1? and new-candidate < 3[
    generate-rep
  ]
end

to generate-rep
  if new-candidate < 3 [
  ;;;CONDITIONAL FOR WHAT TYPE OF CANDIDATE

  create-candidate 1 [
    set party "Republican"
    set shape "star"
    set label "Republican"
    set color green
    set size 5
    set cid (word "C" who)

    let x-mid [nominate_dim1] of candidates 1 + random-float 0.2
    let y-mid [nominate_dim2] of candidates 1 + random-float 0.2
    set nominate_dim1 x-mid
    set xcor x-mid * 10
    set ycor y-mid * 10
    set adaptation "Sticker"
  ]

  set new-candidate new-candidate + 1
    show (word "New candidate rep: " new-candidate ", independent: " independent)
  ]

end


to center

    set center-space
      sqrt((([nominate_dim1] of candidates 0 - [nominate_dim1] of candidates 1) * ([nominate_dim1] of candidates 0 - [nominate_dim1] of candidates 1)) +
            (([nominate_dim2] of candidates 0 - [nominate_dim2] of candidates 1) * ([nominate_dim2] of candidates 0 - [nominate_dim2] of candidates 1)))

end

to centrist-entry
;simulates a centrist when there is a large space in the middle

  let condition2? false

    if center-space > centrifugal [
      set condition2? true
    ]


  if condition2? and new-candidate < 3[
    generate-centrist
  ]
end

to generate-centrist
  if new-candidate < 3  [
  ;;;CONDITIONAL FOR WHAT TYPE OF CANDIDATE
  ;ask candidates 4
    create-candidate 1 [
    set party "Centrist"
    set shape "star"
    set label "Centrist"
    set color green
    set size 5
    set cid (word "C" who)

    set nominate_dim1 random-normal 0.0 0.1
    set nominate_dim2 random-normal 0.0 0.33
    set xcor 10
    set ycor 10
    set adaptation "Pragmatist"
  ]
    ]
  set new-candidate new-candidate + 1
  set independent independent + 1
    show (word "New candidate ind: " new-candidate ", independent: " independent)

end


to elect-plurality

  ;determines which voters actually go to vote on election day
  ;provides the calculation for the actual vote

 ;distance calculation

  ask resident with [neighborhood = 1] [
    let closest-candidate nobody
    let shortest-distance 2112

    ask candidate [
      ; Calculate Euclidean distance between resident and candidate in 2D
      let dist sqrt((nominate_dim1 - [nominate_dim1] of myself) ^ 2 + (nominate_dim2 - [nominate_dim2] of myself) ^ 2)
      if dist < shortest-distance [
        set shortest-distance dist
        set closest-candidate self
      ]
    ]

    set poll closest-candidate
    set cand-distance shortest-distance

    if shortest-distance < alienation
    [set voter 1]
  ]

;count the vote

    ask resident with [neighborhood = 1 and voter = 1]
  [
    set choice poll
  ]

;decide the two finalists
 ask candidate [
  set votes 0
]

; count votes
ask resident with [neighborhood = 1 and voter = 1] [
  ask choice [
    set votes votes + 1
  ]
]

; find top two candidates by votes
let sorted-candidates sort-by [[c1 c2] -> [votes] of c2 < [votes] of c1] candidate
let top1 first sorted-candidates
let top2 item 1 sorted-candidates

; print the winners
;show (word "Top winner: " [who] of top1 " with votes: " [votes] of top1)
;show (word "Second winner: " [who] of top2 " with votes: " [votes] of top2)

;apply the top two attribute to carry the candidate to the next round
ask candidate [
    if (self = top1) or (self = top2) [set finalist 1]
  ]

end


to campaign2

  ;count the vote / take the poll numbers

  ask resident with [neighborhood = 1] [
    let closest-candidate2 nobody
    let shortest-distance2 2112

  ask candidate with [finalist = 1][
     ; Calculate Euclidean distance between resident and candidate in 2D
      let dist2 sqrt((nominate_dim1 - [nominate_dim1] of myself) ^ 2 + (nominate_dim2 - [nominate_dim2] of myself) ^ 2)
      if dist2 < shortest-distance2 [
        set shortest-distance2 dist2
        set closest-candidate2 self
      ]
]

    set poll2 closest-candidate2
  ]


  ;this section creates the voter blocs that candidates poll/care about

 ; Global ideological means
  set mean_all1d mean [nominate_dim1] of resident
  set mean_all2d mean [nominate_dim2] of resident

  ; loop through each candidate and store cohort info
  ask candidate with [finalist = 1][
    let my-id (word "C" who)  ; or use a 'cid' variable if set earlier
    let my-voters resident with [poll = myself]

    let count-my-voters count my-voters
    set cohort-size count-my-voters  ; optional: a variable to track it

    ifelse count-my-voters > 0 [
      let avg-x mean [nominate_dim1] of my-voters
      let avg-y mean [nominate_dim2] of my-voters
      ; store these values on the candidate
      set cohort-mean1 avg-x
      set cohort-mean2 avg-y
    ]
    [
      set cohort-mean1 "null"
      set cohort-mean2 "null"
    ]
  ]

  ask candidate with [finalist = 1][
  let old-dim1 nominate_dim1
  let old-dim2 nominate_dim2

  ; === PARTISAN ADAPTATION ===
  if adaptation = "Partisan" [
    if cohort-size > 0 [
      set nominate_dim1 cohort-mean1
      set nominate_dim2 cohort-mean2
      set dim1_diff (nominate_dim1 - old-dim1)
      set dim2_diff (nominate_dim2 - old-dim2)
    ]
  ]

  ; === HUNTER ADAPTATION ===
  if adaptation = "Hunter" [
    set nominate_dim1 mean_all1d - 0.01
    set nominate_dim2 mean_all2d - 0.01
    set dim1_diff (nominate_dim1 - old-dim1)
    set dim2_diff (nominate_dim2 - old-dim2)
  ]

  ; === PRAGMATIST ADAPTATION ===
  if adaptation = "Pragmatist" [
    if cohort-size > 0 [
      ; find a rival with more support
      let rival max-one-of other candidate [cohort-size]

      if rival != nobody and [cohort-size] of rival > cohort-size [
        ifelse cohort-mean1 < [nominate_dim1] of rival
          [set nominate_dim1 nominate_dim1 + messaging]
          [set nominate_dim1 nominate_dim1 - messaging]

        ifelse cohort-mean2 < [nominate_dim2] of rival
          [set nominate_dim2 nominate_dim2 + 0.01]
          [set nominate_dim2 nominate_dim2 - 0.01]
      ]

      set dim1_diff (nominate_dim1 - old-dim1)
      set dim2_diff (nominate_dim2 - old-dim2)
    ]
  ]

  ; === STICKER STRATEGY ===
  if strategy1 = "Sticker" [
    set nominate_dim1 old-dim1
    set nominate_dim2 old-dim2
  ]
]
end




to elect-plurality2

  ;determines which voters actually go to vote on election day
  ;provides the calculation for the actual vote

 ;distance calculation


  ;count the vote / take the poll numbers / determine turnout

  ask resident with [neighborhood = 1] [
    let closest-candidate2 nobody
    let shortest-distance2 2112

  ask candidate with [finalist = 1][
     ; Calculate Euclidean distance between resident and candidate in 2D
      let dist2 sqrt((nominate_dim1 - [nominate_dim1] of myself) ^ 2 + (nominate_dim2 - [nominate_dim2] of myself) ^ 2)
      if dist2 < shortest-distance2 [
        set shortest-distance2 dist2
        set closest-candidate2 self
      ]
]

    set poll2 closest-candidate2
    set cand-distance2 shortest-distance2


    if shortest-distance2 < alienation
    [set voter2 1]
  ]

;count the vote

    ask resident with [neighborhood = 1 and voter2 = 1]
  [
    set choice2 poll2
  ]

end


to-report all-cands
  let cand-list sort candidate
  let counts (list cand-list)
  report counts
end

to-report cand-dim1
  let cand-list sort candidate
  let counts map [c -> (list [nominate_dim1] of c)] cand-list
  report counts
end

 to-report cand-dim2
  let cand-list sort candidate
  let counts map [c -> (list [nominate_dim2] of c)] cand-list
  report counts
end

to-report cand-party
  let cand-list sort candidate
  let counts map [c -> (list [party] of c)] cand-list
  report counts
end

to-report count-choice-votes
  let first-round sort candidate
  let counts map [c -> count resident with [choice = c and neighborhood = 1 and voter = 1]] first-round
  report counts
end

to-report all-finalists
  let cand-list sort candidate with [finalist = 1]
  let counts (list cand-list)
  report counts
end

to-report count-choice-votes-round2
  let finalists sort candidate with [finalist = 1]
  let counts map [c -> count resident with [choice2 = c and neighborhood = 1 and voter2 = 1]] finalists
  report counts
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
1171
149
1233
194
Rashid
count resident with [choice = candidates 0]
17
1
11

MONITOR
1174
206
1233
251
Wittman
count resident with [choice = candidates 1]
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
620
221
801
266
NIL
median [alienation] of resident
5
1
11

MONITOR
977
201
1145
246
NIL
count resident with [voter = 1]
17
1
11

CHOOSER
32
98
170
143
strategy1
strategy1
"Partisan" "Pragmatist" "Hunter" "Sticker"
3

CHOOSER
34
154
172
199
strategy2
strategy2
"Partisan" "Pragmatist" "Hunter" "Sticker"
3

MONITOR
322
10
415
55
NIL
count tot_vap
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

SLIDER
16
335
188
368
col
col
-0.2
-0.1
-0.2
0.1
1
NIL
HORIZONTAL

SLIDER
16
289
188
322
sd
sd
0.1
0.2
0.2
.1
1
NIL
HORIZONTAL

SLIDER
16
233
188
266
dem_dim1
dem_dim1
-1.0
0
-0.363
0.001
1
NIL
HORIZONTAL

SLIDER
12
384
184
417
w
w
-0.5
0.0
-0.05
0.01
1
NIL
HORIZONTAL

SLIDER
14
426
186
459
race1
race1
-1.0
0.0
-0.1
0.1
1
NIL
HORIZONTAL

SLIDER
14
484
186
517
rep_dim1
rep_dim1
0
1.0
0.397
.001
1
NIL
HORIZONTAL

SLIDER
16
528
188
561
centrifugal
centrifugal
0
1.1
0.0841
0.0001
1
NIL
HORIZONTAL

MONITOR
853
27
948
72
NIL
new-candidate
17
1
11

MONITOR
611
280
686
325
NIL
mean_all1d
17
1
11

MONITOR
618
358
693
403
NIL
mean_all2d
17
1
11

MONITOR
819
248
905
293
NIL
center-space
17
1
11

MONITOR
861
89
943
134
NIL
independent
17
1
11

MONITOR
764
366
956
411
NIL
count resident with [voter2 = 1]
17
1
11

MONITOR
1017
261
1276
306
NIL
count resident with [choice = candidates 98]
17
1
11

MONITOR
1022
317
1281
362
NIL
count resident with [choice = candidates 99]
17
1
11

MONITOR
1025
374
1291
419
NIL
count resident with [choice = candidates 100]
17
1
11

MONITOR
234
387
493
432
NIL
count resident with [choice2 = candidates 0]
17
1
11

MONITOR
244
440
503
485
NIL
count resident with [choice2 = candidates 1]
17
1
11

MONITOR
232
490
498
535
NIL
count resident with [choice2 = candidates 98]
17
1
11

MONITOR
248
546
514
591
NIL
count resident with [choice2 = candidates 99]
17
1
11

MONITOR
234
604
507
649
NIL
count resident with [choice2 = candidates 100]
17
1
11

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
  <experiment name="va08 - cand sweep simple center" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="10"/>
    <metric>count resident with [voter = 1]</metric>
    <metric>median [cand-distance] of resident</metric>
    <metric>mean [cand-distance] of resident</metric>
    <metric>standard-deviation [cand-distance] of resident</metric>
    <metric>count resident with [voter2 = 1]</metric>
    <metric>median [cand-distance2] of resident</metric>
    <metric>mean [cand-distance2] of resident</metric>
    <metric>standard-deviation [cand-distance2] of resident</metric>
    <metric>count-choice-votes</metric>
    <metric>all-cands</metric>
    <metric>cand-dim1</metric>
    <metric>cand-dim2</metric>
    <metric>cand-party</metric>
    <metric>count-choice-votes</metric>
    <metric>all-finalists</metric>
    <metric>count-choice-votes-round2</metric>
    <enumeratedValueSet variable="strategy1">
      <value value="&quot;Partisan&quot;"/>
      <value value="&quot;Pragmatist&quot;"/>
      <value value="&quot;Sticker&quot;"/>
      <value value="&quot;Hunter&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="strategy2">
      <value value="&quot;Partisan&quot;"/>
      <value value="&quot;Pragmatist&quot;"/>
      <value value="&quot;Sticker&quot;"/>
      <value value="&quot;Hunter&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="messaging">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="centrifugal">
      <value value="0.08"/>
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="va08 - 5runs" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="10"/>
    <metric>count resident with [voter = 1]</metric>
    <metric>median [cand-distance] of resident</metric>
    <metric>mean [cand-distance] of resident</metric>
    <metric>standard-deviation [cand-distance] of resident</metric>
    <metric>count resident with [voter2 = 1]</metric>
    <metric>median [cand-distance2] of resident</metric>
    <metric>mean [cand-distance2] of resident</metric>
    <metric>standard-deviation [cand-distance2] of resident</metric>
    <metric>count-choice-votes</metric>
    <metric>all-cands</metric>
    <metric>cand-dim1</metric>
    <metric>cand-dim2</metric>
    <metric>cand-party</metric>
    <metric>count-choice-votes</metric>
    <metric>all-finalists</metric>
    <metric>count-choice-votes-round2</metric>
    <metric>starting-seed</metric>
    <enumeratedValueSet variable="strategy1">
      <value value="&quot;Partisan&quot;"/>
      <value value="&quot;Pragmatist&quot;"/>
      <value value="&quot;Sticker&quot;"/>
      <value value="&quot;Hunter&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="strategy2">
      <value value="&quot;Partisan&quot;"/>
      <value value="&quot;Pragmatist&quot;"/>
      <value value="&quot;Sticker&quot;"/>
      <value value="&quot;Hunter&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="messaging">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="centrifugal">
      <value value="0.08"/>
      <value value="0.25"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sd">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="race1">
      <value value="-0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="w">
      <value value="-0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="col">
      <value value="-0.2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="va08 - 10runs" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="10"/>
    <metric>count resident with [voter = 1]</metric>
    <metric>median [cand-distance] of resident</metric>
    <metric>mean [cand-distance] of resident</metric>
    <metric>standard-deviation [cand-distance] of resident</metric>
    <metric>count resident with [voter2 = 1]</metric>
    <metric>median [cand-distance2] of resident</metric>
    <metric>mean [cand-distance2] of resident</metric>
    <metric>standard-deviation [cand-distance2] of resident</metric>
    <metric>count-choice-votes</metric>
    <metric>all-cands</metric>
    <metric>cand-dim1</metric>
    <metric>cand-dim2</metric>
    <metric>cand-party</metric>
    <metric>count-choice-votes</metric>
    <metric>all-finalists</metric>
    <metric>count-choice-votes-round2</metric>
    <metric>starting-seed</metric>
    <enumeratedValueSet variable="strategy1">
      <value value="&quot;Partisan&quot;"/>
      <value value="&quot;Pragmatist&quot;"/>
      <value value="&quot;Sticker&quot;"/>
      <value value="&quot;Hunter&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="strategy2">
      <value value="&quot;Partisan&quot;"/>
      <value value="&quot;Pragmatist&quot;"/>
      <value value="&quot;Sticker&quot;"/>
      <value value="&quot;Hunter&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="messaging">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="centrifugal">
      <value value="0.08"/>
      <value value="0.25"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sd">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="race1">
      <value value="-0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="w">
      <value value="-0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="col">
      <value value="-0.2"/>
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
