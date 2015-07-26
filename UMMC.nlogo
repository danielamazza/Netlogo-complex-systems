globals [Operations Dataex fcc] ; numero di operazioni applicazione, Dati da Offloadare, Velocità di calcolo della centralized cloud

breed [antennas antenna]
antennas-own [chcapacity radius n-conn n-attuali flops]

breed [aps ap]
aps-own [chcapacity radius n-conn n-attuali flops]

breed [cloudlets cloudlet]
cloudlets-own [chcapacity radius n-conn n-attuali flops ]

breed [smds smd ]
smds-own [chcapacity radius n-conn n-attuali flops latency ]

directed-link-breed [connessioni connessione]
directed-link-breed [coperture copertura]

to display-labels
  if show-label-who? [
    ask turtles [ set label who ]
  ]
end

to setup
  clear-all
  set Operations 100 ;variabile della applicazione
  set Dataex 20 ;variabile della applicazione
  set fcc 10000 ;variabile del cloud centralizzato 
  setup-antennas
  setup-aps
  setup-cloudlets  
  setup-smds
  display-labels  
  reset-ticks
end
 
to setup-antennas
  set-default-shape antennas "antenna" 
  create-antennas number-of-antennas
  [
    set color white
    set size 3.5  ;; easier to see
    setxy 0 0 ;random-xcor random-ycor
    set chcapacity antenna-chcapacity    
    set radius antennas-radius    
    set n-conn antennas-n-conn
    set n-attuali 0
    set flops fcc    
  ]
end 


to setup-aps
  set-default-shape aps "ap" 
  create-aps number-of-aps
  [
    set color white
    set size 2  ;; easier to see
    setxy random-xcor random-ycor
    set chcapacity aps-capacity
    set radius aps-radius
    set n-conn aps-n-conn
    set n-attuali 0
    set flops fcc
   ] 
  
end

to setup-cloudlets
  set-default-shape cloudlets "cloud" 
  create-cloudlets number-of-cloudlets
  [
    set size 3.5  ;; easier to see
    set color white
    setxy random-xcor random-ycor
    set chcapacity cloudlet-capacity    
    set radius cloudlet-radius
    set n-conn cloudlets-n-conn
    set n-attuali 0
    set flops cloudlet-flops    
  ]
end 

to setup-smds
  set-default-shape smds "smd"   
  create-smds number-of-smds
  [
    set size 1  ;; easier to see
    set color pink
    setxy random-xcor random-ycor
    set chcapacity smd-capacity
    set radius smds-radius
    set n-conn smds-n-conn
    set n-attuali 0
    set flops smd-flops    
    set latency Operations / flops
    separate-smds
  ]
end
 
to separate-smds  
  if any? other turtles-here
    [ fd 1     
      separate-smds ]
end  
  
to go
  move-smd
  link-if-covered-by ;potenziale copertura
  delete-link-lunghi 
  connect-smds-only-one-vicino
  aggiorna-latency 
  ;user-message (word "mean latency = " mean ([latency] of smds))
  do-plotting
  tick
end
  
to move-smd
  ask smds [
    right random 50
    left random 50
    forward random 3
  ]
end

to aggiorna-latency
  ask smds [ ;user-message (word "sono smd = " self  )
           ifelse count my-in-connessioni = 0
                 [ ;user-message (word "non sono connesso" )
                   set latency Operations / flops
                   ;user-message (word "quindi latency = locale = " latency " by " self)
                   ]
                 [;user-message (word "sono connesso" )
                  let vel 0
                  ;user-message (word "quindi vel (iniziale) = " vel " by " self)
                  let Throughput 0
                  let lunghezza 0
                  ;user-message (word "e Throughput (iniziale) = " Throughput  " by " self)
                  ask in-connessione-neighbors [ ;il vicino connesso dovrebbe essere solo uno, altrimenti usiamo one-of
                                               ;user-message (word "chiedo alla mia connessione: " self)
                                               ;user-message (word "self = "  self)
                                               ;user-message (word "myself = "  myself)
                                               set lunghezza distance myself 
                                                ;user-message (word "lunghezza = "  lunghezza)
                                               set Throughput chcapacity / n-attuali * log (1 + (100 / (lunghezza ^ 2))) 2 
                                               
                                               set vel flops 
                                               ;user-message (word "e di porre vel = " vel " by " self)
                                               ]
                  set latency  (Operations / vel ) + (Dataex / Throughput)
                 ; user-message (word "sono tornato io: " self " e pongo latency = " latency)                                            
                 ]
           ]
  ;user-message (word "fine aggiornamento latency " ) 
end




to link-if-covered-by   
  ask turtles [    
    ask other smds in-radius radius [
         if (not out-connessione-neighbor? myself)  
         [create-copertura-from myself  ]  ]    
      ]
     
end

to delete-link-lunghi  
  ask turtles [ 
    let lung radius
    ask my-out-links with [link-length > lung ][die] 
    ; devo eliminare anche le connessioni, e devo aggiornare il set n-attuali 
    set n-attuali count my-out-connessioni
  ]
end

to connect-smds-only-one ; per connettere un smd al massimo a una unità
 ask smds[
  if count my-in-connessioni < 1 ; non ha ancora connessioni
  [ask other turtles [
    connect self myself]
  ]]
end

;la seguente per connettere al più vicino (ma se è connesso rimane, senza handover anche se un altro è più vicino)
to connect-smds-only-one-vicino ;  
 ask smds[ 
  if count my-in-connessioni < 1 ; se non ha ancora connessioni 
  [
    connect min-one-of in-link-neighbors [distance myself] self 
  ]]
end

to connect [node smd] 
  ask smd [   
    if (count my-in-connessioni = 0) and (count my-in-coperture > 0) [  ; se smd non è ancora connesso a nessuno
                                     ask node [
                                                 if ((out-link-neighbor? smd) and              ; se node copre smd
                                                    (count my-out-connessioni < n-conn))       ; e node è ancora disponibile    
                                                 [ ask out-copertura-to smd  [die] ; elimina il link che rappresenta la copertura
                                                 create-connessione-to smd [ set color red ;creo una connessione al posto del precedente link di copertura
                                                                             set thickness .5                                                                              
                                                                           ]
                                                 set n-attuali n-attuali + 1
                                                 ]
                                                 
                                              ]
                                      ]
          ]
end





to-report link-distance [ x y ]
  let a [ distancexy x y ] of end1
  let b [ distancexy x y ] of end2
  let c link-length
  let d (0 - a ^ 2 + b ^ 2 + c ^ 2) / (2 * c)
  if d > c [
    report a
  ]
  if d < 0 [
    report b
  ]
  report sqrt (b ^ 2 - d ^ 2)
end

to do-plotting
  set-current-plot "Avg. Latency"
  set-current-plot-pen "Latency"
    plot mean [ latency ] of smds
end

to-report latency-media
  report mean [ latency ] of smds
end
@#$#@#$#@
GRAPHICS-WINDOW
687
10
1213
557
25
25
10.12
1
14
1
1
1
0
1
1
1
-25
25
-25
25
1
1
1
ticks
30.0

SLIDER
9
77
145
110
number-of-smds
number-of-smds
0
250
74
1
1
NIL
HORIZONTAL

SLIDER
323
120
469
153
antennas-radius
antennas-radius
0.0
200.0
25
1.0
1
NIL
HORIZONTAL

SLIDER
482
81
629
114
number-of-cloudlets
number-of-cloudlets
0
5
2
1
1
NIL
HORIZONTAL

SLIDER
482
117
629
150
cloudlet-radius
cloudlet-radius
0.0
70.0
9.7
0.1
1
NIL
HORIZONTAL

BUTTON
9
10
78
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
86
10
153
43
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
157
249
473
446
Avg. Latency
time
latency
0.0
100.0
0.0
10.0
true
true
"" ""
PENS
"latency" 1.0 0 -13345367 true "" ""

TEXTBOX
12
53
152
72
SMD's settings
14
0.0
1

TEXTBOX
490
54
646
88
Cloudlets settings
14
0.0
1

SWITCH
166
10
329
43
show-label-who?
show-label-who?
0
1
-1000

SLIDER
323
80
469
113
number-of-antennas
number-of-antennas
0
3
1
1
1
NIL
HORIZONTAL

TEXTBOX
332
55
482
73
Macrocells setting
14
0.0
1

SLIDER
161
116
307
149
aps-radius
aps-radius
0
100
19
1
1
NIL
HORIZONTAL

SLIDER
162
78
308
111
number-of-aps
number-of-aps
0
10
3
1
1
NIL
HORIZONTAL

TEXTBOX
167
53
317
71
AP's settings
14
0.0
1

SLIDER
7
117
145
150
smds-radius
smds-radius
0
100
10
1
1
NIL
HORIZONTAL

SLIDER
325
198
469
231
antennas-n-conn
antennas-n-conn
0
100
47
1
1
NIL
HORIZONTAL

SLIDER
162
198
307
231
aps-n-conn
aps-n-conn
0
100
18
1
1
NIL
HORIZONTAL

SLIDER
480
199
630
232
cloudlets-n-conn
cloudlets-n-conn
0
100
8
1
1
NIL
HORIZONTAL

SLIDER
7
197
144
230
smds-n-conn
smds-n-conn
0
5
0
1
1
NIL
HORIZONTAL

SLIDER
7
237
143
270
smd-flops
smd-flops
0
100
31
1
1
NIL
HORIZONTAL

SLIDER
480
243
630
276
cloudlet-flops
cloudlet-flops
0
1000
170
1
1
NIL
HORIZONTAL

SLIDER
7
157
145
190
smd-capacity
smd-capacity
0
100
9
1
1
NIL
HORIZONTAL

SLIDER
481
158
630
191
cloudlet-capacity
cloudlet-capacity
0
100
50
1
1
NIL
HORIZONTAL

SLIDER
159
158
307
191
aps-capacity
aps-capacity
0
100
76
1
1
NIL
HORIZONTAL

SLIDER
322
159
469
192
antenna-chcapacity
antenna-chcapacity
0
100
49
1
1
NIL
HORIZONTAL

MONITOR
140
478
301
523
latency
latency-media
17
1
11

@#$#@#$#@
## WHAT IS IT?

Algoritmo:
1. verifica quali sono i link di copertura
2. ogni smd sceglie tra i possibili un link di copertura (diventa una connessione)-
NOTA: il nodo che fornisce la connessione non deve aver già tutte le connessioni impegnate
NOTA 2: come scegliere? Il nodo che fornisce la connessione ha già un numero di n connes-sioni attuali fornite, quindi in base a questo nconattuali e alla distanza (lunghezza link) ha un valore (valore di link) --> l'smd sceglie tra le potenziali connessioni quella che ha un costo minore (compreso il local computation).



## HOW IT WORKS

There are two main variations to this model.

In the first variation, wolves and sheep wander randomly around the landscape, while the wolves look for sheep to prey on. Each step costs the wolves energy, and they must eat sheep in order to replenish their energy - when they run out of energy they die. To allow the population to continue, each wolf or sheep has a fixed probability of reproducing at each time step. This variation produces interesting population dynamics, but is ultimately unstable.

The second variation includes grass (green) in addition to wolves and sheep. The behavior of the wolves is identical to the first variation, however this time the sheep must eat grass in order to maintain their energy - when they run out of energy they die. Once grass is eaten it will only regrow after a fixed amount of time. This variation is more complex than the first, but it is generally stable.

The construction of this model is described in two papers by Wilensky & Reisman referenced below.

## HOW TO USE IT

1. Set the GRASS? switch to TRUE to include grass in the model, or to FALSE to only include wolves (red) and sheep (white).
2. Adjust the slider parameters (see below), or use the default settings.
3. Press the SETUP button.
4. Press the GO button to begin the simulation.
5. Look at the monitors to see the current population sizes
6. Look at the POPULATIONS plot to watch the populations fluctuate over time

Parameters:
INITIAL-NUMBER-SHEEP: The initial size of sheep population
INITIAL-NUMBER-WOLVES: The initial size of wolf population
SHEEP-GAIN-FROM-FOOD: The amount of energy sheep get for every grass patch eaten
WOLF-GAIN-FROM-FOOD: The amount of energy wolves get for every sheep eaten
SHEEP-REPRODUCE: The probability of a sheep reproducing at each time step
WOLF-REPRODUCE: The probability of a wolf reproducing at each time step
GRASS?: Whether or not to include grass in the model
GRASS-REGROWTH-TIME: How long it takes for grass to regrow once it is eaten
SHOW-ENERGY?: Whether or not to show the energy of each animal as a number

Notes:
- one unit of energy is deducted for every step a wolf takes
- when grass is included, one unit of energy is deducted for every step a sheep takes

## THINGS TO NOTICE

When grass is not included, watch as the sheep and wolf populations fluctuate. Notice that increases and decreases in the sizes of each population are related. In what way are they related? What eventually happens?

Once grass is added, notice the green line added to the population plot representing fluctuations in the amount of grass. How do the sizes of the three populations appear to relate now? What is the explanation for this?

Why do you suppose that some variations of the model might be stable while others are not?

## THINGS TO TRY

Try adjusting the parameters under various settings. How sensitive is the stability of the model to the particular parameters?

Can you find any parameters that generate a stable ecosystem that includes only wolves and sheep?

Try setting GRASS? to TRUE, but setting INITIAL-NUMBER-WOLVES to 0. This gives a stable ecosystem with only sheep and grass. Why might this be stable while the variation with only sheep and wolves is not?

Notice that under stable settings, the populations tend to fluctuate at a predictable pace. Can you find any parameters that will speed this up or slow it down?

Try changing the reproduction rules -- for example, what would happen if reproduction depended on energy rather than being determined by a fixed probability?

## EXTENDING THE MODEL

There are a number ways to alter the model so that it will be stable with only wolves and sheep (no grass). Some will require new elements to be coded in or existing behaviors to be changed. Can you develop such a version?

## NETLOGO FEATURES

Note the use of breeds to model two different kinds of "turtles": wolves and sheep. Note the use of patches to model grass.

Note use of the ONE-OF agentset reporter to select a random sheep to be eaten by a wolf.

## RELATED MODELS

Look at Rabbits Grass Weeds for another model of interacting populations with different rules.

## CREDITS AND REFERENCES

Wilensky, U. & Reisman, K. (1999). Connected Science: Learning Biology through Constructing and Testing Computational Theories -- an Embodied Modeling Approach. International Journal of Complex Systems, M. 234, pp. 1 - 12. (This model is a slightly extended version of the model described in the paper.)

Wilensky, U. & Reisman, K. (2006). Thinking like a Wolf, a Sheep or a Firefly: Learning Biology through Constructing and Testing Computational Theories -- an Embodied Modeling Approach. Cognition & Instruction, 24(2), pp. 171-209. http://ccl.northwestern.edu/papers/wolfsheep.pdf


## HOW TO CITE

If you mention this model in a publication, we ask that you include these citations for the model itself and for the NetLogo software:

* Wilensky, U. (1997).  NetLogo Wolf Sheep Predation model.  http://ccl.northwestern.edu/netlogo/models/WolfSheepPredation.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1997 Uri Wilensky.

![CC BY-NC-SA 3.0](http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2000.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

antenna
false
0
Circle -7500403 true true 135 0 30
Polygon -7500403 true true 165 30 255 270 240 270 150 30 165 15 165 30
Polygon -7500403 true true 150 30 75 270 60 270 135 30 150 15 150 30
Polygon -7500403 true true 135 60 165 75 180 90 120 135 210 165 90 210 240 240 225 225 135 210 210 180 195 150 150 135 180 105 180 60 135 45

ap
false
14
Polygon -7500403 true false 150 210 15 150 150 90 285 150
Line -16777216 true 150 210 15 150
Line -16777216 true 150 210 285 150
Polygon -7500403 true false 15 150 150 210 150 285 15 225 15 150
Polygon -7500403 true false 150 210 285 150 285 225 150 285 150 210
Polygon -7500403 true false 135 15 150 15 150 105 135 105 135 15
Line -16777216 true 150 210 150 285
Line -16777216 true 135 15 135 105
Polygon -16777216 true true 30 180 135 225 135 255 30 210 30 180

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

bstation
true
0
Rectangle -7500403 true true 144 0 159 105
Rectangle -6459832 true false 195 45 255 255
Rectangle -16777216 false false 195 45 255 255
Rectangle -6459832 true false 45 45 105 255
Rectangle -16777216 false false 45 45 105 255
Line -16777216 false 45 75 255 75
Line -16777216 false 45 105 255 105
Line -16777216 false 45 60 255 60
Line -16777216 false 45 240 255 240
Line -16777216 false 45 225 255 225
Line -16777216 false 45 195 255 195
Line -16777216 false 45 150 255 150
Polygon -7500403 true true 90 60 60 90 60 240 120 255 180 255 240 240 240 90 210 60
Rectangle -16777216 false false 135 105 165 120
Polygon -16777216 false false 135 120 105 135 101 181 120 225 149 234 180 225 199 182 195 135 165 120
Polygon -16777216 false false 240 90 210 60 211 246 240 240
Polygon -16777216 false false 60 90 90 60 89 246 60 240
Polygon -16777216 false false 89 247 116 254 183 255 211 246 211 237 89 236
Rectangle -16777216 false false 90 60 210 90
Rectangle -16777216 false false 143 0 158 105

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

caterpillar
true
0
Polygon -7500403 true true 165 210 165 225 135 255 105 270 90 270 75 255 75 240 90 210 120 195 135 165 165 135 165 105 150 75 150 60 135 60 120 45 120 30 135 15 150 15 180 30 180 45 195 45 210 60 225 105 225 135 210 150 210 165 195 195 180 210
Line -16777216 false 135 255 90 210
Line -16777216 false 165 225 120 195
Line -16777216 false 135 165 180 210
Line -16777216 false 150 150 201 186
Line -16777216 false 165 135 210 150
Line -16777216 false 165 120 225 120
Line -16777216 false 165 106 221 90
Line -16777216 false 157 91 210 60
Line -16777216 false 150 60 180 45
Line -16777216 false 120 30 96 26
Line -16777216 false 124 0 135 15

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cloud
false
0
Circle -7500403 true true 13 118 94
Circle -7500403 true true 86 101 127
Circle -7500403 true true 51 51 108
Circle -7500403 true true 118 43 95
Circle -7500403 true true 158 68 134

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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

smd
false
0
Polygon -7500403 true true 75 0 60 15 60 285 75 300 225 300 240 285 240 15 225 0 75 0
Rectangle -16777216 true false 120 15 180 30
Circle -16777216 true false 129 249 42
Rectangle -16777216 true false 90 45 210 240

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

tank
true
0
Rectangle -7500403 true true 144 0 159 105
Rectangle -6459832 true false 195 45 255 255
Rectangle -16777216 false false 195 45 255 255
Rectangle -6459832 true false 45 45 105 255
Rectangle -16777216 false false 45 45 105 255
Line -16777216 false 45 75 255 75
Line -16777216 false 45 105 255 105
Line -16777216 false 45 60 255 60
Line -16777216 false 45 240 255 240
Line -16777216 false 45 225 255 225
Line -16777216 false 45 195 255 195
Line -16777216 false 45 150 255 150
Polygon -7500403 true true 90 60 60 90 60 240 120 255 180 255 240 240 240 90 210 60
Rectangle -16777216 false false 135 105 165 120
Polygon -16777216 false false 135 120 105 135 101 181 120 225 149 234 180 225 199 182 195 135 165 120
Polygon -16777216 false false 240 90 210 60 211 246 240 240
Polygon -16777216 false false 60 90 90 60 89 246 60 240
Polygon -16777216 false false 89 247 116 254 183 255 211 246 211 237 89 236
Rectangle -16777216 false false 90 60 210 90
Rectangle -16777216 false false 143 0 158 105

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.1.0
@#$#@#$#@
setup
set grass? true
repeat 75 [ go ]
@#$#@#$#@
@#$#@#$#@
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
