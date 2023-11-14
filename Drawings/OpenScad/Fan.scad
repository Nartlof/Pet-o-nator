/**
 * Project Name :Motor fan
 *
 * Author: Carlos Eduardo Foltran
 * GitHub: [GitHub Repository URL]
 * Thingiverse: [Thingiverse Project URL]
 * License: Creative Commons CC0 1.0 Universal (CC0 1.0)
 * Description: this is a simple fan for a DC motor
 *
 * Date Created: [Date of initial creation]
 * Last Updated: [Date of last modification]
 *
 * This OpenSCAD file is provided under the Creative Commons CC0 1.0 Universal (CC0 1.0) License.
 * You are free to use, modify, and distribute this design for any purpose, without any restrictions.
 *
 * For more details about the CC0 license, visit: https://creativecommons.org/publicdomain/zero/1.0/
 */

AxisDiameter = 3;
MotorDiamenter = 30;
ContactSpace = 6;
Clearence = 3;
RubThickness = 3;
Blades = 5;
BladeThickness = 1.5;
BladeAngle = 35;
BladeHeigth = 15;
FanDiameter = 80;

$fa = ($preview) ? $fa : 2;
$fs = ($preview) ? $fs : .2;

RubHeight = ContactSpace + RubThickness + Clearence;
RubDiameter = AxisDiameter + 2 * RubThickness;
BladeRubDiamenter = MotorDiamenter + 2 * Clearence + 2 * BladeThickness;

intersection()
{
    difference()
    {
        union()
        {
            cylinder(h = RubHeight, d = RubDiameter, center = false);
            difference()
            {
                union()
                {
                    // Blades
                    for (i = [0:Blades - 1])
                    {
                        rotate([ 0, 0, i * 360 / Blades ])
                        {
                            translate(v = [ 0, 0, BladeHeigth / (4 * sin(BladeAngle)) ]) rotate([ BladeAngle, 0, 0 ])
                                translate(v = [ FanDiameter / 4, 0, 0 ]) cube(
                                    [
                                        FanDiameter / 2, (BladeHeigth + BladeThickness) / sin(BladeAngle),
                                        BladeThickness
                                    ],
                                    center = true);
                        }
                    }
                    cylinder(h = BladeHeigth, d = BladeRubDiamenter, center = false);
                }
                translate(v = [ 0, 0, BladeThickness ])
                    cylinder(h = BladeHeigth, d = BladeRubDiamenter - 2 * BladeThickness);
            }
        }
        // Furo do eixo
        cylinder(h = RubHeight + 1, d = AxisDiameter, center = false);
        // Furos de ventilação
        for (i = [0:5])
        {
            rotate([ 0, 0, i * 60 ]) translate(v = [ (MotorDiamenter + 2 * Clearence) / 3, 0, 0 ])
                cylinder(h = 3 * BladeThickness, r = (MotorDiamenter - BladeThickness) / 6, center = true);
        }
    }
    cylinder(h = BladeHeigth, d = FanDiameter, center = false);
}