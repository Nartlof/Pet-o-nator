Diameter = 7;
Thick = 1;
Lenght = 15;
NozzleHigth = 35;
BlockBaseThickness = 5;
Screw = 4;

BlockHeigth = NozzleHigth+Diameter;
BlockBase = Screw*6+Diameter;


Gap = .25;

$fa=($preview)?$fa:1;
$fs=($preview)?$fs:.2;

module Channel(D, T, L){
    Di=D-2*Thick;    
    difference(){
        hull(){
            translate([-D/4,0,0])
                difference(){
                    cylinder(d=D,h=T,center=true);
                    cylinder(d=D-2*T, h=2*T,center=true);
                    translate([-D/2,0,0]){
                        cube([D,D+T,2*T],center=true);
                    }
                }
            translate([0,0,L]){
                cube([T,PI*D/2,T],center=true);
            }
        }
        translate([0,0,-Gap/2])
        hull(){
            translate([-D/4,0,0]){
                difference(){
                        cylinder(d=Di,h=T,center=true);
                    cylinder(d=Di-2*T, h=2*T,center=true);
                    translate([-(Di+T)/2,0,0]){
                        cube([Di,Di+T,2*T],center=true);
                    }
                }
                translate([-T/2,0,0])
                    cube([T,Di,T],center=true);    
            }
            translate([-T,0,L+Gap]){
                cube([T,PI*D/2,T],center=true);
            }
        }
    }
}


difference(){
    union(){
        translate([-Diameter/2,0,0])
            cube([Diameter,BlockHeigth,Lenght]);
        translate([0,BlockHeigth,0])
            cylinder(d=Diameter,h=Lenght);
        translate([-BlockBase/2,0,0])
            cube([BlockBase,BlockBaseThickness,Lenght]);
    }
    translate([0,NozzleHigth,0])
        Channel(Diameter, Thick, Lenght);
    for (i = [1,-1]){
        translate([i*(Diameter/2+1.5*Screw),-Gap,Lenght/2])
            rotate([-90,0,0])
                cylinder(d=Screw,h=BlockBaseThickness+2*Gap);
    }
}