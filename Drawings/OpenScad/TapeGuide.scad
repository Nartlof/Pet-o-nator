TapeThick = 1;
TapeWidth = 20;
BlockMinThickness = 5;
Lenght = 15;
NozzleHigth = 35;
Screw = 4;

BlockBaseThickness = BlockMinThickness;
BlockThickness = BlockMinThickness + TapeThick;
BlockHeigth = NozzleHigth + TapeWidth/2;
BlockBase = Screw  * 6 + BlockThickness;


Gap = .25;

$fa=($preview)?$fa:1;
$fs=($preview)?$fs:.2;

difference(){
    union(){
        translate([-BlockThickness/2,0,0])
            cube([BlockThickness,BlockHeigth,Lenght]);
        translate([0,BlockHeigth,0])
            cylinder(d=BlockThickness,h=Lenght);
        translate([-BlockBase/2,0,0])
            cube([BlockBase,BlockBaseThickness,Lenght]);
    }
    translate([0,NozzleHigth,Lenght/2])
        cube([TapeThick, TapeWidth, Lenght+1],center=true);
    for (i = [1,-1]){
        translate([i*(BlockThickness/2+1.5*Screw),-Gap,Lenght/2])
            rotate([-90,0,0])
                cylinder(d=Screw,h=BlockBaseThickness+2*Gap);
    }
}