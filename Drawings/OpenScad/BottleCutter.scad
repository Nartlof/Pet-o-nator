/*
This file is part of the Pet-o-Nator project
Contant: Parts for the bottle cutter
Autor: Carlos Eduardo Foltran
Last update 2023-02-26
*/

use <Library\MNut.scad>
use <Library\RoundCube.scad>

// Bearing outer diameter
BearingOuterDiameter = 17;
// Bearing internal diameter
BearingInternalDiamenter = 6;
// Bearing height
BearingHeight = 6;
// Screw nominal diameter
ScrewType = 6;
// Overlap of the cutting edge
BearingOverlap = 1;
// Block rounding radius
BlockRoundingRadius = 5;
// Block height
BlockHeight = 15;
FixingScrewHead = 7.5;
FixingScrewShaft = 4;

BlockWidth = 2.5 * BearingOuterDiameter + 2 * BlockRoundingRadius;
BlockLenght = 1.5 * BearingOuterDiameter + 2 * BlockRoundingRadius;

Gap = .25;

$fa = ($preview) ? $fa : 1;
$fs = ($preview) ? $fs : .2;

module screwPocket(Head = 7.5, Shaft = 4, Lenght = 10) {
  Transition = Head - Shaft;
  cylinder(h = Transition + 1 / 512, d1 = Shaft, d2 = Head, center = true);
  translate([ 0, 0, Transition / 2 ])
      cylinder(h = Lenght, d = Head, center = false);
  translate([ 0, 0, -(Transition / 2 + Lenght) ])
      cylinder(h = Lenght, d = Shaft, center = false);
}

module mainScrew() {
  MNut(M = ScrewType, Insert = 0, Folga = Gap);
  cylinder(h = 2 * BlockHeight, d = ScrewType + 2 * Gap, center = false);
}

module block() {
  difference() {
    translate(-[ BlockWidth / 2, BlockLenght / 2, BlockRoundingRadius ]) {
      difference() {
        roundCube(
            [ BlockWidth, BlockLenght, BlockHeight + BlockRoundingRadius ],
            r = BlockRoundingRadius);
        cube([ BlockWidth, BlockLenght, BlockRoundingRadius ]);
      }
    }
    xCorner = BlockWidth / 2 - BlockRoundingRadius - FixingScrewHead / 2;
    yCorner = BlockLenght / 2 - BlockRoundingRadius - FixingScrewHead / 2;
    xScrewPosition = (BearingOuterDiameter - BearingOverlap) / 2;
    // posicionando o parafuso de suporte no vertice de um trianguli equilátero
    ySupporScrew = xScrewPosition * sqrt(3);
    for (i = [ -1, 1 ]) {
      for (j = [ -1, 1 ]) {
        translate([ i * xCorner, j * yCorner, BlockHeight / 2 ])
            screwPocket(Head = FixingScrewHead, Shaft = FixingScrewShaft,
                        Lenght = BlockHeight);
      }
      translate([ i * xScrewPosition, -ySupporScrew / 3, -1 ]) mainScrew();
    }
    // Parafuso de suporte
    translate([ 0, ySupporScrew * 2 / 3, -1 ])
        cylinder(h = 2 * BlockHeight, d = ScrewType - 2 * Gap, center = false);
  }
}

block();
// mainScrew();