/*
This file is part of the Pet-o-Nator project
Contant: Iversed Spool for loose filament
Autor: Carlos Eduardo Foltran
Last update 2023-03-05
*/

SpoolOuterDiameter = 200;
SpoolWidht = 50;
SpoolWallThickness = 3;
SpoolScrewDiameter = 2;
SpoolScrewLenght = 15;

Gap = .25;

$fa = ($preview) ? $fa : 1;
$fs = ($preview) ? $fs : .2;

module Profile() {
  translate([ 0, SpoolWidht / 2 ]) {
    translate([ SpoolWidht / 2, 0, 0 ]) difference() {
      circle(d = SpoolWidht);
      circle(d = SpoolWidht - 2 * SpoolWallThickness);
      for (i = [ 0, 90, 180 ])
        rotate([ 0, 0, i ])
            square(size = SpoolWidht + SpoolWallThickness, center = false);
    }
    translate([ 0, -SpoolWidht / 2, 0 ])
        square(size = [ SpoolWidht / 2, SpoolWallThickness ], center = false);
    translate([ 0, -(SpoolWidht - SpoolWallThickness) / 2, 0 ])
        circle(d = SpoolWallThickness);
  }
}

module Spool() {
  rotate_extrude(angle = 360, convexity = 2)
      translate([ (SpoolOuterDiameter - SpoolWidht) / 2, 0, 0 ]) Profile();
}

Spool();