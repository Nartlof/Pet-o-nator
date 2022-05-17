Thickness = 2;
Stiffener = 6;
ExternalDiameter = 220;
InternalDiameter = 100;
Rollers = 8;
RollersDiameter = 10;
RollersAxis = 1.6;
Screws = 4;
ScrewTotalLength = 52;
ScrewDiameter = 3.5;
ScrewHeadDiameter = 7;
ScrewHeadThickness = 3;
ScrewPostDiameter = max(3*ScrewDiameter,ScrewHeadDiameter+Thickness);
ScrewLength = ScrewTotalLength - 2 * ScrewHeadThickness;

RadialRollerHeigth = (ExternalDiameter-InternalDiameter)/2-4*Thickness;

Gap = .25;


$fa=($preview)?$fa:1;
$fs=($preview)?$fs:.2;



module AxialRoller(){
    difference(){
        cylinder(d=RollersDiameter, h=ScrewLength-2*Thickness-3*Gap, center=true);
        cylinder(d=RollersAxis, h=ScrewLength, center=true);
    }
}

module RarialRoller(){
    difference(){
        translate([0,0,-RadialRollerHeigth/2])
        intersection(){
            cylinder(d1=RollersDiameter, d2=0, h=ExternalDiameter-4*Thickness);
            cylinder(d=RollersDiameter,h=RadialRollerHeigth);
        }
        cylinder(d=RollersAxis, h=RadialRollerHeigth+1, center=true);
    }
}

module Disk(){
    module PlaceScrews(){
        Angle = 360/Screws;
        for (i=[0:Screws-1]){
            rotate([0,0,(i+0.5)*Angle])
                translate([ExternalDiameter/2,0,0])
                    children();
        }
    }

    module PlaceAxialRollers(){
        Angle = 360/Rollers;
        for (i=[0:Rollers-1]){
            rotate([0,0,(i+0.5)*Angle])
                translate([ExternalDiameter/2,0,0])
                    children();
        }
    }

    module PlaceRadialRollers(){
        Angle = 360/Rollers;
        for (i=[0:Rollers-1]){
            rotate([0,0,(i+.25)*Angle])
                translate([(ExternalDiameter+InternalDiameter)/4,0,0])
                    children();
        }
    }


    module AxialRollerSupport(){
        rotate_extrude(){
            translate([RollersDiameter/2+Thickness,0,0]){
                circle(d=Thickness);
                translate([0,Stiffener-Thickness,0])
                    circle(d=Thickness);
                translate([-Thickness/2,0])
                    square([Thickness,Stiffener-Thickness]);
            }
            translate([RollersAxis/2,-Thickness/2])
                square([RollersDiameter/2+Thickness-RollersAxis/2,Thickness]);
        }
    }

    module RadialRollerSupport(){
        for(j=[-1,1]){
            translate(j*[(RadialRollerHeigth+Thickness+2*Gap)/2,0,0])
                rotate([0,0,90]) translate([0,0,RollersAxis]) rotate([90,0,0]){
                    rotate_extrude(angle=180)
                        union(){
                            translate([RollersDiameter/2,0])
                                circle(d=Thickness);
                            translate([RollersAxis/2+Gap,-Thickness/2])
                                square([(RollersDiameter-RollersAxis-2*Gap)/2,Thickness]);        
                    }
                    for(i=[-1,1]){
                        translate([i*RollersDiameter/2,0,0])
                        rotate([90,0,0])
                        cylinder(d=Thickness,h=RollersAxis);
                    }
                    translate(-1*[RollersDiameter/2,RollersAxis,Thickness/2])
                    cube([RollersDiameter,RollersAxis,Thickness]);
                }
        }
    }

    AxialDiameter = ExternalDiameter-Thickness;
    AxialWidht = (ExternalDiameter-InternalDiameter)/2-Thickness;
    AxialStiff = Stiffener-Thickness;
    //Disco principal
    difference(){
        union(){
            rotate_extrude(){
                translate([(InternalDiameter+Thickness)/2,0,0]){
                    for (i=[0,1]){
                        translate([AxialWidht,0,0]*i){            
                        circle(d=Thickness);
                            translate([0, AxialStiff, 0]) 
                                circle(d=Thickness);
                        translate([-Thickness/2,0,0])
                            square([Thickness,AxialStiff]);
                        }
                    }
                    translate([0,-Thickness/2,0])
                        square([AxialWidht, Thickness]);
                }
            }
            //Base
            translate([0,-AxialDiameter/4,0]){
                difference(){
                    cube([AxialDiameter,AxialDiameter/2,Thickness],center=true);
                    translate([0,AxialDiameter/4,0])
                        cylinder(d=InternalDiameter+4*Thickness,h=2*Thickness,center=true);
                }
                //Enrijecedores da base
                translate([0,-AxialDiameter/4,AxialStiff/2])
                    cube([AxialDiameter,Thickness,AxialStiff],center=true);
                for(i=[0,1]){
                    translate([i*AxialDiameter-AxialDiameter/2,0,AxialStiff/2]){
                        cube([Thickness,AxialDiameter/2,AxialStiff], center=true);
                        translate([0,-AxialDiameter/4,0])
                            cylinder(d=Thickness,h=AxialStiff,center=true);
                    }
                    translate([0,0,i*AxialStiff]){
                        translate([0,-AxialDiameter/4,0])
                            rotate([0, 90, 0])
                                cylinder(d=Thickness, h=AxialDiameter, center=true);
                        for (j=[1,-1]){
                            translate([j*AxialDiameter/2,0,0])
                                rotate([90,0,0]){
                                    cylinder(d=Thickness,h=AxialDiameter/2,center=true);
                                    translate([0,0,AxialDiameter/4])
                                        sphere(d=Thickness);
                                }
                        }
                    }
                }
            }
            //Suporte dos parafusos
            PlaceScrews()
                rotate_extrude() union(){
                    translate([(ScrewPostDiameter-Thickness)/2,0,0])
                        circle(d=Thickness);
                    translate([ScrewDiameter/2,0,0])    {
                        square([(ScrewPostDiameter-ScrewDiameter)/2,(ScrewLength-Thickness)/2]);
                        translate([0,-Thickness/2])
                            square([(ScrewPostDiameter-ScrewDiameter-Thickness)/2,Thickness]);
                    }
                }
            
            //Suportes dos rollers axiais
            difference(){
                PlaceAxialRollers()
                    AxialRollerSupport();
                cylinder(d=ExternalDiameter-Thickness, h=Stiffener);
            }
            //Suportes radiais
            translate([0,0,Thickness/2])
            PlaceRadialRollers()
                RadialRollerSupport();
            //Enrigecedor dos furos de economia
            rotate([0,0,360/Rollers/2])
                PlaceRadialRollers()
                    cylinder(d=(ExternalDiameter-InternalDiameter)/4+2*Thickness,h=Stiffener/2);
            //Enrogecedor dos furos dos roletes radiais
            RadialAngle = asin(((RollersDiameter+Thickness)/2)/((ExternalDiameter-2*Thickness)/2));
            RadialCorrection = asin((Thickness/2)/((ExternalDiameter-InternalDiameter-Thickness)/2));
            for (i=[-1,1])
                rotate([0,0,i*RadialAngle])
                    PlaceRadialRollers(){
                        translate([0,Thickness*i,Stiffener/4])
                            rotate([0,0,-i*RadialCorrection])
                                cube([(ExternalDiameter-InternalDiameter-Thickness)/2,Thickness,Stiffener/2],center=true);
            }

        }
        //Furos
        //Furos dos parafusos
        PlaceScrews(){
            translate([0,0,-Thickness/2-1]){
                cylinder(d=ScrewDiameter, h=ScrewLength);
            }
        }
        //Furos para os rollers axiais
        PlaceAxialRollers(){
            translate([0,0,-Thickness])
                cylinder(d=RollersAxis+2*Gap,h=2*Thickness);
            translate([0,0,Thickness/2])
                cylinder(d=RollersDiameter+Thickness, h=Stiffener);
        }
        //Furos para os rollers radiais
        PlaceRadialRollers()
            translate([0,0,(Thickness+RollersAxis)/2+Gap])
                rotate([0,90,0]){
                    cylinder(d=RollersAxis+2*Gap,h=RadialRollerHeigth+6*Thickness,center=true);
                    cylinder(d2=RollersDiameter+Thickness, d1=(RollersDiameter+Thickness)*(InternalDiameter+8*Thickness)/(ExternalDiameter-8*Thickness)+Thickness,h=RadialRollerHeigth+2*Gap,center=true);
                }
        //Furos para gastar menos plástico
        rotate([0,0,360/Rollers/2])
        PlaceRadialRollers()
            cylinder(d=(ExternalDiameter-InternalDiameter)/4,h=4*Thickness,center=true);
    }
    //PlaceRadialRollers()
    //    translate([0,0,Thickness])
    //    rotate([0,-90,0])
    //    RarialRoller();

    //translate([0,0,ScrewLength/2-Thickness/2])
    //    PlaceAxialRollers() color("red") AxialRoller();
    
}


//Disk();
AxialRoller();
//RarialRoller();


