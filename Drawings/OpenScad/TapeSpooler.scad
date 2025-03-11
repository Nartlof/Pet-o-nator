/**
 * Project Name : Pet-o-Nator
 *
 * Author: Carlos Eduardo Foltran
 * GitHub: [GitHub Repository URL]
 * Thingiverse: [Thingiverse Project URL]
 * License: Creative Commons CC0 1.0 Universal (CC0 1.0)
 * Description: This file contains the spooler mechanism for pooling the PET tape from the cutter
 *
 * Date Created: 2025-03-09
 * Last Updated: 2025-03-09
 *
 * This OpenSCAD file is provided under the Creative Commons CC0 1.0 Universal (CC0 1.0) License.
 * You are free to use, modify, and distribute this design for any purpose, without any restrictions.
 *
 * For more details about the CC0 license, visit: https://creativecommons.org/publicdomain/zero/1.0/
 */

include <GlobalDefinitions.scad>
use <Library\gear\gears.scad>
use <SpoolAndCarrier.scad>

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

echo("Zr=", Zr);
echo("Zs=", Zs);
echo("Zp=", Zp);
echo("(Zs+Zr)/Np", (Zs + Zr) / Np);

// Calculando o número de engrenagens planeta apenas para checar se é maior que 3
echo("Np=", floor(180 / asin((Zp + 2) / (Zs + Zp))));

$fa = ($preview) ? $fa : 2;
$fs = ($preview) ? $fs : .2;

module SpoolCarrier()
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
        }
        translate(v = [ 0, 0, -SpoolWidth / 2 + lip ])
            ring_gear(modul = Mod, tooth_number = Zr, width = SpoolWidth - 2 * lip, rim_width = PartsMinThickness,
                      pressure_angle = 20, helix_angle = Helix);
    }
}

module PlanetGear()
{
    coneHeigth = ((Zp + 2) * Mod - CopperInsertDiameter) / 2;
    translate(v = [ 0, 0, SpoolWidth / 2 ]) render(convexity = 2) intersection()
    {
        union()
        {
            hull() for (i = [ 0, 1 ])
            {
                rotate(a = [ i * 180, 0, 0 ])

                    translate(v = [ 0, 0, SpoolWidth / 2 - PartsMinThickness - Lip ]) union()
                {
                    cylinder(h = coneHeigth, d1 = (Zp + 2) * Mod, d2 = CopperInsertDiameter, center = false);
                }
            }
            cylinder(h = SpoolWidth + 2, d = CopperInsertDiameter + 2 * Lip, center = true);
        }
        translate(v = [ 0, 0, -SpoolWidth / 2 ])
            spur_gear(modul = Mod, tooth_number = Zp, width = SpoolWidth, bore = CopperInsertDiameter,
                      pressure_angle = 20, helix_angle = Helix, optimized = false);
    }
}

module PositionPlanetGear()
{
    for (i = [0:2])
    {
        rotate(a = i * 120) translate(v = [ (Zr - Zp) / 2, 0, PartsMinThickness ]) rotate(a = -i * (Zr / Zp) * 120)
            children();
    }
}

module SunGear()
{
    spur_gear(modul = Mod, tooth_number = Zs, width = SpoolWidth, bore = Zs / 2, pressure_angle = 20,
              helix_angle = -Helix, optimized = false);
}

render(convexity = 2) intersection()
{
    cylinder(h = SpoolWidth / 2, r = SpoolInternalDiameter, center = false);
    union()
    {
        SpoolCarrier();

        PositionPlanetGear() PlanetGear();
        translate(v = [ 0, 0, PartsMinThickness ]) SunGear();
    }
}
/*
translate(v = [ 0, 0, PartsMinThickness ])
{
    Spool(FenseOnly = false);
    translate(v = [ 0, 0, SpoolUsefulWidth + PartsMinThickness ]) Spool(FenseOnly = true);
}

//*/