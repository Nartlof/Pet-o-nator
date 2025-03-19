/**
 * Project Name : Pet-o-Nator
 *
 * Author: Carlos Eduardo Foltran
 * GitHub: [GitHub Repository URL]
 * Thingiverse: [Thingiverse Project URL]
 * License: Creative Commons CC0 1.0 Universal (CC0 1.0)
 * Description: This file contains the spool and carrier and related definitions
 *
 * Date Created: 2025-03-07
 * Last Updated: 2025-03-19 - Correcting the fins on the carrier when carving
 *
 * This OpenSCAD file is provided under the Creative Commons CC0 1.0 Universal (CC0 1.0) License.
 * You are free to use, modify, and distribute this design for any purpose, without any restrictions.
 *
 * For more details about the CC0 license, visit: https://creativecommons.org/publicdomain/zero/1.0/
 */

include <GlobalDefinitions.scad>

// Cria o Carrier para encaixe do carretel e também o corpo de corte para o carretel
module Carrier(carve = false)
{
    module Base(height, gap)
    {
        partsThickness = PartsMinThickness + 2 * gap;
        finHeight = height - 2 * PartsMinThickness + 4 * gap;
        // Cilindro central
        cylinder(d = SpoolInternalDiameter + 4 * gap, h = SpoolWidth + 2 * gap, center = true);
        for (i = [0:3])
        {
            rotate([ 0, 0, i * 45 ]) hull() union()
            {
                // Base da aleta
                intersection()
                {
                    cube([ SpoolInternalDiameter + 4 * partsThickness, partsThickness, finHeight ], center = true);
                    cylinder(h = finHeight, r = SpoolInternalDiameter / 2 + partsThickness, center = true);
                }
                // Criando as partes inclinadas para facilitar o encaixe do carretel e possibilitar impressão sem
                // suportes
                for (k = [ 0, 1 ])
                {
                    rotate([ k * 180, 0, 0 ])
                    {
                        translate(v = [ 0, 0, finHeight / 2 ])
                        {

                            for (j = [ -1, 1 ])
                            {
                                translate(v = [ j * SpoolInternalDiameter / 2, 0, 0 ]) rotate(a = 45)

                                    cylinder(h = partsThickness, d1 = partsThickness * sqrt(2), d2 = 0, center = false,
                                             $fn = 4);
                            }
                        }
                    }
                }
            }
        }
    }

    if (carve)
    {
        alpha =
            (180 / PI) * ((PartsMinThickness + 2 * Gap) / (SpoolInternalDiameter + 2 * (PartsMinThickness + 2 * Gap)));
        for (j = [ 0, 1 ])
        {
            rotate(a = j * 22.5)
            {

                Base(height = 2 * SpoolWidth, gap = Gap);
                for (i = [ 1, -1 ])
                {
                    rotate(a = [ 0, 0, i * alpha ]) Base(height = SpoolUsefulWidth - 2 * PartsMinThickness, gap = Gap);
                }
            }
        }
    }
    else
    {
        Base(height = SpoolUsefulWidth - 2 * PartsMinThickness, gap = 0);
    }
}

module Spool(FenseOnly = false)
{
    module Fense()
    {
        // Furos para diminuir o tanto de plástico gasto da defença
        HoleDiameter = (SpoolFenseDiameter - SpoolExternalDiameter) / 2 - 2 * PartsMinThickness;
        // Calculando quantos furos cabem na curcunferência média deixando
        // espessura mínima
        MediumDiameter = (SpoolFenseDiameter + SpoolExternalDiameter) / 2;
        NumberOfHoles = floor((PI * MediumDiameter) / (HoleDiameter + PartsMinThickness));
        HoleAngle = 360 / NumberOfHoles;
        translate(v = [ 0, 0, PartsMinThickness / 2 ]) union()
        {
            difference()
            {
                // Cilindro base
                cylinder(d = SpoolFenseDiameter - PartsMinThickness, h = PartsMinThickness, center = true);
                // Furos de fixação e de encaixe
                // translate(v = [ 0, 0, -(SpoolWidth - PartsMinThickness) / 2 ]) Fixtures();
                for (i = [0:NumberOfHoles - 1])
                {
                    rotate([ 0, 0, i * HoleAngle ]) translate([ MediumDiameter / 2, 0, 0 ])
                        cylinder(d = HoleDiameter, h = PartsMinThickness + 1, center = true);
                }
                // Buracos para pender o filamento
                for (i = [0:NumberOfHoles - 1])
                {
                    rotate([ 0, 0, (i + .5) * HoleAngle ])
                    {
                        translate([ (SpoolExternalDiameter + PartsMinThickness) / 2, 0, 0 ])
                            cylinder(d = PartsMinThickness, h = PartsMinThickness + 1, center = true);
                        translate([ SpoolFenseDiameter / 2 - 1.5 * PartsMinThickness, 0, 0 ])
                            cylinder(d = PartsMinThickness, h = PartsMinThickness + 1, center = true);
                    }
                }
            }
            rotate_extrude()
            {
                translate([ (SpoolFenseDiameter - PartsMinThickness) / 2, 0, 0 ]) circle(d = PartsMinThickness);
            }
            for (i = [0:NumberOfHoles - 1])
            {
                rotate([ 0, 0, i * HoleAngle ]) translate([ MediumDiameter / 2, 0, 0 ]) rotate_extrude()
                {
                    translate([ HoleDiameter / 2, 0, 0 ]) circle(d = PartsMinThickness);
                }
            }
        }
    }

    // Cria os furos de fixação e encaixe
    module Fixtures()
    {

        Carrier(carve = true);

        /* for (i = [0:7])
         {
             rotate([ 0, 0, i * 22.5 ]) cube(
                 [
                     SpoolInternalDiameter + 2 * (2 * Gap + PartsMinThickness), 2 * Gap + PartsMinThickness,
                     SpoolUsefulWidth + 1
                 ],
                 center = true);
         }//*/
        for (i = [0:7])
        {
            rotate([ 0, 0, i * 45 + 11.75 ])
                translate([ SpoolInternalDiameter / 2 + PartsMinThickness, 0, SpoolWidth / 2 ])
                    ScrewM2(lenght = SpoolWidth, passThrough = PartsMinThickness);
        }
    }

    if (FenseOnly)
    {
        difference()
        {
            Fense();
            translate(v = [ 0, 0, -SpoolWidth / 2 + PartsMinThickness ]) Fixtures();
        }
    }
    else
    {
        translate([ 0, 0, SpoolUsefulWidth / 2 + PartsMinThickness ]) union()
        {
            difference()
            {
                union()
                {
                    cylinder(d = SpoolExternalDiameter, h = SpoolUsefulWidth, center = true);
                    translate([ 0, 0, -SpoolWidth / 2 ]) Fense();
                }
                Fixtures();
            }
        }
    }
}

// Carrier(carve = false);
// Carrier(carve = true);

// Spool(FenseOnly = false);
// Spool(FenseOnly = true);