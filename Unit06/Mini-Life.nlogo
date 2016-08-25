breed [cells cell]
cells-own [
  live?
]

to startup setup end
to setup
  no-display clear-all 
  set-default-shape cells "circle" 
  ask patches
    [set pcolor 6.7
     sprout-cells 1 [set size 0.8 set color white]]
  reset-ticks display
end

to randomize
  no-display reset-ticks
  ask cells [set color white set label ""]
  ask n-of round (count cells * percent-black / 100)
      cells [set color black]
  display
end

to edit 
;  if ticks != int ticks [go]  ;; start on a whole step
  if mouse-inside? and mouse-down?              ;; when clicked,
    [ask cells-on patch mouse-xcor mouse-ycor   ;; toggle color
        [set color ifelse-value (color = black) [white] [black]]
     wait 0.16 display]
end

to go
  no-display
  ask cells [count-black-nbrs]  ;; first all cells count neighbors,
  ask cells [change-color]     ;; and only then do they change color.
  tick
  display     
end

to count-black-nbrs             ;; mark only the cells with 'just enough' neighbors
  let n count (cells-on neighbors) with [color = black]
  ifelse (n = 3 or (color = black and n = 2)) [set live? true] [set live? false];; 'live' next generation
end

to change-color
  set color ifelse-value (live?) [black] [white]
end
     
@#$#@#$#@
GRAPHICS-WINDOW
199
13
605
440
16
16
12.0
1
16
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
generations
30.0

BUTTON
13
93
145
126
NIL
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
13
270
145
303
NIL
edit
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
16
358
79
391
NIL
go
NIL
1
T
OBSERVER
NIL
1
NIL
NIL
1

BUTTON
85
358
148
391
NIL
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

TEXTBOX
15
10
106
36
Mini-Life
18
95.0
1

SLIDER
13
155
145
188
percent-black
percent-black
0
100
12
1
1
%
HORIZONTAL

BUTTON
14
194
146
227
NIL
randomize
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
14
38
145
66
Conway's Game of Life on a finite grid.
11
5.0
1

TEXTBOX
21
73
140
91
Turn all cells white:
11
5.0
1

TEXTBOX
20
138
148
156
Turn some cells black:
11
5.0
1

TEXTBOX
20
239
149
267
Click cells to toggle\nbetween white & black:
11
5.0
1

TEXTBOX
21
309
152
351
Compute new 'generations' of cell color patterns:
11
5.0
1

@#$#@#$#@
## Conway's Game of Life, only smaller
This is a simplified version of what is probably the most famous cellular automaton, invented by Cambridge mathematician John H. Conway around 1970. Unlike the _real_ Game of Life, which takes place on an infinite plane, this version only supports a fixed number of cells. By default, the 'world' grid is wrapped into a torus shape.

## How it works
An _additive_ cellular automaton rule counts the number of neighborhood cells in a particular state. The rule which Conway defined is an additive rule for cells with two states (here, "black" and "white", or "live" and "dead"). These cells inhabit a square grid, where a cell's neighborhood includes its eight horizontal, vertical, and diagonal neighbors.

> Where _n_ is the **number of black cells** in the cell's outer 8-neighborhood:
> 
>    A black cell remains black on the next step
>    only if _n_ = 2 or _n_ = 3, otherwise becoming white;
>
>   A white cell becomes black on the next step
>    only if _n_ = 3, otherwise remaining white

This model is a fairly simple and direct implementation in NetLogo, using round turtles for cells. It includes rudimentary pattern editing and randomization features, but it is mostly intended to be easy to use and easy to understand, rather than fast or featureful.

## Some basic questions to get started:
Try a few simple initial patterns of cells. How many generations does it take before they stabilize into a 'still life'? Are there any initial patterns which never become stable or settle into an oscillating _cycle_? Can you find a cyclic pattern which moves across the grid? Can you find a small initial pattern which grows to fill the entire space? Why do we need two half-steps to compute one generation --- what would happen if cells changed their colors immediately upon counting their neighbors?

## Need more room?
You can increase the NetLogo 'world size', and the model will still work without being wrapped around at the edges. But Complexity Explorer also provides a full-sized Game of Life implementation, with more features and more background information. You'll probably want to move up to that model when you feel like you understand this one.

## CREDITS AND REFERENCES

This model is part of the Cellular Automata series of the Complexity Explorer project.  
 
Main Author:  Max Orhai

Contributions from: Melanie Mitchell

Netlogo:  Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.


## HOW TO CITE

If you use this model, please cite it as: "Mini-Life" model, Complexity Explorer project, http://complexityexplorer.org

## COPYRIGHT AND LICENSE

Copyright 2013 Santa Fe Institute.  

This model is licensed by the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 License ( http://creativecommons.org/licenses/by-nc-nd/3.0/ ). This states that you may copy, distribute, and transmit the work under the condition that you give attribution to ComplexityExplorer.org, and your use is for non-commercial purposes.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

circle
false
0
Circle -7500403 true true 0 0 300

outlined circle
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 false false 0 0 300

@#$#@#$#@
NetLogo 5.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
