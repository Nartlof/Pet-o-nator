/*
*Author: Eduardo Foltran
*Desing by Eduardo Foltran
*Date: 2020-12-29
*License: Creative Commons CC-BY (Attribution)
*Thingiverse: https://www.thingiverse.com/thing:4701547
*Visit my portifolio at
*https://www.thingiverse.com/EduardoFoltran/designs

This library can generate any plug derived from the IEC 60906 standard by just fitting 
the appropriated dimensions. The default dimensions are those from the Brazilian NBR14136
standard. The use is more or less self explanatory.

      +------------Width----------+   
      |  _______________________  | _______+
      | /                       \ |        |
       /                         \         |
      <     O               O     >      Height
       \            G            /         |
        \_______________________/   _______+    



*/

module PlugNBR14136(Width = 35.5, Height = 17.0, OtoO = 19.0, 
        OtoG = 3.0, IncludeGround = true, RadiusSmall = 1.0, 
        RadiusLarge = 5.0, PinDiameter = 4.0, PlugHeigth = 10.0){

    Cos45 = cos(45);
    ReducedWith = Width - 2 * RadiusSmall;
    RedudedHeigth = Height - 2 * RadiusSmall;
    ReducedDiagonal = ReducedWith * Cos45;
    ReducedRadius = RadiusLarge - RadiusSmall;
    Diagonal = ReducedDiagonal + 2 * RadiusSmall;

    //$fa =  $preview ? $fa : 1;
    //$fs =  $preview ? $fs : .2;

    DiagonalSmallSquare = RedudedHeigth - 2 * ReducedRadius * (1 - Cos45);
    SideSmallSquare = DiagonalSmallSquare * Cos45;
    CentralRectangleWidth = ReducedWith - DiagonalSmallSquare - 2 * (ReducedRadius * Cos45);

    linear_extrude(height=PlugHeigth, convexity = 20){
        difference(){
            minkowski() {
                union(){
                    //Central Rectangle
                    square([CentralRectangleWidth,RedudedHeigth], center = true);
                    //Two small squares
                    rotate([0,0,-45]) {
                            for (i = [-1, 1]){
                            translate([i, i] * (ReducedDiagonal - SideSmallSquare) / 2) {
                                square(SideSmallSquare, center = true);
                            }
                        }
                    }
                    //Four circles of radius ReducedRadius
                    for (i = [-1, 1] * (RedudedHeigth / 2 - ReducedRadius)){
                        for (j = [-1, 1] * CentralRectangleWidth / 2){
                            translate([j, i])
                                circle(r = ReducedRadius);
                        }
                    }
                }
                circle(r = RadiusSmall);
            }
            for (i = [-1, 1] * OtoO / 2){
                translate([i,0])
                    circle(d = PinDiameter);
            }
            if (IncludeGround) {
                translate([0, OtoG])
                    circle(d = PinDiameter);
            }
        }
    }
}

PlugNBR14136();