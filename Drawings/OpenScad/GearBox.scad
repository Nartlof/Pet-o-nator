use <gear\gears.scad>
MotorAxisDiameter = 3.2;
MotorGearThickness = 6;
IntermidiateGearAxis = 4;
IntermidiateGearThickness = 10;

module MotorGear(){
    rotate([0,0,18])
    herringbone_gear(modul=.75, tooth_number=10, width=6, bore=MotorAxisDiameter, pressure_angle=20, helix_angle=20, optimized=false);
}

module FirstGear(){
    
    herringbone_gear(modul=.75, tooth_number=66, width=MotorGearThickness, bore=IntermidiateGearAxis, pressure_angle=20, helix_angle=-20, optimized=true);
    difference(){
        cylinder(d=17,h=MotorGearThickness+1);
        translate([0,0,-1])
        #cylinder(d=IntermidiateGearAxis,h=MotorGearThickness+2);
    }
    translate([0,0,MotorGearThickness+1])
        herringbone_gear(modul=1, tooth_number=15, width=IntermidiateGearThickness, bore=IntermidiateGearAxis, pressure_angle=20, helix_angle=-20, optimized=false);
}

//MotorGear();
//translate([5*.75+33*.75,0,0])
FirstGear();