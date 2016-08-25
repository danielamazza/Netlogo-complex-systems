turtles-own [new?] ;whether or not a turtle is newly hatched
globals [ 
  len       ;length of the line segments to be drawn in the current iteration
  memory    ;the string representing the L-system ("memory" of the last iteration)
  fractal-name ;name of the fractal
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; Setup Procedures ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to setup 
 ;clearing world 
 ca
 reset-ticks
 
 ;initializing variables
 set len initial-length
 set memory ""
 
 ;hatching first turtle at the initial position & heading 
 ask patch x_i y_i  [sprout 1 
   [
   pd
   set pen-size 2
   set new? false
   set size 4
   set color green
   set heading head_i
  ]
 ]
 tick
end

;Iterating the function by asking the old turtles to die, and having the
;new turtles run the L-system. This procedure also re-scales the line segments
;and adjusts the turtle sizes (for display purposes)
to iterate
  if clear-display? [cd] ;some fractals require the previous iterations to be deleted
  set len len * scale-factor ;rescaling segment lengths
  set scale-factor precision scale-factor 2 ;truncating scale-factor for display purposes
  ask turtles with [not new?] [die] ;clearing turtles from previous iteration
  ask turtles with [new?] 
  [ set new? false     ;these turtles become "old", also turning green
    set color green
    ifelse (ticks >= 3) ;This is just to ensure that the turtles don't obstruct view of the fractal
    [hide-turtle]
    [set size size * 0.6]
    pd
    run memory ;having turtles iterate the L-system
   ]
  copy-memory ;copying the command string in memory to the L-system input box so the user can view and modify it
  tick
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; L-system procedures ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;The following definitions are expressing the grammar and syntax
;of the L-systems that we will be using to create the fractals.
;They mimic already existing function (-fd- vs fd), but are used
;for the buttons on the interface so that we may specify certain
;lengths by which to move forward with the sliders
;You can look at the command strings to get an idea of how these
;procedures operate, or look into the code, paying attention to the
;procedure arguments to understand how the commands fit together!

;Moving forward by length len
to -fd-
  #fd-len " pd fd "
end

to #fd-len [#fd-len-command-string]
    set #fd-len-command-string (word #fd-len-command-string "len") ;setting the command string to "pd fd len"
    ask turtles with [not new?] [run #fd-len-command-string]
    set memory (word memory  #fd-len-command-string)  ;writing out the operation to memory
end

;Turning right by "angle" degrees
to -rt-
  #right " rt " 
end

to #right [#right-command-string]
  set #right-command-string (word #right-command-string angle)
  ask turtles with [not new?] [run #right-command-string]
  set memory (word memory  #right-command-string) 
end

;Turning left by "angle" degrees
to -lt-
  #left " lt " 
end

to #left [#left-command-string]
  set angle angle
  set #left-command-string (word #left-command-string angle)
  ask turtles with [not new?] [run #left-command-string]
  set memory (word memory  #left-command-string) 
end
 
to -t-
  #hatch " t "
end

;Hatching a turtle 
to #hatch [#hatch-command-string]  
  ifelse(count turtles = 0)
  [
    setup ;If this is the first turtle being hatched, set up in initial position
  ]
  [
    ask turtles with [not new?] [run #hatch-command-string] ;Otherwise, hatch a "new" turtle at the old turtle's location
    set memory (word memory  #hatch-command-string) 
    clear-output
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; "Create Your Own" Procedures;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;These procedures are those located on the right-hand side
;and allow the user to easily create/modify an L-system, then
;setup and run it

;Running the L-system, setting the initial position and
;establishing the first iteration
to run-system
  ;First, setup the initial turtle
  ;setup
  set memory (word memory "\n" L-system)
  ask turtles[
    pu
    setxy x_i y_i
    set heading head_i
    pd
    run memory
;    pd
;    fd initial-length  ;/ scale-factor
    if (clear-display?)[pu setxy x_i y_i pd]
    ;t
  ]
  
  clear-output
  set len initial-length
  tick
end

;Iterate the L-system
;Set memory to L-system (opposite of copy-memory), then run the
;ITERATE procedure, which will ask the turtles to run MEMORY
to iterate-system
  set memory L-system
  iterate
end

;Setting the L-system input to the value of memory
;Allows the user to see & modify the L-system last run
to copy-memory
  set L-system memory
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Examples ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;These procedures run the preset examples

to Koch-curve
  ;Setting up the initial position
  set initial-length 18
  set x_i precision (-1.5 * initial-length) 0
  set y_i 0
  set head_i 90
  setup
  
  ;Setting up fractal-specific variables to be reflected in Interface tab
  set clear-display? true
  set len len * 3
  set angle 60
  set scale-factor 0.33
  
  ask turtles[
    set pen-size 2
    pen-down
    fd len
    pu
    setxy x_i y_i
    pd
    t
  ]
  update "t  fd len  lt 60  t  fd len  rt 120 t  fd len  lt 60  t  fd len" 
end

to dragon-curve
  ;Updating the initial position, then creating turtle (SETUP)
  set initial-length 25
  set x_i 0
  set y_i precision (initial-length * -0.71) 0
  set head_i 0
  setup

  ;Setting the intial variables
  set len len * 1.414
  set clear-display? true
  set fractal-name "dragon"
  set angle 45
  set scale-factor 0.71  

  ;Drawing "base case" as straigt line
  ask turtles[
    set pen-size 2
    pen-down
    fd len
    pu
    setxy 0 y_i
    pd
    t
  ]
  update "lt 45  t  pd  fd len  rt 45  rt 45  pd  fd len  lt 180  t "
end

to levy-curve
  ;Updating initial position of turtle, then creating turtle (SETUP)
  set initial-length 18
  set x_i 0
  set y_i precision (initial-length * -0.71) 0
  set head_i 0
  setup
  
  ;Initializing fractal-specific variables
  set len len * 1.414
  set clear-display? true
  set fractal-name "levy"
  set angle 45
  set scale-factor 0.71
  
  ;Drawing "base case" straight line
  ask turtles[
    pd
    fd len
    pu
    setxy x_i y_i
    pd
    t
  ]
  update "lt 45  t  fd len  rt 45  rt 45  t  fd len"
end

to fractal-tree
  ;Setting turtle's initial position, then placing turtle
  set x_i 0
  set y_i -15
  set head_i 0
  set initial-length 16
  setup
  
  ;Setting fractal-specific variables
  set clear-display? false
  set scale-factor 1 / 2
  set len initial-length ;* 2
  set angle 15
  
  ;Drawing "base case" straigt line
  ask turtles[
    pd
    fd len
    t
  ]
  update "rt 15 fd len t rt 180 pu fd len pd rt 180 lt 40 fd len t"
  ;tree "rt 15 fd len t rt 180 pu fd len pd rt 180 lt 40 fd len t"
end

to cantor
  set x_i -20
  set y_i 0
  set head_i 90
  set initial-length 15
  setup
  
  set len 45 
  set clear-display? true
  set scale-factor 0.33
  set angle 0
  
  ask turtles[
    pd fd len pu setxy x_i y_i t pd]
  update "pd t fd len pu fd len pd t fd len"
end

to sierpinski
  set x_i -15
  set y_i -15
  set head_i 90
  set initial-length 30
  setup
  
  set clear-display? true
  set scale-factor 1 / 2
  set len initial-length
  set angle 60
  
  update "t fd len / 2 t fd len / 2 left 120 fd len left 120 fd len / 2 left 120 t right 120 fd len / 2"
  ask turtles [ run memory]
end

;Updating the memory with the example command string, then copying that
;L-system into the input box
to update [command-string]
  set memory (word memory "\n" command-string)
  copy-memory
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Fractal Commands ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Hatch
to t
  hatch 1 [set new? true set color yellow]
end

;Die
to d
ask turtles with [not new?][ die ]
end
@#$#@#$#@
GRAPHICS-WINDOW
294
10
670
407
30
30
6.0
1
10
1
1
1
0
0
0
1
-30
30
-30
30
0
0
1
ticks
30.0

SLIDER
845
137
1008
170
scale-factor
scale-factor
.01
2
0.33
.01
1
NIL
HORIZONTAL

BUTTON
78
244
223
303
Iterate
iterate
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
37
126
151
159
Koch Curve
Koch-curve
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
37
158
151
191
Levy Curve
Levy-curve
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
845
72
1008
105
angle
angle
0
180
60
1
1
NIL
HORIZONTAL

SLIDER
845
104
1008
137
initial-length
initial-length
0
30
18
1
1
NIL
HORIZONTAL

TEXTBOX
42
10
170
37
L-Systems
18
95.0
1

TEXTBOX
40
102
190
124
Examples
16
0.0
1

BUTTON
37
191
151
224
Dragon Curve
dragon-curve
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
692
17
978
43
Create your own L-system fractal
16
0.0
1

INPUTBOX
692
223
1010
310
L-system
\nt  fd len  lt 60  t  fd len  rt 120 t  fd len  lt 60  t  fd len
1
0
String

BUTTON
692
310
851
343
Setup L-system
setup\nrun-system
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
851
310
1010
343
Iterate L-system
iterate-system
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
692
343
851
376
Clear world
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

SWITCH
805
182
933
215
clear-display?
clear-display?
0
1
-1000

BUTTON
151
191
265
224
Tree
fractal-tree
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
692
47
810
75
Initialization\n
13
0.0
1

TEXTBOX
43
43
251
111
First click on an example. Then repeatedly click \"Iterate\" to see the next iterations. 
11
0.0
1

MONITOR
77
318
223
363
Current Iteration
ticks - 1
17
1
11

TEXTBOX
697
383
1012
439
The L-system window shows the L-system of the fractal currently in the world. You can create an L-system by typing in the commands in the L-system window, and then clicking \"Setup L-system\" and \"Iterate L-system\". 
11
0.0
1

TEXTBOX
1023
70
1211
336
x_i : turtle's initial x-coordinate\n\ny_i : turtle's initial y-coordinate\n\nHEAD_i : turtle's initial heading\n\nANGLE : number of degrees turtle turns\n\nINITIAL-LENGTH : length of the first line segment\n\nSCALE-FACTOR : how much each line segment shrinks at each iteration\n\nCLEAR-DISPLAY? : whether or not to clear the screen of the last iteration 
11
0.0
1

BUTTON
151
158
265
191
Sierpinski Triangle
sierpinski
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
151
126
265
159
Cantor Set
cantor
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
691
72
845
105
x_i
x_i
-20
20
-27
1
1
NIL
HORIZONTAL

SLIDER
691
105
845
138
y_i
y_i
-20
20
0
1
1
NIL
HORIZONTAL

SLIDER
691
137
845
170
head_i
head_i
0
360
90
1
1
NIL
HORIZONTAL

BUTTON
851
343
1010
376
Clear L-system
set l-system \"\"
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
1021
41
1206
81
Sliders and Switches:
16
0.0
1

@#$#@#$#@
## WHAT IS IT?
L-systems is a model that illustrates how L-systems work. In this model a series of procedures are used to encode a string which is then run iteratively at different scales. Custom fractals can be made directly from the interface without the need to input code.

## HOW IT WORKS

On the left side of the interface window, click on one of the example fractals, and then on Iterate.   You will see the L-system for the example fractal in the L-system window on the right side of the interface.  Each of the example fractals has an associated command line, which directs the turtles and hatches them at spots where the fractal pattern copies itself. With each progressive iteration, the segment lengths that the turtles travel become shorter, creating smaller, self-similar features of the fractal. 

On the right side of the interface, you can use the initialization settings and the L-system window to create your own L-system fractal.  

## HOW TO USE IT

To design a fractal, enter the L-system commands in the L-system input window. Set up the initialization parameters using the sliders on the right side of the interface.  
To display the fractal you just created,  first click on "Setup L-system" and then on "Iterate L-system". Experiment with the different commands, changing the initial-length, scale-factor, and angle.

## CREDITS AND REFERENCES

This model is part of the Fractals series of the Complexity Explorer project.  
 
Main Author:  John Driscoll

Contributions from:  Vicki Niu, Melanie Mitchell

Some of the code for this model was adapted from the L-System Fractals model in the Netlogo Models Library:  Wilensky, U. (2001).  NetLogo L-System Fractals model.  http://ccl.northwestern.edu/netlogo/models/L-SystemFractals.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Netlogo:  Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## HOW TO CITE

If you use this model, please cite it as: "L-Systems" model, Complexity Explorer project, http://complexityexplorer.org

## COPYRIGHT AND LICENSE

Copyright 2013 Santa Fe Institute.
This model is licensed by the Creative Commons Attribution-NonCommercial-ShareAlike License ( http://creativecommons.org/licenses/by-nc-sa/4.0/ ). This states that you may copy, distribute, and transmit the work under the condition that you give attribution to ComplexityExplorer.org, and your use is for non-commercial purposes.
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

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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
NetLogo 5.1.0
@#$#@#$#@
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
