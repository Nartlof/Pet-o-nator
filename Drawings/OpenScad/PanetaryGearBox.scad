/*
This file is part of the Pet-o-Nator project
Contant: Planetary gear reduction
Autor: Carlos Eduardo Foltran
Last update 2023-03-19
*/

use <Library\gear\gears.scad>
PartsMinThickness = 3;
MotorDiameter = 32;
MotorAxisDiameter = 3.2;
MotorGearThickness = 6;
MotorGearTeeth = 10;
MotorGearModulus = .75;
IntermidiateGearAxis = 4.5;     // Diametro de um prego número 20
IntermidiateGearBushing = 6.35; // Diametro externo de cano de cobre de 1/8
IntermidiateGearThickness = 6;
InterGearGap = 1;
FirstGearModulus = 2;
PlanetaryGearModulus = 1;
PlanetaryGearThickness = 2 * PartsMinThickness;
NumberOfPlanets = 3;
IRSensorDiameter = 5;
MdfThickness = 9; // Espessura do MDF usado no gabinete do Pet-o-nator

// Parafuso M8 usado como eixo do carretel
ScrewAxisLength = 100;

// Estabelecendo a circunferência do carretel. Representa a quantidade de
// filamento recolhido por rotação
SpoolCircunfetence = 250;

// Estabelecendo a largura útil do carretel. O comprimento do parafuso
// eixo é calculado levando em conta este valor
SpoolUsefulWidth = 30;

// Estabelecendo a altura útil do carretel. Determina a quantidade de filamento
// recolhido.
SpoolUsefulHeight = 25;

Gap = .25;

$fa = ($preview) ? $fa : 1;
$fs = ($preview) ? $fs : .2;

// A direção da engrenagem determina o angulo da hélice
Outwards = 1;
Inwards = -1;

// Dimensões do rolamento 608
Bearing608ExternalDiamenter = 22;
Bearing608InternalDiamenter = 8;
Bearing608MeanDiamenter =
    (Bearing608ExternalDiamenter + Bearing608InternalDiamenter) / 2;
Bearing608Width = 7;

// Dimensões do parafuso usado como eixo do hub do carretel
M8SwcreewHeadWidth = 6;
M8SwcreewLength = 105;
M8SwcreewNutWidth = 6.4;
M8SwcreewNutDiameter = 14.6;
M8SwcreewDiameter = 7.8;

// Calculando as dimensões vinculadas às pre estabelecidas

// Diametro esterno do centro do carretel
SpoolExternalDiameter = SpoolCircunfetence / PI;

// Diametro interno do cado centro do carretel
SpoolInternalDiameter = SpoolExternalDiameter - 4 * PartsMinThickness;

// A largura total do carretel é a largura útil mais a espessura de duas
// defenças
SpoolWidth = SpoolUsefulWidth + 2 * PartsMinThickness;

// Estabelece o diâmetro esterno da defença do carretel
SpoolFenseDiameter = SpoolExternalDiameter + 2 * SpoolUsefulHeight;

// Altura do hub central
HubBaseHeigth = 2 * PartsMinThickness;
HubHeigth = SpoolWidth + HubBaseHeigth;
echo("Altura do hub=", HubHeigth);

/*************************************************
 *             Definição das engrenagens
 * Usando o formulário disponível em:
 * https://khkgears.net/new/gear_knowledge/gear_technical_reference/gear_systems.html
 *
 * Za: Número de dentes da engrenagem sol
 * Zb: Número de dentes da engrenagem planeta
 * Zc: Número de dentes da engrenagem anel
 *
 * Restrições:
 * 1-A engrenagem sol deve ter um diametro tal que comporte
 *   o eixo do mecanismo passando por ela
 * 2-A engrenagem planeta deve ter um diâmetro máximo tal que seu centro
 *   fique dentro do diâmetro do hub
 * 3-Serão usadas 3 engrenagens planeta
 **************************************************/

// O furo central da engrenagem sol deve ser tal a passar com bastante folga
// pelo parafuso-eixo
SunGearBore = M8SwcreewDiameter + 4 * Gap;

// Estabelecendo o número mínimo de dentes da engrenagem sol
// O diametro da raiz dos dentes de uma engrenagem é D-2.5*M
// O número de dentes é calculado de modo a espessura minima seja
// respeitada.
Za = ceil((SunGearBore + 2 * PartsMinThickness + 2.5 * PlanetaryGearModulus) /
          PlanetaryGearModulus);

// (E)stimando o número máximo de dentes da engrenagem planeta
ZbE = floor(((SpoolInternalDiameter - Za * PlanetaryGearModulus)) /
            PlanetaryGearModulus);

// (E)stimando o número de dentes da engrenagem anel
ZcE = 2 * ZbE + Za;

// Corrigindo o tamanho das engrenagens para garantir o espaçamento
// Za+Zc deve ser múltiplo de 3 e Zc-Za deve ser par
// Usando uma função recursiva para encontrar Zc que garante as condições

Zc = FindZc(Zc0 = ZcE, Za0 = Za);

// Recalculando o número de dentes da engrenagem planeta
Zb = (Zc - Za) / 2;

echo("Za=", Za);
echo("Zb=", Zb);
echo("Zc=", Zc);
echo("Ganho mecânico=", 1 + Zc / Za);

// Calculando o diâmetro nominal das engrenagens
DZa = Za * PlanetaryGearModulus;
DZb = Zb * PlanetaryGearModulus;
DZc = Zc * PlanetaryGearModulus;

// Função recursiva para encontrar o número de dentes da engrenagem anel
function FindZc(Zc0, Za0) = ((((Zc0 - Za0) % 2 == 0) &&
                              ((Zc0 + Za0) % NumberOfPlanets == 0)) ||
                             (Zc0 == 0))
                                ? Zc0
                                : FindZc(Zc0 - 1, Za0);

/***************************************
 *Módulos de posicionamento
 ****************************************/

module PositionPlanetGear() {
  for (i = [0:NumberOfPlanets]) {
    rotate([ 0, 0, i * 360 / NumberOfPlanets ])
        translate([ (DZa + DZb) / 2, 0, 0 ]) children();
  }
}

/***************************************
 *Módulos de engrenagens
 ****************************************/
module GearSpacer(bore = 3, gap = Gap) {
  difference() {
    cylinder(h = InterGearGap / 2 - gap / 2, d = bore + 2 * PartsMinThickness,
             center = false);
    translate(v = [ 0, 0, -InterGearGap / 4 ])
        cylinder(h = InterGearGap, d = bore, center = false);
  }
}

module SunGear() {
  rotate([ 0, 0, 180 / Za ])
      spur_gear(modul = PlanetaryGearModulus, tooth_number = Za,
                width = PlanetaryGearThickness, bore = SunGearBore,
                pressure_angle = 20, helix_angle = 0, optimized = false);
  translate(v = [ 0, 0, PlanetaryGearThickness ])
      GearSpacer(bore = SunGearBore);
}

module PlanetGear() {
  spur_gear(modul = PlanetaryGearModulus, tooth_number = Zb,
            width = PlanetaryGearThickness, bore = IntermidiateGearBushing,
            pressure_angle = 20, helix_angle = 0, optimized = false);
  translate(v = [ 0, 0, PlanetaryGearThickness ])
      GearSpacer(bore = IntermidiateGearBushing);
}

module RingGear() {
  ring_gear(modul = PlanetaryGearModulus, tooth_number = Zc,
            width = PlanetaryGearThickness, rim_width = PartsMinThickness,
            pressure_angle = 20, helix_angle = 0);
}

/***************************************
 *Módulos de partes complexas
 ****************************************/

module LowerCarrier() {
  difference() {
    // Base da peça
    union() {
      difference() {
        cylinder(h = PartsMinThickness + InterGearGap + PlanetaryGearThickness,
                 r = (DZa + DZb + IntermidiateGearAxis) / 2 +
                     2 * PartsMinThickness,
                 center = false);
        translate(v = [ 0, 0, PartsMinThickness ]) PositionPlanetGear()
            cylinder(h = PlanetaryGearThickness + InterGearGap + 1,
                     d = DZb + 2 * PlanetaryGearModulus + 4 * Gap + 2);
      }
      // Espaçadores das engrenagens
      translate(v = [ 0, 0, PartsMinThickness ]) PositionPlanetGear()
          GearSpacer(bore = IntermidiateGearAxis);
    }
    // Furos dos eixos
    translate(v = [ 0, 0, -.5 ]) PositionPlanetGear()
        cylinder(h = PartsMinThickness + 1, d = IntermidiateGearAxis);
    // Furo da engrenagem sol
    translate(v = [ 0, 0, -.5 ]) cylinder(
        h = PartsMinThickness + PlanetaryGearThickness + InterGearGap + 1,
        d = DZa + 2 * PlanetaryGearModulus + 4 * Gap);
  }
}

module UpperCarrier() {

  difference() {
    // Base da peça
    union() {
      // Placa base
      cylinder(h = PartsMinThickness,
               r = (DZa + DZb + IntermidiateGearAxis) / 2 +
                   2 * PartsMinThickness,
               center = false);
      // Stand da engrenagem sol
      cylinder(h = 2 * PartsMinThickness + 1.5 * InterGearGap,
               d = DZa + 2 * PlanetaryGearModulus, center = false);
      // Espaçador entre os estágios
      cylinder(h = PartsMinThickness + InterGearGap,
               d = DZa + 2 * (PlanetaryGearModulus + PartsMinThickness),
               center = false);
    }
    // Furo do eixo principal
    translate(v = [ 0, 0, -.5 ])
        cylinder(h = 2 * PartsMinThickness + InterGearGap + 1, d = SunGearBore,
                 center = false);
    // Furos dos eixos das engrenagens planetas
    translate(v = [ 0, 0, -.5 ]) PositionPlanetGear()
        cylinder(h = PartsMinThickness + 1, d = IntermidiateGearAxis);
  }
  // Engrenagem sol
  translate(v = [ 0, 0, 2 * PartsMinThickness + 1.5 * InterGearGap ]) SunGear();
}

module Spool(FenseOnly = false) {
  module Fense() {
    // Furos para diminuir o tanto de plástico gasto da defença
    HoleDiameter = (SpoolFenseDiameter - SpoolExternalDiameter) / 2 -
                   2 * PartsMinThickness;
    // Calculando quantos furos cabem na curcunferência média deixando
    // espessura mínima
    MediumDiameter = (SpoolFenseDiameter + SpoolExternalDiameter) / 2;
    NumberOfHoles =
        floor((PI * MediumDiameter) / (HoleDiameter + PartsMinThickness));
    HoleAngle = 360 / NumberOfHoles;
    union() {
      difference() {
        cylinder(d = SpoolFenseDiameter - PartsMinThickness,
                 h = PartsMinThickness, center = true);
        Fixtures();
        for (i = [0:NumberOfHoles - 1]) {
          rotate([ 0, 0, i * HoleAngle ])
              translate([ MediumDiameter / 2, 0, 0 ]) cylinder(
                  d = HoleDiameter, h = PartsMinThickness + 1, center = true);
        }
        // Buracos para pender o filamento
        for (i = [0:NumberOfHoles - 1]) {
          rotate([ 0, 0, (i + .5) * HoleAngle ]) {
            translate([ (SpoolExternalDiameter + PartsMinThickness) / 2, 0, 0 ])
                cylinder(d = PartsMinThickness, h = PartsMinThickness + 1,
                         center = true);
            translate(
                [ SpoolFenseDiameter / 2 - 1.5 * PartsMinThickness, 0, 0 ])
                cylinder(d = PartsMinThickness, h = PartsMinThickness + 1,
                         center = true);
          }
        }
      }
      rotate_extrude() {
        translate([ (SpoolFenseDiameter - PartsMinThickness) / 2, 0, 0 ])
            circle(d = PartsMinThickness);
      }
      for (i = [0:NumberOfHoles - 1]) {
        rotate([ 0, 0, i * HoleAngle ]) translate([ MediumDiameter / 2, 0, 0 ])
            rotate_extrude() {
          translate([ HoleDiameter / 2, 0, 0 ]) circle(d = PartsMinThickness);
        }
      }
    }
  }

  module Fixtures() {
    cylinder(d = SpoolInternalDiameter + 3 * Gap, h = SpoolUsefulWidth + 1,
             center = true);
    for (i = [0:7]) {
      rotate([ 0, 0, i * 22.5 ]) cube(
          [
            SpoolInternalDiameter + 2 * (2 * Gap + PartsMinThickness),
            2 * Gap + PartsMinThickness, SpoolUsefulWidth + 1
          ],
          center = true);
    }
    for (i = [0:3]) {
      rotate([ 0, 0, i * 90 + 11.75 ])
          translate([ SpoolInternalDiameter / 2 + PartsMinThickness, 0, 0 ])
              cylinder(d = 2, h = SpoolUsefulWidth + 1, center = true);
    }
  }

  if (FenseOnly) {
    Fense();
  } else {
    translate([ 0, 0, SpoolUsefulWidth / 2 + PartsMinThickness ]) union() {
      translate([ 0, 0, -(SpoolUsefulWidth + PartsMinThickness) / 2 ]) Fense();
      difference() {
        cylinder(d = SpoolExternalDiameter, h = SpoolUsefulWidth,
                 center = true);
        Fixtures();
      }
    }
  }
}

// Peça principal que suporta o carretel e a engrenagem primária
module Hub() {
  translate([ 0, 0, HubHeigth / 2 + PartsMinThickness ]) {
    difference() {
      union() {
        // Corpo da peça
        difference() {
          union() {
            // Chanfro de encaixe
            translate([ 0, 0, SpoolWidth / 2 - PartsMinThickness ])

                cylinder(d1 = SpoolInternalDiameter - 2 * Gap,
                         d2 = SpoolInternalDiameter - PartsMinThickness,
                         h = PartsMinThickness);
            // Cilindro central
            translate([ 0, 0, -PartsMinThickness / 2 ])
                cylinder(d = SpoolInternalDiameter - 2 * Gap,
                         h = SpoolWidth - PartsMinThickness, center = true);
            // Base
            translate([ 0, 0, -SpoolWidth / 2 - HubBaseHeigth ])
                cylinder(d = SpoolInternalDiameter + 3 * PartsMinThickness,
                         h = HubBaseHeigth, center = false);
          }
          // Furo central
          translate([ 0, 0, .5 ])
              cylinder(d = SpoolInternalDiameter - 2 * PartsMinThickness,
                       h = SpoolWidth + 1, center = true);
          // Furo da base com espaço para encaixe dos eixos das engrenagens
          // planeta
          translate([ 0, 0, -SpoolWidth / 2 - HubBaseHeigth - .5 ]) {
            cylinder(r = (DZa + DZb) / 2 - PartsMinThickness -
                         IntermidiateGearAxis / 2,
                     h = HubBaseHeigth + 1);
            // Furos dos eixos das engrenagens planetas
            PositionPlanetGear()
                cylinder(d = IntermidiateGearAxis, h = HubBaseHeigth + 1);
          }
        }
        // Aletas de fixação
        for (i = [0:3]) {
          rotate([ 0, 0, i * 45 ]) {
            // Aletas principais de encaixe
            translate([ 0, 0, -HubBaseHeigth / 2 - PartsMinThickness ]) cube(
                [
                  SpoolInternalDiameter + 2 * (PartsMinThickness - Gap),
                  PartsMinThickness - Gap, HubHeigth - 2 *
                  PartsMinThickness
                ],
                center = true);
            // Aletas internas de suporte
            translate([ 0, 0, SpoolWidth / 2 - PartsMinThickness ]) cube(
                [
                  SpoolInternalDiameter - PartsMinThickness - Gap,
                  PartsMinThickness - Gap, 2 *
                  PartsMinThickness
                ],
                center = true);
            // Chanfros de encaixe
            for (i = [ 0, 1 ]) {
              rotate([ 0, 0, i * 180 ]) translate([
                (SpoolInternalDiameter - Gap) / 2, 0, (SpoolWidth) / 2 - 2 *
                PartsMinThickness
              ])
                  scale([
                    (2 * PartsMinThickness - Gap) / (PartsMinThickness - Gap),
                    1, 1
                  ]) rotate([ 0, 0, 45 ])
                      cylinder(d1 = sqrt(2) * (PartsMinThickness - Gap), d2 = 0,
                               h = PartsMinThickness, $fn = 4);
            }
          }
        }
        // Eixo central
        translate([ 0, 0, -PartsMinThickness ])
            cylinder(d = Bearing608ExternalDiamenter + 2 * PartsMinThickness,
                     h = HubHeigth, center = true);
      }
      // Furo do eixo central
      cylinder(d = Bearing608MeanDiamenter + 2 * Gap, h = HubHeigth + 1,
               center = true);
      // Furos para os rolamentos
      translate([ 0, 0, -SpoolWidth / 2 - HubBaseHeigth - 1 ]) cylinder(
          d = Bearing608ExternalDiamenter + 2 * Gap, h = Bearing608Width + 1);
      // O furo para o rolamento superior deve conter a cabeça do parafuso
      // usado como eixo
      translate([ 0, 0, HubHeigth / 2 - Bearing608Width - M8SwcreewHeadWidth ])
          cylinder(d = Bearing608ExternalDiamenter + 2 * Gap,
                   h = Bearing608Width + M8SwcreewHeadWidth + 1);
    }
  }
}

// translate(v = [ 0, 0, PlanetaryGearThickness ]) Hub();
// RingGear();

translate([ 0, 0, -PartsMinThickness - InterGearGap ]) UpperCarrier();
translate(
    v = [ 0, 0, PartsMinThickness + PlanetaryGearThickness + InterGearGap ]) %
    UpperCarrier();
LowerCarrier();
translate(v = [ 0, 0, PartsMinThickness + InterGearGap / 2 ])
    PositionPlanetGear() PlanetGear();