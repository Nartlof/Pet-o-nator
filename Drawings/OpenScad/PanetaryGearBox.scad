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
IntermidiateGearThickness = 10;
InterGearGap = 1;
FirstGearModulus = 2;
PlanetaryGearModulus = 1;
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
HubHeigth = SpoolWidth + 2 * PartsMinThickness + MdfThickness;
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

module SunGear() {
  rotate([ 0, 0, 180 / Za ])
      spur_gear(modul = PlanetaryGearModulus, tooth_number = Za,
                width = 2 * PartsMinThickness, bore = SunGearBore,
                pressure_angle = 20, helix_angle = 0, optimized = false);
}

module PlanetGear() {
  spur_gear(modul = PlanetaryGearModulus, tooth_number = Zb,
            width = 2 * PartsMinThickness, bore = IntermidiateGearBushing,
            pressure_angle = 20, helix_angle = 0, optimized = false);
}

module RingGear() {
  ring_gear(modul = PlanetaryGearModulus, tooth_number = Zc,
            width = 2 * PartsMinThickness, rim_width = PartsMinThickness,
            pressure_angle = 20, helix_angle = 0);
}

RingGear();
// SunGear();
/*
for (i = [ 0, 120, 240 ])
{
  rotate([ 0, 0, i ]) translate([ (DZa + DZb) / 2, 0, 0 ])
PlanetGear();

//}//*/