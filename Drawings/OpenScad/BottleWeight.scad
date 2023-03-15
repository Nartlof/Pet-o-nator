/*
This file is part of the Pet-o-Nator project
Contant: Parts for weight used with the bottle cutter
Autor: Carlos Eduardo Foltran
Last update 2023-03-14
*/

use <Library\threads.scad>

TotalWeight = 300;           // Target weight of filling material
FillingDensityG_Cm3 = 11.34; // Density of lead in g/cm3
PlasticDensityG_Cm3 = 1.34;  // Density of PET. Change for another plastic
WallThickness = 2;
InternalDiameter = 29.5; // Diameter of a soda bottle thread
Height = 20.3713;
Inlid = 0.5;
// Apparent density of the filling compared to real material
ApparentDensity = 0.63; // Use 1 if the density refers to loose material aready
// This figure refers to loose spheres of lead

ScrewDiamenter = 2;

CoreHeight = Height - 2 * WallThickness;
CoreInnerRadius = InternalDiameter / 2 + WallThickness;

// Calculating appatent density of the filling in g/mm3
FillingDensity = ApparentDensity * FillingDensityG_Cm3 / 1000;

// Calculating the width of the internal core

CoreWidth = (sqrt(CoreHeight * (CoreHeight * CoreInnerRadius ^
                                2 + TotalWeight / (FillingDensity * PI))) -
             CoreHeight * CoreInnerRadius) /
            CoreHeight;

Width = CoreWidth + 2 * WallThickness;

echo("CoreHeight", CoreHeight);
echo("CoreWith:", CoreWidth);

Gap = .25;

$fa = ($preview) ? $fa : 1;
$fs = ($preview) ? $fs : .2;

module BottleThread(d = 27.43, h = 20) {
  translate([ 0, 0, -1 ]) metric_thread(
      diameter = d, pitch = 3.18, length = h + 2, internal = true, n_starts = 1,
      thread_size = -1, groove = false, square = false, rectangle = 0,
      angle = 30, taper = 0, leadin = 0, leadfac = 1.0, test = $preview);
}

module MainBody() {
  difference() {
    cylinder(h = Height - WallThickness,
             r = CoreInnerRadius + CoreWidth + WallThickness, center = false);
    translate(v = [ 0, 0, WallThickness ]) difference() {
      cylinder(h = CoreHeight + 1, r = CoreInnerRadius + CoreWidth,
               center = false);
      cylinder(h = CoreHeight + 1, r = CoreInnerRadius, center = false);
    }
  }
}

module ScrewPosition() {
  for (i = [ 0, 90, 180, 270 ]) {
    rotate([ 0, 0, i ]) {
      for (j = [ -1, 1 ]) {
        translate(v = [
          CoreInnerRadius + CoreWidth / 2 +
              j * (-CoreWidth / 2 + ScrewDiamenter / 2),
          0, 0
        ]) children();
      }
    }
  }
}

module CupLid(Lid = false) {
  rotate(Lid ? [ 180, 0, 0 ] : [ 0, 0, 0 ])
      translate(v = [ 0, 0, (Lid ? -Height : 0) ])

          difference() {
    if (Lid) {
      translate(v = [ 0, 0, Height - WallThickness ]) {
        cylinder(h = WallThickness,
                 r = CoreInnerRadius + CoreWidth + WallThickness,
                 center = false);
        translate(v = [ 0, 0, -Inlid ]) difference() {
          cylinder(h = Inlid, r = CoreInnerRadius + CoreWidth - Gap,
                   center = false);
          translate(v = [ 0, 0, -.5 ]) {
            cylinder(h = Inlid + 1, r = CoreInnerRadius + Gap, center = false);
            ScrewPosition() cylinder(
                h = Inlid + 1, d = ScrewDiamenter + 2 * WallThickness + 2 * Gap,
                center = false);
          }
        }
      }
    } else {
      union() {
        MainBody();
        ScrewPosition()
            cylinder(h = Height - WallThickness,
                     d = ScrewDiamenter + 2 * WallThickness, center = false);
      }
    }
    ScrewPosition()
        cylinder(h = Height + 1, d = ScrewDiamenter, center = false);
    BottleThread(d = InternalDiameter, h = Height);
  }
}

CupLid(Lid = true);