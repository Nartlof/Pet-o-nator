/**
 * Project Name :
 *
 * Author: Carlos Eduardo Foltran
 * GitHub: https://github.com/Nartlof/Pet-o-nator
 * Thingiverse: [Thingiverse Project URL]
 * License: Creative Commons CC0 1.0 Universal (CC0 1.0)
 * Description: This is a cutter to make platc tape from PET bottles
 *
 * Date Created: 2023-02-26
 * Last Updated: 2023-09-25
 * Last Updated: 2025-03-17
 * Last Updated: 2025-03-19
 *
 * This OpenSCAD file is provided under the Creative Commons CC0 1.0 Universal (CC0 1.0) License.
 * You are free to use, modify, and distribute this design for any purpose, without any restrictions.
 *
 * For more details about the CC0 license, visit: https://creativecommons.org/publicdomain/zero/1.0/
 */

use <Library/MNut.scad>
use <Library/RoundCube.scad>

// What to render
WhatToRender = "All"; //[All, Block, Support]

// Bearing outer diameter
BearingOuterDiameter = 17;
// Bearing internal diameter
BearingInternalDiamenter = 6;
// Bearing height
BearingHeight = 6;
// Supporting washer diamenter
SupportingWasherDiameter = 18;
// Clearence for the supporting washer
SupportingWasherClearence = 2;
// Total height of supporting washer and nut
SupportingWasherHeigth = 6;
// Maximum cutting width
MaxCutting = 16;
// Screw nominal diameter
ScrewType = 6;
// Nut height
NutHeight = 5;
// Overlap of the cutting edge
BearingOverlap = 1;
// Block rounding radius
BlockRoundingRadius = 5;
// Block height
BlockHeight = 15;
FixingScrewHead = 7.5;
FixingScrewShaft = 4;
// Supporting rod
RodDiameter = 12;
RodDistance = 50;

BlockWidth = 2.5 * BearingOuterDiameter + 2 * BlockRoundingRadius + RodDistance;
BlockLenght = 1.5 * BearingOuterDiameter + 2 * BlockRoundingRadius + RodDiameter / 2;

Gap = .25;

SupportingWasherDiameterToUse = SupportingWasherDiameter + 2 * SupportingWasherClearence;

$fa = ($preview) ? $fa : 1;
$fs = ($preview) ? $fs : .2;

// Gera os furos para os parafusos de fixação do cortador
module screwPocket(Head = 7.5, Shaft = 4, Lenght = 10) {
  Transition = Head - Shaft;
  cylinder(h=Transition + 1 / 512, d1=Shaft, d2=Head, center=true);
  translate([0, 0, Transition / 2]) cylinder(h=Lenght, d=Head, center=false);
  translate([0, 0, -(Transition / 2 + Lenght)]) cylinder(h=Lenght, d=Shaft, center=false);
}

// Gera o furo para os parafusos de corte
module mainScrew() {
  MNut(M=ScrewType, Insert=0, Folga=Gap);
  cylinder(h=2 * BlockHeight + MaxCutting, d=ScrewType + 2 * Gap, center=false);
}

module block() {
  // posição dos parafusos de fixação
  xCorner = BlockWidth / 2 - BlockRoundingRadius - FixingScrewHead / 2;
  yCorner = BlockLenght / 2 - BlockRoundingRadius - FixingScrewHead / 2;
  // Calculando a posição do parafuso de suporte
  // posicionando o parafuso de suporte no vertice de um triangulo isóceles com
  // um lado igual à distância entre o centro dos rolamentos de conte e os
  // outros com lado igual à soma dos raios do rolamento e da arruela de apoio
  xScrewPosition = (BearingOuterDiameter - BearingOverlap) / 2;
  ySupporScrew = sqrt((BearingOuterDiameter + SupportingWasherDiameterToUse) ^ 2 / 4 - xScrewPosition ^ 2);
  // echo(ySupporScrew);

  difference() {
    translate(-[BlockWidth / 2, BlockLenght / 2, BlockRoundingRadius]) {
      difference() {
        roundCube([BlockWidth, BlockLenght, BlockHeight + BlockRoundingRadius], r=BlockRoundingRadius);
        cube([BlockWidth, BlockLenght, BlockRoundingRadius]);
      }
    }
    // Furos dos parafusos de fixação
    for (i = [-1, 1]) {
      for (j = [-1, 1]) {
        translate([i * xCorner, j * yCorner, BlockHeight / 2])
          screwPocket(Head=FixingScrewHead, Shaft=FixingScrewShaft, Lenght=BlockHeight);
      }
    }
    // Parafusos de corte e suporte

    translate([RodDistance / 2, 0, 0]) {
      // Parafusos de corte
      for (i = [-1, 1]) {
        translate([i * xScrewPosition, -ySupporScrew / 3, -1]) mainScrew();
      }
      // Parafuso de suporte
      translate([0, ySupporScrew * 2 / 3, -1])
        cylinder(h=2 * BlockHeight, d=ScrewType - 2 * Gap, center=false);
    }
    // Haste de apoio
    translate([-RodDistance / 2, BlockLenght / 2 - RodDiameter / 2 - BlockRoundingRadius, BlockHeight / 2])
      cylinder(d1=RodDiameter - 2 * Gap, d2=RodDiameter + 2 * Gap, h=BlockHeight + 2 * Gap, center=true);
  }
}

// Peça extra para dar altura ao rolamento mais baixo
module ScrewSupport() {
  difference() {
    Heigth = MaxCutting + SupportingWasherHeigth;
    echo(Heigth);
    LowerBearingHeight = Heigth - BearingHeight - 2 * NutHeight;
    HolesDistance = BearingOuterDiameter - BearingOverlap;
    union() {
      cylinder(h=Heigth, r=BearingOuterDiameter / 3);
      translate(v=[-HolesDistance, -BearingOuterDiameter / 3, 0])
        cube([HolesDistance, 2 * BearingOuterDiameter / 3, min(SupportingWasherHeigth, LowerBearingHeight)]);
      translate(v=[-HolesDistance, 0, 0])
        cylinder(h=LowerBearingHeight, r=BearingOuterDiameter / 3);
    }
    translate([0, 0, -.5]) {
      cylinder(h=Heigth + 1, d=ScrewType + 2 * Gap);
      translate(v=[-HolesDistance, 0, 0])
        cylinder(h=Heigth + 1, d=ScrewType + 2 * Gap);
    }
  }
}

if (WhatToRender == "All") {
  xScrewPosition = (BearingOuterDiameter - BearingOverlap) / 2;
  ySupporScrew = sqrt((BearingOuterDiameter + SupportingWasherDiameterToUse) ^ 2 / 4 - xScrewPosition ^ 2);
  translate(v=[RodDistance / 2 + xScrewPosition, -ySupporScrew / 3, BlockHeight]) color(c="blue", alpha=1.0)
      ScrewSupport();
  block();
}
if (WhatToRender == "Block") {
  block();
} else if (WhatToRender == "Support") {
  ScrewSupport();
}

// Modulos para MAKE

module BottleCutterLeftHand() // make me
{
  block();
}

module BottleCutterRigthHand() // make me
{
  mirror(v=[0, 1, 0]) block();
}

module BottleCutterScrewSupport() // make me
{
  ScrewSupport();
}
