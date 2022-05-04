use <gear\gears.scad>
PartsMinThickness = 3;
MotorAxisDiameter = 3.2;
MotorGearThickness = 6;
IntermidiateGearAxis = 4;
IntermidiateGearThickness = 10;


NozzleHeight = 35;

//Parafuso M8 usado como eixo do carretel
ScrewAxisLength = 100;


//Estabelecendo a circunferência do carretel.  Representa a quantidade de filamento
//recolhido por rotação
SpoolCircunfetence = 250;

Gap = .25;

$fa=($preview)?$fa:1;
$fs=($preview)?$fs:.2;

//Dimensões do rolamento 608
Bearing608ExternalDiamenter = 22;
Bearing608InternalDiamenter = 8;
Bearing608MeanDiamenter = (Bearing608ExternalDiamenter + Bearing608InternalDiamenter) / 2;
Bearing608Width = 7;

//Dimensões do parafuso usado como eixo do hub do carretel
M8SwcreewHeadWidth = 6;
M8SwcreewLength = 105;
M8SwcreewNutWidth = 6.4;

//Calculando as dimensões vinculadas às pre estabelecidas

//Diametro esterno do centro do carretel
SpoolExternalDiameter = SpoolCircunfetence / PI;

//Diametro interno do cado centro do carretel
SpoolInternalDiameter = SpoolExternalDiameter - 4 * PartsMinThickness;

//A largura útil do carretel é calculada de acordo com o tamanho do parafuso eixo
SpoolUsefulWidth = 30;

//A largura total do carretel é a largura útil mais a espessura de duas defenças
SpoolWidth = SpoolUsefulWidth + 2 * PartsMinThickness;

//Estabelece o diâmetro esterno da defença do carretel
SpoolFenseDiameter = SpoolExternalDiameter + 2 * (2 * NozzleHeight / 3);

//Altura do hub central
HubHeigth = SpoolWidth + 2 * PartsMinThickness + IntermidiateGearThickness;
echo("Altura do hub=", HubHeigth);

//Definição da última engranagem
LastGearTeeth = floor(SpoolExternalDiameter + NozzleHeight);
echo("Numero de dentes da última engrenagem = ", LastGearTeeth);

module MotorGear(){
    rotate([0,0,18])
    //Ângulo de hélice para saida é -20 e entrada 20
    //Esta é uma engrenagem de saída
    herringbone_gear(modul=.75, tooth_number=10, width=6, bore=MotorAxisDiameter, pressure_angle=20, helix_angle=-20, optimized=false);
}

module FirstGear(){
    //Ângulo de hélice para saída é -20 e entrada 20
    //Esta é uma engrenagem de entrada
    herringbone_gear(modul=.75, tooth_number=66, width=MotorGearThickness, bore=IntermidiateGearAxis, pressure_angle=20, helix_angle=20, optimized=true);
    difference(){
        cylinder(d=17,h=MotorGearThickness+1);
        translate([0,0,-1])
        cylinder(d=IntermidiateGearAxis,h=MotorGearThickness+2);
    }
    translate([0,0,MotorGearThickness+1])
        //Ângulo de hélice para saída é -20 e entrada 20
        //Esta é uma engrenagem de saída
        herringbone_gear(modul=1, tooth_number=15, width=IntermidiateGearThickness, bore=IntermidiateGearAxis, pressure_angle=20, helix_angle=-20, optimized=false);
}

module Spool(FenseOnly=false){
    module Fense(){
        //Furos para diminuir o tanto de plástico gasto da defença
        HoleDiameter = (SpoolFenseDiameter - SpoolExternalDiameter) / 2 - 2 * PartsMinThickness;
        //Calculando quantos furos cabem na curcunferência média deixando espessura mínima
        MediumDiameter = (SpoolFenseDiameter + SpoolExternalDiameter) / 2;
        NumberOfHoles = floor((PI * MediumDiameter)/(HoleDiameter + PartsMinThickness));
        HoleAngle = 360 / NumberOfHoles;
        union(){
            difference(){
                cylinder(d=SpoolFenseDiameter-PartsMinThickness, h=PartsMinThickness, center=true);
                Fixtures();
                for(i = [0:NumberOfHoles-1]){
                    rotate([0, 0, i * HoleAngle])
                        translate([MediumDiameter/2,0,0])
                            cylinder(d=HoleDiameter,h=PartsMinThickness+1,center=true);
                }
                //Buracos para pender o filamento
                for(i = [0:NumberOfHoles-1]){
                    rotate([0, 0, (i + .5) * HoleAngle]){
                        translate([(SpoolExternalDiameter+PartsMinThickness)/2 ,0,0])
                            cylinder(d=PartsMinThickness,h=PartsMinThickness+1,center=true);
                        translate([SpoolFenseDiameter/2-1.5*PartsMinThickness,0,0])
                            cylinder(d=PartsMinThickness,h=PartsMinThickness+1,center=true);
                        }
                }
            }
            rotate_extrude(){
                translate([(SpoolFenseDiameter-PartsMinThickness)/2,0,0])
                    circle(d=PartsMinThickness);
            }
            for(i = [0:NumberOfHoles-1]){
                rotate([0, 0, i * HoleAngle])
                    translate([MediumDiameter/2,0,0])
                        rotate_extrude(){
                            translate([HoleDiameter/2,0,0])
                                circle(d=PartsMinThickness);
                        }
            }
        }    
    }

    module Fixtures(){
        cylinder(d=SpoolInternalDiameter + 2 * Gap, h=SpoolUsefulWidth + 1, center=true);
        for (i = [0:7]){
            rotate([0,0,i*22.5])
                cube([SpoolInternalDiameter + 2 * (Gap + PartsMinThickness), Gap + PartsMinThickness, SpoolUsefulWidth + 1], center=true);
        }
        for (i = [0:3]){
            rotate([0,0,i*90+11.75])
                translate([SpoolInternalDiameter/2+PartsMinThickness,0,0])
                    cylinder(d=2, h=SpoolUsefulWidth + 1, center=true);
        }
    }

    if (FenseOnly) {
        Fense();
    } else {
        union(){
            translate([0,0,-(SpoolUsefulWidth+PartsMinThickness)/2])
            Fense();
            difference(){
                cylinder(d=SpoolExternalDiameter, h=SpoolUsefulWidth, center=true);
                Fixtures();
            }
        }
    }
}


module SpoolGear(){
    
    
    difference(){
        union(){
            //Corpo da peça
            difference(){
                union(){
                    translate([0,0,PartsMinThickness + IntermidiateGearThickness / 2])
                        cylinder(d=SpoolInternalDiameter - 2 * Gap, h = SpoolWidth, center=true);
                    translate([0,0,-SpoolWidth/2])
                        cylinder(d=SpoolInternalDiameter + 3 * PartsMinThickness, h= 2 * PartsMinThickness + IntermidiateGearThickness, center=true);
                }        
                cylinder(d=SpoolInternalDiameter - 2 * PartsMinThickness, h = HubHeigth + 1, center=true);
            }
            //Aletas de fixação
            for (i = [0:3]){
                rotate([0,0,i*45])
                    cube([SpoolInternalDiameter + 2 * (PartsMinThickness - Gap), PartsMinThickness - Gap, HubHeigth], center=true);
            }
            //Eixo central
            cylinder(d=Bearing608ExternalDiamenter + 2 * PartsMinThickness, h = HubHeigth, center=true);
        }
        //Furo do eixo central
        cylinder(d=Bearing608MeanDiamenter + 2 * Gap, h = HubHeigth + 1, center = true);
        //Furos para os rolamentos
        translate([0,0,-HubHeigth/2-1])
            cylinder(d = Bearing608ExternalDiamenter + 2 * Gap, h = Bearing608Width + 1);
        //O furo para o rolamento superior deve conter a cabeça do parafuso usado como eixo
        translate([0,0,HubHeigth/2-Bearing608Width - M8SwcreewHeadWidth])
            cylinder(d = Bearing608ExternalDiamenter + 2 * Gap, h = Bearing608Width + M8SwcreewHeadWidth + 1);
    }
    //Engranagem
    //Ângulo de hélice para saida é -20 e entrada 20
    //Esta é uma engranagem de entrada
    translate([0,0,-HubHeigth/2])
    herringbone_gear(modul=1, tooth_number=LastGearTeeth, width=IntermidiateGearThickness, bore=SpoolInternalDiameter + 2 * PartsMinThickness, pressure_angle=20, helix_angle=20, optimized=false);

}

SpoolGear();