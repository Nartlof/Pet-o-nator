/**
 * Project Name : Pet-o-Nator
 *
 * Author: Carlos Eduardo Foltran
 * GitHub: https://github.com/Nartlof/Pet-o-nator
 * Thingiverse: [Thingiverse Project URL]
 * License: Creative Commons CC0 1.0 Universal (CC0 1.0)
 * Description: This file contains the spooler mechanism for pooling the PET tape from the cutter
 *
 * Date Created: 2025-03-09
 * Last Updated: 2025-03-17
 *
 * This OpenSCAD file is provided under the Creative Commons CC0 1.0 Universal (CC0 1.0) License.
 * You are free to use, modify, and distribute this design for any purpose, without any restrictions.
 *
 * For more details about the CC0 license, visit: https://creativecommons.org/publicdomain/zero/1.0/
 */

include <GlobalDefinitions.scad>
use <Library/Gear/gears.scad>
use <SpoolAndCarrier.scad>
// What to render
WhatToRender = "All"; //["All","Planet","Sun","PCBase","PCTop","HexAxis","Carrier","Arm","Handle","Core","Cap"]

/*[Hidden]*/

CrankHandleHeight = 40;

/*************************************************
 *             Definição das engrenagens
 * Usando o formulário disponível em:
 * https://khkgears.net/new/gear_knowledge/gear_technical_reference/gear_systems.html
 *
 * Zs: Número de dentes da engrenagem sol
 * Zp: Número de dentes da engrenagem planeta
 * Zr: Número de dentes da engrenagem anel
 *
 * Restrições:
 * 1-A engrenagem anel deve ter um diametro tal que o carrier tenha sua espessura mínima respeitada
 * 2-O ganho mecânico deve ser de no mímimo 2
 * 3-Serão usadas 3 engrenagens planeta: Np=3
 **************************************************/

// Escolha do módulo das engrenagens
Mod = 1;

// Escolha do número de engrenagens planeta. O sistema de calculo das engrenagens
// pode não funcionar se Np for par.
Np = 3;

// Escolha do ângulo de hélice. O ângulo é tal que a helicoide faz avançar um dente.
// A distância entre dois dentes consecutivos é Pi*Mod
Helix = (Mod / SpoolWidth) * 180;

// Calculando o número de dentes da engrenagem anel para garantir espessura
// mínima da parede do carrier
Zr = floor(SpoolInternalDiameter - 2 * PartsMinThickness - 2 * Mod);

// Calculando o número de dentes da engrenagem sol para o ganho mecânico mínimo
// e garantindo que Zr e Zs tenham a mesma paridade, para que seja sempre possível
// ter uma engrenagem planeta com número inteiro de dentes. Além disso a soma Zs+Zr deve
// ser multipla de Np.

Zs = let(Zs_1 = floor(Zr / 2), Zs_2 = Zs_1 - ((Zs_1 % 2 == Zr % 2) ? 0 : 1), Ajt_1 = (Zs_2 + Zr) % Np,
         Ajt_2 = (Ajt_1 % 2 == 0) ? Ajt_1 : Ajt_1 + Np) Zs_2 -
     Ajt_2;

// Calculando o número de dentes das engrenagens planeta
Zp = (Zr - Zs) / 2;

echo(str("Zr=", Zr));
echo(str("Zs=", Zs));
echo(str("Zp=", Zp));
echo(str("(Zs+Zr)/Np", (Zs + Zr) / Np));
echo(str("Mechanical gain=", Zr / Zs));

// Calculando o número de engrenagens planeta apenas para checar se é maior que 3
echo(str("Np=", floor(180 / asin((Zp + 2) / (Zs + Zp)))));

// Calculando o tamanho do hexagono para prender a manivela. Ele deve ter uma medida
// que permita usar uma chave de boca, ou seja, a altura deve ser um inteiro. A altura h
// do hexagono em relação à diagonal é h=d*sqrt(3)/2. É preciso achar d tal que h seja
// inteiro e que respeite a espessura mínima.
HexSize = let(dMax = (Zs - 2.5) * Mod - 2 * PartsMinThickness, h = floor(dMax * sqrt(3) / 2)) 2 * h * sqrt(3) / 3;

// Espessura da aste da manivela
CrankArmThickness = 3 / 2 * PartsMinThickness;

// Diametro da base
BaseDiameter = SpoolInternalDiameter + 6 * PartsMinThickness;

// Diametro do furo para o parafuso da manopla
CrankScrewD = 3;

$fa = ($preview) ? $fa : 2;
$fs = ($preview) ? $fs : .2;

module PositionPlanetGear()
{
    for (i = [0:2])
    {
        rotate(a = i * 120) translate(v = [ (Zr - Zp) / 2, 0, 0 ]) rotate(a = -i * (Zr / Zp) * 120) children();
    }
}

module SpoolCarrier() // make me
{
    // Diametro do espaço interno do carrier
    innerDiameter = SpoolInternalDiameter - 2 * PartsMinThickness;
    // Altura da borda reta na parte inclinada do carrier, para não fazer borda afiada.
    lip = Lip;
    // Altura total do carrier é de (SpoolWidth + PartsMinThickness)
    // Trazendo toda a peça para o plano XY
    translate(v = [ 0, 0, SpoolWidth / 2 + PartsMinThickness ])
    {
        difference()
        {
            union()
            {
                // Carrier e o batente do carretel
                Carrier(carve = false);
                translate(v = [ 0, 0, -SpoolWidth / 2 - PartsMinThickness ])
                    cylinder(h = PartsMinThickness, d = SpoolInternalDiameter + 6 * PartsMinThickness, center = false);
            }
            hull() for (i = [ 0, 1 ])
            {
                rotate(a = [ i * 180, 0, 0 ]) translate(v = [ 0, 0, SpoolWidth / 2 - PartsMinThickness - lip ])
                    cylinder(h = PartsMinThickness, d1 = innerDiameter, d2 = innerDiameter - 2 * PartsMinThickness,
                             center = false);
            }
            cylinder(h = SpoolWidth + 2 * PartsMinThickness + 1, d = innerDiameter - 2 * PartsMinThickness,
                     center = true);
            // Buracos dos parafusos para fixar o spooler na base de madeira
            for (i = [0:3])
            {
                rotate(a = 90 * i + 22.5) translate(
                    v = [ (BaseDiameter + SpoolInternalDiameter) / 4, 0, -(SpoolWidth / 2 + PartsMinThickness) ])
                    ScrewM3(lenght = 2 * PartsMinThickness, passThrough = PartsMinThickness,
                            deepness = PartsMinThickness);
            }
        }
        translate(v = [ 0, 0, -SpoolWidth / 2 + lip ])
            ring_gear(modul = Mod, tooth_number = Zr, width = SpoolWidth - 2 * lip, rim_width = PartsMinThickness,
                      pressure_angle = 20, helix_angle = Helix);
    }
}

module PlanetGear() // make me
{
    coneHeigth = PartsMinThickness + Lip;
    dOut = (Zp + 2) * Mod;
    translate(v = [ 0, 0, SpoolWidth / 2 ]) render(convexity = 2) intersection()
    {
        union()
        {
            hull() for (i = [ 0, 1 ])
            {
                rotate(a = [ i * 180, 0, 0 ])

                    translate(v = [ 0, 0, SpoolWidth / 2 - PartsMinThickness - Lip ]) union()
                {
                    cylinder(h = coneHeigth, d1 = dOut, d2 = dOut - 2 * coneHeigth, center = false);
                }
            }
            cylinder(h = SpoolWidth + 2, d = CopperInsertDiameter + 2 * Lip, center = true);
        }
        translate(v = [ 0, 0, -SpoolWidth / 2 ])
            spur_gear(modul = Mod, tooth_number = Zp, width = SpoolWidth, bore = CopperInsertDiameter,
                      pressure_angle = 20, helix_angle = Helix, optimized = false);
    }
}

module SunGear() // make me
{
    coneHeigth = PartsMinThickness + Lip; // Altura do cone superior
    dOut = (Zs + 2) * Mod;
    dIn = (Zs - 2.5) * Mod;
    render(convexity = 2) difference()
    {
        union()
        {
            intersection()
            {
                // Fazendo a parte de baixo cônica
                union()
                {
                    hull()
                    {
                        cylinder(h = coneHeigth, d1 = dOut - 2 * coneHeigth, d2 = dOut, center = false);
                        translate(v = [ 0, 0, SpoolWidth - 1 ]) cylinder(h = 1, d = dOut, center = false);
                    }
                }

                spur_gear(modul = Mod, tooth_number = Zs, width = SpoolWidth, bore = CopperInsertDiameter,
                          pressure_angle = 20, helix_angle = -Helix, optimized = false);
            }
            // Criando o encaixe superior
            translate(v = [ 0, 0, SpoolWidth - coneHeigth ])
            {
                difference()
                {
                    union()
                    {
                        cylinder(h = coneHeigth - Lip, d1 = dIn, d2 = dIn + 2 * (coneHeigth - Lip), center = false);
                        translate(v = [ 0, 0, coneHeigth - Lip ])
                            cylinder(h = Lip, d = dIn + 2 * (coneHeigth - Lip), center = false);
                        translate(v = [ 0, 0, coneHeigth ])
                            cylinder(h = PartsMinThickness, d = Zs * Mod, center = false);
                    }
                    translate(v = [ 0, 0, -1 ])
                        cylinder(h = coneHeigth + PartsMinThickness + 2, d = CopperInsertDiameter, center = false);
                }
            }
        }
        // Criando o furo hexagonal
        translate(v = [ 0, 0, 2 * PartsMinThickness ]) HexAxis(gap = Gap);
    }
}

module HexAxis(gap = 0)
{
    difference()
    {
        cylinder(h = SpoolWidth + CrankArmThickness, d = HexSize + 2 * gap, center = false, $fn = 6);
        // Buraco do parafuso de fixação
        /*translate(v = [ 0, -(HexSize / 2 + 1.5), SpoolWidth + CrankArmThickness / 2 ]) rotate(a = [ 90, 0, 0 ])
            ScrewM2(lenght = 10, passThrough = 0, deepness = 0);//*/
    }
}

module PlanetsCarrier(base = true)
{
    module PlanetSpace()
    {
        dOut = (Zp + 3) * Mod;
        translate(v = [ 0, 0, SpoolWidth / 2 + Gap ]) hull() for (i = [ 1, 0 ])
        {
            rotate(a = [ i * 180, 0, 0 ]) translate(v = [ 0, 0, -SpoolWidth / 2 - Gap ])
                cylinder(h = PartsMinThickness, d1 = dOut - 2 * PartsMinThickness, d2 = dOut, center = false);
        }
    }
    module SunSpace()
    {
        dOut = (Zs + 3) * Mod;
        dIn = (Zs - 2) * Mod;
        hull()
        {
            translate(v = [ 0, 0, -Gap ]) cylinder(h = 5 * Mod, d1 = dOut - 2 * PartsMinThickness,
                                                   d2 = dIn + 2 * PartsMinThickness, center = false);
            translate(v = [ 0, 0, SpoolWidth + Gap - Lip ])
                cylinder(h = Lip, d = dIn + 2 * PartsMinThickness, center = false);
        }
    }

    innerDiameter = SpoolInternalDiameter - 4 * PartsMinThickness - 2 * Gap;
    planetsCarrierHeigth = SpoolWidth + 3 * PartsMinThickness + 2 * Gap;
    baseDiameter = SpoolInternalDiameter + 6 * PartsMinThickness;
    sCreewDiameter = 2.9; // Usando parafuso auto tarraxante de 2.9mm
    intersection()
    {
        difference()
        {
            union()
            {
                // Corpo interno
                cylinder(h = SpoolWidth + 3 * PartsMinThickness + 2 * Gap, d = innerDiameter, center = false);
                // Base de fixação
                cylinder(h = PartsMinThickness, d = baseDiameter, center = false);
                translate(v = [ 0, 0, SpoolWidth + 2 * PartsMinThickness + 2 * Gap ]) hull()
                {
                    cylinder(h = Lip, d = SpoolInternalDiameter, center = false);
                    cylinder(h = PartsMinThickness, d = SpoolInternalDiameter - 2 * (PartsMinThickness - Lip),
                             center = false);
                }
            }
            // Aberturas para as engrenagens planeta
            PositionPlanetGear()
            {
                translate(v = [ 0, 0, Lip ])
                    cylinder(h = SpoolWidth + 3 * PartsMinThickness - 2 * Lip, d = StealAxisDiamenter, center = false);
                translate(v = [ 0, 0, 2 * PartsMinThickness ]) PlanetSpace();
            }
            // Eixo da engrenagem sol
            translate(v = [ 0, 0, Lip ]) cylinder(h = 3 * PartsMinThickness, d = StealAxisDiamenter, center = false);
            translate(v = [ 0, 0, 2 * PartsMinThickness ]) SunSpace();
            translate(v = [ 0, 0, SpoolWidth + 2 * PartsMinThickness - 1 ])
                cylinder(h = PartsMinThickness + 2, d = Zs * Mod + 2 * Gap, center = false);
            // Buracos dos parafusos para unir as duas mentades
            rotate(a = 180 / Np) PositionPlanetGear()
                translate(v = [ 0, 0, planetsCarrierHeigth / 2 + 2 * PartsMinThickness ])
            {
                ScrewM3(lenght = 20, passThrough = PartsMinThickness, deepness = planetsCarrierHeigth);
                // cylinder(h = planetsCarrierHeigth, d = 5.5, center = false);
            }
            // Buracos dos parafusos para fixar o spooler na base de madeira
            for (i = [0:3])
            {
                rotate(a = 90 * i + 22.5)
                    translate(v = [ (baseDiameter + SpoolInternalDiameter) / 4, 0, PartsMinThickness ])
                        ScrewM3(lenght = 2 * PartsMinThickness, passThrough = PartsMinThickness);
            }
        }
        if (base)
        {

            cylinder(h = planetsCarrierHeigth / 2, d = baseDiameter, center = false);
            rotate(a = 180 / Np) PositionPlanetGear() translate(v = [ 0, 0, planetsCarrierHeigth / 2 ])
                cylinder(h = PartsMinThickness, d1 = 2 * PartsMinThickness + sCreewDiameter,
                         d2 = 2 * (PartsMinThickness - Lip) + sCreewDiameter, center = false);
        }
        else
        {
            translate(v = [ 0, 0, planetsCarrierHeigth / 2 ]) difference()
            {
                cylinder(h = planetsCarrierHeigth / 2, d = baseDiameter, center = false);
                rotate(a = 180 / Np) PositionPlanetGear()
                    cylinder(h = PartsMinThickness, d1 = 2 * (PartsMinThickness + Gap) + sCreewDiameter,
                             d2 = 2 * (PartsMinThickness + Gap - Lip) + sCreewDiameter, center = false);
            }
        }
    }
}

module CrankArm() // make me
{
    profileRadius = CrankArmThickness * sqrt(2) / 2;
    crankArmLenght = SpoolFenseDiameter / 2 - CrankArmThickness - CrankScrewD / 2;
    module quartProfile()
    {
        // difference()
        {
            intersection()
            {
                translate(v = [ CrankArmThickness - profileRadius, 0 ]) circle(r = profileRadius);
                square(size = [ CrankArmThickness, CrankArmThickness / 2 ], center = false);
            }
            // translate(v = [ 0, CrankArmThickness / 2 + profileRadius * (1 - (1 - cos(45))), 0 ])
            //     circle(r = profileRadius);
        }
    }
    module halfProfile()
    {
        quartProfile();
        mirror(v = [ 0, 1, 0 ]) quartProfile();
    }

    module ending(d = 10)
    {
        // relação do ráio do encaixe final com os tapers laterais
        rMulti = 3;
        // Angulo de concordância entre a aste e o engate
        alpha = asin((rMulti * d / 2 + CrankArmThickness) / ((rMulti + 1) * d / 2 + CrankArmThickness));

        cylinder(h = CrankArmThickness, d = d + CrankArmThickness, center = true);
        rotate_extrude(angle = 360, convexity = 2) translate(v = [ d / 2, 0, 0 ]) halfProfile();

        for (i = [ 0, 1 ])
        {
            mirror(v = [ i, 0, 0 ])
            {

                translate(v = [ sin(alpha), cos(alpha), 0 ] * ((rMulti + 1) * d / 2 + CrankArmThickness))
                    rotate_extrude(angle = 90 - alpha, convexity = 2)
                        translate(v = [ -rMulti * d / 2 - CrankArmThickness, 0, 0 ]) halfProfile();
            }
        }
    }

    difference()
    {
        union()
        { // Aste
            rotate(a = [ -90, 0, 0 ]) linear_extrude(height = crankArmLenght, center = false, convexity = 10, twist = 0,
                                                     slices = 20, scale = 1.0)
            {
                for (i = [ 0, 180 ])
                {

                    rotate(a = i)
                    {
                        halfProfile();
                    }
                }
            }
            // Encaixe hexagonal
            ending(d = HexSize);
            hull()
            {

                cylinder(h = CrankArmThickness / 2 + PartsMinThickness, d = HexSize + 2 * PartsMinThickness,
                         center = false);
            }
            // Engate da manopla
            translate(v = [ 0, SpoolFenseDiameter / 2 - CrankArmThickness - CrankScrewD / 2 ]) rotate(a = 180)
                ending(d = CrankScrewD);
        }
        // Parafuso da manopla
        // rotate(a = [ 0, 180, 0 ])
        translate(v = [ 0, SpoolFenseDiameter / 2 - CrankArmThickness - CrankScrewD / 2, CrankArmThickness / 2 ])
            ScrewM3(lenght = 10, passThrough = CrankArmThickness, deepness = 0);
        // Furo exagonal
        translate(v = [ 0, 0, -CrankArmThickness ]) HexAxis(gap = Gap);
        // cylinder(h = CrankArmThickness + 1, d = HexSize, center = true, $fn = 6);
        //  Parafuso de fixação
        /*translate(v = [ 0, -HexSize / 2 - CrankArmThickness + Lip, 0 ]) rotate(a = [ 90, 0, 0 ])
            ScrewM2(lenght = 10, passThrough = 10, deepness = CrankArmThickness);//*/
    }
}

module CrankHandle() // make me
{
    r_2 = CrankArmThickness + CrankScrewD / 2;
    r_1 = r_2 - CrankArmThickness * (sqrt(2) - 1) / 2;
    difference()
    {
        hull()
        {
            translate(v = [ 0, 0, CrankHandleHeight - PartsMinThickness - 2 * Gap - 1 ])
                cylinder(h = 1, r = CrankArmThickness + CrankScrewD / 2, center = false);
            cylinder(h = r_2 - r_1, r1 = r_1, r2 = r_2, center = false);
        }
        translate(v = [ 0, 0, -Gap ]) cylinder(h = CrankHandleHeight, r = PartsMinThickness + Gap, center = false);
    }
}

module CrankHandleCore()
{
    difference()
    {
        cylinder(h = CrankHandleHeight - PartsMinThickness, d = 2 * PartsMinThickness, center = false, $fn = 6);

        rotate(a = [ 180, 0, 0 ]) translate(v = [ 0, 0, PartsMinThickness ])
            ScrewM3(lenght = 17, passThrough = 0, deepness = 0);
        translate(v = [ 0, 0, CrankHandleHeight ]) ScrewM2(lenght = 13, passThrough = PartsMinThickness, deepness = 0);
    }
}

module CrankHandleCap() // make me
{
    difference()
    {
        scale([ 0, 0, 1 ] + [ 1, 1, 0 ] * (CrankArmThickness + CrankScrewD / 2) / PartsMinThickness) intersection()
        {
            sphere(r = PartsMinThickness);
            cylinder(h = PartsMinThickness, r = PartsMinThickness, center = false);
        }
        translate(v = [ 0, 0, PartsMinThickness ]) ScrewM2(lenght = 13, passThrough = PartsMinThickness, deepness = 0);
    }
}

if (WhatToRender == "All")
{

    color(c = "blue", alpha = 1.0) render() PlanetsCarrier(base = false);
    color(c = "Red", alpha = 1.0) render() PlanetsCarrier(base = true);
    translate(v = [ 0, 0, PartsMinThickness + Gap ])
    {
        SpoolCarrier();
        translate(v = [ 0, 0, PartsMinThickness ])
        {
            PositionPlanetGear() PlanetGear();

            SunGear();
            translate(v = [ 0, 0, 2 * PartsMinThickness ]) color(c = "green", alpha = 1.0) HexAxis();
            translate(v = [ 0, 0, SpoolWidth + 2 * PartsMinThickness + CrankArmThickness / 2 ])
            {
                rotate(a = [ 0, 180, 0 ]) render() CrankArm();
                translate(
                    v = [ 0, SpoolFenseDiameter / 2 - CrankArmThickness - CrankScrewD / 2, CrankArmThickness / 2 ])
                {
                    CrankHandleCore();
                    translate(v = [ 0, 0, Gap ]) CrankHandle();
                    translate(v = [ 0, 0, CrankHandleHeight - PartsMinThickness ]) CrankHandleCap();
                }
            }
        }
    }

    % render() translate(v = [ 0, 0, 2 * PartsMinThickness ])
    {
        Spool(FenseOnly = false);
        translate(v = [ 0, 0, SpoolUsefulWidth + PartsMinThickness ]) Spool(FenseOnly = true);
    }
}
else if (WhatToRender == "Planet")
{
    PlanetGear();
}
else if (WhatToRender == "Sun")
{
    SunGear();
}
else if (WhatToRender == "PCBase")
{
    PlanetsCarrier(base = true);
}
else if (WhatToRender == "PCTop")
{
    PlanetsCarrierTop();
}
else if (WhatToRender == "HexAxis")
{
    rotate(a = [ 90, 0, 0 ]) HexAxis(gap = 0);
}
else if (WhatToRender == "Carrier")
{
    SpoolCarrier();
}
else if (WhatToRender == "Arm")
{
    CrankArm();
}
else if (WhatToRender == "Handle")
{
    CrankHandle();
}
else if (WhatToRender == "Core")
{
    crankHandleCore();
}
else if (WhatToRender == "Cap")
{
    CrankHandleCap();
}
else
{
    assert(false, "Parâmetro inválido");
}

// Modulos para o MAKE
module crankHandleCore() // make me
{
    rotate(a = [ 90, 0, 0 ]) CrankHandleCore();
}

module PlanetsCarrierBase() // make me
{
    PlanetsCarrier(base = true);
}

module PlanetsCarrierTop() // make me
{
    translate(v = [ 0, 0, SpoolWidth + 3 * PartsMinThickness ]) rotate(a = [ 180, 0, 0 ]) PlanetsCarrier(base = false);
}

module hexAxis() // make me
{
    rotate(a = [ 90, 0, 0 ]) HexAxis(gap = 0);
}
module SpoolBase() // make me
{
    Spool(FenseOnly = false);
}
module SpoolFense() // make me
{
    Spool(FenseOnly = true);
}