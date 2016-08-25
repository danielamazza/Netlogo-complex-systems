turtles-own [new?] ;if the turtle is newly hatched or not

globals [ 
  angle          ;the angle that the self-similar pieces are rotated to make the next image
  scale-factor   ;the scalar that the initial image is reduced by (i.e. 1/2 or 1/3, not 2 or 3)
  initial-length ;the initial length of the fractal's line segments
  pen-down?      ;whether or not to have the pen down while drawing
  memory         ;the l-system command string of the fractal
  n-rep          ;number of self-similar copies generated from each line segment
  len            ;current length of the line segments in the fractal
  cd?            ;whether or not to clear the display after each iteration
  fractal-length ;sum of all line segments in the fractal at that iteration
  fractal-name
  current-iteration ; current level at which fractal is being displayed
]

to reset
  clear-all
  reset-ticks
  set current-iteration 0
  set initial-length 100
  set len initial-length 
  set memory "" 
  set cd? true
  ask patch 0 0  [sprout 1 
    [
      pd
      set pen-size 2
      set new? false
      set color green
      set heading 0
    ]
  ]
  tick
  ask turtles [ hide-turtle ]
end

to iterate
  set current-iteration current-iteration + 1
  if cd? [cd]
  if fractal-name = "kochp" [
    ask turtles[
    ifelse(pycor > -100)[pu setxy (xcor) (ycor - 96) pd] ;moving the turtle down 100 patches so successive iterations are visible
    [stop]
    ]
  ]
  set len len * scale-factor
  ask turtles with [not new?]
  [die]
  ask turtles with [new?] 
  [set new? false]
  ask turtles with [not new? ]  [ run memory]
  ask turtles [ hide-turtle ]
  calc-length
  tick
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;Examples;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to dragon-curve
 reset
 set fractal-length 1
 set fractal-name "dragon"
 set n-rep 2
 ask turtles[
   set pen-size 2
   pen-up
   setxy 0 -70
   pd fd 140 pu
   setxy 0 -70
   pd t
 ]
dragon "lt 45 t  pd fd  len rt 45 rt 45 pd fd  len lt 180 t "
end

to dragon [dragon-command-string]
  set angle 45
  set scale-factor 1 / sqrt(2)
  set memory (word memory "\n" dragon-command-string)
  set len len / 0.71
  tick
end

to levy-curve
  reset
  set fractal-length 1
  set fractal-name "levy"
  set n-rep 2
  set angle 45
  set scale-factor 1 / sqrt(2)
  ask turtles[
    pen-up
    setxy 0 -50
    pd fd 140 pu
    setxy 0 -50
    pd t
  ]
  levy "lt 45 t fd len rt 45 rt 45 t fd len"
end

to levy [levy-command-string]
  set len len / 0.71
  set memory (word memory "\n" levy-command-string)
  tick
end

to koch-prev
  reset
  set cd? false
  set fractal-length 1
  set fractal-name "kochp"
  set n-rep 4
  set angle 60
  set scale-factor 1 / 3
  ask turtles[
    pu
    setxy -150 190
    pd
    set heading 90
    fd 300
    pu setxy -150 190 pd t
  ]
  koch-p "t fd len left 60 t fd len right 60 right 60 t fd len left 60 t fd len"
end

to koch-p [Koch-command-string]
       set memory (word memory "\n" Koch-command-string)
       set len 300
  tick
end

to Cantor-set
  reset
  set fractal-length 1
  set fractal-name "cantor"
  set n-rep 2
  set len 100
  set cd? false
  ask turtles [
    pen-up 
    set heading 90
    setxy -150 170
    pd fd 300 pu
    setxy -150 170
    t pd
    ]
  set scale-factor 1 / 3
  Cantor "t right 90 pu fd 30 pd left 90 t fd len pu fd len pd t fd len"
end

to Cantor [Cantor-command-string]
  set memory (word memory "\n" Cantor-command-string)
  set cd? false
  set len len * 3
  tick
end

to Sierpinski-triangle
  reset
  set fractal-length "N/A"
  set fractal-name "sierpinski"
  set n-rep 3
  set len 270
  set scale-factor 1 / 2
  ask turtles [ 
    pu setxy 0 135 pd
    ]
  Sierpinski "t fd len / 2 t fd len / 2 left 120 fd len left 120 fd len / 2 left 120 t right 120 fd len / 2"
end

to Sierpinski [Sierpinski-command-string]
  ifelse ticks = 1
  [
    ask turtles with [not new?] [set heading 210 run Sierpinski-command-string]
    set memory (word memory "\n" Sierpinski-command-string)
  ]
  [
    cd
    set len len / 2
    ask turtles with [not new?] [die]
    ask turtles with [new?]
    [
      set new? false
    ]
    ask turtles with [not new?] [run memory]
  ]
  tick
end

to fractal-tree
  reset
  set fractal-length 1
  set fractal-name "tree"
  set cd? false
  set n-rep 2
  set scale-factor 1 / 2
  set len 100
  ask turtles[
    pu
    setxy 0 -60
    pd fd 100 t
  ]
  set len len * 1 / 2
  tree "right 15 fd len  t rt 180 pu fd len pd rt 180 lt 40 fd len t"
end

to tree [tree-command-string]
  set cd? false
  set len len * 2
  set memory (word memory "\n" tree-command-string)
  tick
end
   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;fractal commands;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to t
  hatch 1 [set new? true]
end

to calc-length
  if fractal-name = "tree" [set fractal-length ticks]
  if fractal-name = "sierpinski" [set fractal-length "N/A"]
  if fractal-name = "dragon" or fractal-name = "levy" [set fractal-length fractal-length * sqrt(2)]
  if fractal-name = "kochp" [ set fractal-length fractal-length * 4 / 3]
  if fractal-name = "cantor" [set fractal-length fractal-length * (2 / 3)]
end
@#$#@#$#@
GRAPHICS-WINDOW
262
10
677
448
202
203
1.0
1
10
1
1
1
0
0
0
1
-202
202
-203
203
0
0
1
ticks
30.0

BUTTON
60
271
188
328
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
4
184
118
217
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

TEXTBOX
4
10
214
54
Examples of Fractals
18
95.0
1

TEXTBOX
7
126
157
148
Examples
16
0.0
1

BUTTON
4
216
118
249
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

MONITOR
684
73
741
118
N
n-rep
0
1
11

MONITOR
685
131
742
176
M
1 / scale-factor
3
1
11

MONITOR
686
189
900
234
Hausdorff dimension = log(N)/log(M)
log(n-rep) 10 / log(1 / scale-factor) 10
3
1
11

TEXTBOX
683
14
833
36
Fractal Dimension
16
0.0
1

BUTTON
118
152
247
186
Cantor Set
Cantor-set
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
118
184
247
217
Sierpinski Triangle
Sierpinski-triangle
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
118
216
247
249
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
751
73
936
114
N is the number of smaller copies of the previous iteration generated at each new iteration.
11
0.0
1

TEXTBOX
751
130
901
175
M is the factor by which each line segment shrinks at the next iteration.
11
0.0
1

TEXTBOX
684
39
973
81
With each iteration, a fractal uses a number of smaller copies of itself to construct a new pattern.
11
0.0
1

MONITOR
687
272
801
317
Length of fractal
fractal-length
4
1
11

BUTTON
4
152
118
185
Koch Curve
koch-prev
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
806
265
1008
321
Fractal length is the sum of segment lengths at the current iteration. Assume initial line segment is of length 1.
11
0.0
1

TEXTBOX
5
50
250
121
First click on an example to see the fractal generator.  Then repeatedly click \"Iterate\" to see the next iteration. 
13
0.0
1

PLOT
687
327
1004
447
Fractal Length over Time
Time
Length
0.0
10.0
0.0
5.0
true
false
"" ""
PENS
"default" 1.0 0 -10899396 true "" "if(fractal-length != \"N/A\" and ticks > 1) [plot fractal-length]"

TEXTBOX
686
246
836
266
Fractal Length
16
0.0
1

MONITOR
60
342
188
387
Current Iteration
current-iteration
17
1
11

@#$#@#$#@
## WHAT IS IT?
Example Fractals is a model that illustrates how fractals work. In this model, you can experiment with a variety of different fractal patterns to see how fractals recursively create smaller copies to produce larger patterns which have increasing length. Additionally, the fractional dimension of fractals is showcased, along with the formula for Hausdorff dimension.

## HOW IT WORKS

In the interface window, click on one of the examples.  This will display the "generator" (initial pattern) for the chosen fractal.  Then click repeatedly on "Iterate" to show each successive iteration of the fractal.  For example, each iteration of the Koch Curve produces four new copies, each three times smaller than the original, which lie on the original four segments. The number of copies generated at each iteration is denoted N and the shrinking factor for each segment is denoted M. The Hausdorff dimension is defined as log(N)/log(M). Note that the base of this log is irrelevant, which is explained further below. One of the key features of fractals is that they can have fractional dimension. Additionally, the length of a fractal (the sum of the length of all segments) can increase with each iteration.  For example, in the Koch Curve, a straight line between two points (by definition the shortest possible length) is continually replaced with a more indirect, longer path.

## THINGS TO NOTICE

Look for how the shrinking factor, M, and the number of copies, N, play into the pattern that emerges with successive iterations. You can also observe the increase in fractal length that occurs with each step: try to find a pattern between the fractal's properties (N and M) and the successive changes in curve length.

### A NOTE ON LOGS

The equation for the Hausdorff dimension is log(N)/log(M). Note that this follows the change of base formula:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;log<sub>a</sub>x = log<sub>b</sub>x / log<sub>b</sub>a
where the value of b, the base of the log in the fraction, can be any real value. Thus, you could also write the equation for the Hausdorff dimension as:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;d = log<sub>M</sub>N
This is the reason that the base of the log doesn't matter in the fraction. In this code, a common log (base 10) is used, although any base would give the same result.

## CREDITS AND REFERENCES

This model is part of the Fractals series of the Complexity Explorer project.  
 
Main Author:  Vicki Niu

Contributions from:  John Driscoll, Melanie Mitchell

Some of the code for this model was adapted from the L-System Fractals model in the Netlogo Models Library:  Wilensky, U. (2001).  NetLogo L-System Fractals model.  http://ccl.northwestern.edu/netlogo/models/L-SystemFractals.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Netlogo:  Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.


## HOW TO CITE

If you use this model, please cite it as: "Examples of Fractals" model, Complexity Explorer project, http://complexityexplorer.org

## COPYRIGHT AND LICENSE

Copyright 2013 Santa Fe Institute.  

This model is licensed by the Creative Commons Attribution-NonCommercial-ShareAlike   License ( http://creativecommons.org/licenses/by-nc-sa/4.0/ ). This states that you may copy, distribute, and transmit the work under the condition that you give attribution to ComplexityExplorer.org, and your use is for non-commercial purposes.
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
