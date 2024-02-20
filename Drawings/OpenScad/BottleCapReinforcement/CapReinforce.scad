/**
 * Project Name :Pet-o-Nator
 *
 * Author: Carlos Eduardo Foltran
 * GitHub: [GitHub Repository URL]
 * Thingiverse: [Thingiverse Project URL]
 * License: Creative Commons CC0 1.0 Universal (CC0 1.0)
 * Description: This is an reinforcement for the bottle caps. The original cap must be glued inside
 *
 * Date Created: 2023-11-14
 * Last Updated: 2023-11-14
 *
 * This OpenSCAD file is provided under the Creative Commons CC0 1.0 Universal (CC0 1.0) License.
 * You are free to use, modify, and distribute this design for any purpose, without any restrictions.
 *
 * For more details about the CC0 license, visit: https://creativecommons.org/publicdomain/zero/1.0/
 */

CapExternalDiamenter = 50.5;
CapHeigth = 13;
CapThickness = 1.2;
ValveDiameter = 15;
ValveRequiredThickness = 3;

$fa = ($preview) ? $fa : 2;
$fs = ($preview) ? $fs : .2;

ReinforcementThickness = ValveRequiredThickness - CapThickness;
ReinforcementDiamenter = CapExternalDiamenter + 2 * ReinforcementThickness;
ReinforcementHeigth = CapHeigth + ReinforcementThickness;

difference()
{
    cylinder(h = ReinforcementHeigth, d = ReinforcementDiamenter, center = false);
    translate(v = [ 0, 0, ReinforcementThickness ])
    {
        cylinder(h = ReinforcementHeigth, d = CapExternalDiamenter, center = false);
    }
    translate(v = [ 0, 0, -1 ])
    {
        cylinder(h = ReinforcementThickness + 2, d = ValveDiameter, center = false);
    }
}