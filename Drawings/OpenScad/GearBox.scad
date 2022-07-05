use <gear\gears.scad>
PartsMinThickness = 3;
MotorDiameter = 32;
MotorAxisDiameter = 3.2;
MotorGearThickness = 6;
MotorGearTeeth = 10;
MotorGearModulus = .75;
IntermidiateGearAxis = 4;
IntermidiateGearBushing = 6.35;
IntermidiateGearThickness = 10;
InterGearGap = 1;
FirstGearModulus = 2;
IRSensorDiameter = 5;


NozzleHeight = 35;

//Parafuso M8 usado como eixo do carretel
ScrewAxisLength = 100;


//Estabelecendo a circunferência do carretel.  Representa a quantidade de filamento
//recolhido por rotação
SpoolCircunfetence = 250;

Gap = .25;

$fa=($preview)?$fa:1;
$fs=($preview)?$fs:.2;

//A direção da engrenagem determina o angulo da hélice
Outwards = 1;
Inwards = -1;

//Dimensões do rolamento 608
Bearing608ExternalDiamenter = 22;
Bearing608InternalDiamenter = 8;
Bearing608MeanDiamenter = (Bearing608ExternalDiamenter + Bearing608InternalDiamenter) / 2;
Bearing608Width = 7;

//Dimensões do parafuso usado como eixo do hub do carretel
M8SwcreewHeadWidth = 6;
M8SwcreewLength = 105;
M8SwcreewNutWidth = 6.4;
M8SwcreewNutDiameter = 14.6;
M8SwcreewDiameter = 7.8;

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

//Definição das engranagens de saída. Deve ser um número par.
ExitGearTeeth = 16;

//Definição da primeira engranagem, que se atrala ao carretel.
FirstGearTeeth = floor((SpoolExternalDiameter + NozzleHeight)/FirstGearModulus)*FirstGearModulus;
SecondGearTeeth = floor(FirstGearTeeth - (Bearing608ExternalDiamenter + PartsMinThickness - ExitGearTeeth/2));
ThirdGearTeeth = floor(SecondGearTeeth - ExitGearTeeth/2);
FourthGearTeeth = floor((ThirdGearTeeth - ExitGearTeeth/2)/MotorGearModulus);
echo("Numero de dentes da engrenagem do hub= ", FirstGearTeeth);
echo("Ganho mecânico 1 = ", FirstGearTeeth/ExitGearTeeth);
echo("Numero de dentes da engrenagem 2= ", SecondGearTeeth);
echo("Ganho mecânico 2 = ", SecondGearTeeth/ExitGearTeeth);
echo("Numero de dentes da engrenagem 3= ", ThirdGearTeeth);
echo("Ganho mecânico 3 = ", ThirdGearTeeth/ExitGearTeeth);
echo("Numero de dentes da engrenagem 4= ", FourthGearTeeth);
echo("Ganho mecânico 4 = ", FourthGearTeeth/MotorGearTeeth);
//Distancias entre os eixos das engrenages
    Distance1to2 = (FirstGearTeeth+ExitGearTeeth)/2;
    Distance2to3 = (SecondGearTeeth+ExitGearTeeth)/2;
    Distance3to4 = (ThirdGearTeeth+ExitGearTeeth)/2;
    Distance4ToM = MotorGearModulus * (FourthGearTeeth + MotorGearTeeth)/2;

//Modulos de posicionamento
module PositionFirstGear(){
    translate([0,0,0]) children();
}

module PositionSecondGear(){
    //A segunda engrenagem é posicionada de modo que sua parte inferior fique à mesma altura da engrenagem 1
    Angle = 180 + asin((FirstGearTeeth - SecondGearTeeth)/(2 * Distance1to2));
    PositionFirstGear(){
        translate([cos(Angle),sin(Angle),0]*Distance1to2)
            children();
    }
}

module PositionThirdGear(){
    MinimalDistance1to3 = (FirstGearTeeth + ThirdGearTeeth + 6)/2;
    Angle = 180;//acos((Distance1to2^2+Distance2to3^2-MinimalDistance1to3^2)/(2 * Distance1to2 * Distance2to3));
    PositionSecondGear()
            translate([cos(Angle),sin(Angle),0]*Distance2to3)
                children();
}

module PositionFourthGear(){
    MinimalDistance2to4 = (SecondGearTeeth + ExitGearTeeth + 6)/2;
    Angle = 180 - acos((Distance2to3^2+Distance3to4^2-MinimalDistance2to4^2)/(2 * Distance2to3 * Distance3to4));
    PositionThirdGear()
        rotate([0,0,Angle])
            translate([Distance3to4,0,0])
                children();
}

module ExitGear(AxisDiameter = IntermidiateGearAxis, Direction = Outwards, Elevation = -1, Modulus = 1){
    Elev = (Elevation == -1) ? InterGearGap+IntermidiateGearThickness : Elevation;
    translate([0,0,Elev])
        herringbone_gear(modul=Modulus, tooth_number=ExitGearTeeth/Modulus, width=IntermidiateGearThickness, bore=AxisDiameter, pressure_angle=20, helix_angle=-20*Direction, optimized=false);
    difference(){
        cylinder(d=ExitGearTeeth+2, h = Elev);
        translate([0,0,-.5])
        cylinder(d=AxisDiameter, h = Elev + 1);
    }
}

module MotorGear(){
    //Diametro do disco sensor
    SensorDiscDiameter = MotorDiameter + 2*IRSensorDiameter + 4*PartsMinThickness;
    SensorHolesRadius = MotorDiameter/2 + PartsMinThickness+ IRSensorDiameter/2;
    Holes = floor((2*PI*SensorHolesRadius)/(2*IRSensorDiameter));
    Angle = 360/Holes;
    //Ângulo de hélice para saida é -20 e entrada 20
    //Esta é uma engrenagem de saída
    translate([0,0,InterGearGap])
        herringbone_gear(modul=MotorGearModulus, tooth_number=MotorGearTeeth, width=6, bore=MotorAxisDiameter, pressure_angle=20, helix_angle=Inwards*-20, optimized=false);
    difference(){
        union(){
            cylinder(d=(MotorGearTeeth+2)*MotorGearModulus, h=InterGearGap);
            cylinder(d=SensorDiscDiameter, h=InterGearGap/2);
        }
        //Eixo
        translate([0,0,-InterGearGap/2])
        cylinder(d=MotorAxisDiameter, h=2*InterGearGap);
        //Furos do sensor
        for (i=[0:Holes-1]){
            rotate([0,0,i*Angle])
                translate([SensorHolesRadius,0,0])
                    cylinder(d=IRSensorDiameter, h=2*InterGearGap,center=true);
        }
    }

}

module FourthGear(){
    Axis = FourthGearTeeth*MotorGearModulus - 5 * PartsMinThickness;
    CoreDiameter = Axis + PartsMinThickness;
    //Calculando os furos para o sensor óptico
    LdrDiameter = 6;
    HoleRadius = Axis/2 - PartsMinThickness - LdrDiameter/2;
    NumberOfHoles = floor(((2*PI*HoleRadius)/LdrDiameter)/2);
    HoleAngle = 360/NumberOfHoles;
    HoleSize = (2*PI*HoleRadius)/(2*NumberOfHoles);
    //Esta é a parte do miolo que contem os furos para o sensor óptico para controle do motor
    translate([ 0, 0, MotorGearThickness/4]) {
        difference(){
            cylinder(d=CoreDiameter, h=MotorGearThickness/2, center=true);
            cylinder(d=IntermidiateGearAxis, h=MotorGearThickness/2+1, center=true);
            //Furos para o sensor óptico
                for (i = [0:NumberOfHoles-1]){
                    rotate([0,0,i*HoleAngle])
                        translate([HoleRadius,0,0])
                            cylinder(d=LdrDiameter, h=MotorGearThickness/2+1, center=true);
    }
        }
    }
    //Ângulo de hélice para saída é -20 e entrada 20
    //Esta é uma engrenagem de entrada
    herringbone_gear(modul=MotorGearModulus, tooth_number=FourthGearTeeth, width=MotorGearThickness, bore=Axis, pressure_angle=20, helix_angle=20*Outwards, optimized=false);
    ExitGear(Direction=Outwards, Elevation = MotorGearThickness + IntermidiateGearThickness + 2 * InterGearGap);
}

module ThirdGear(){
    Axis = IntermidiateGearAxis;
    //Ângulo de hélice para saida é -20 e entrada 20
    //Esta é uma engranagem de entrada
    herringbone_gear(modul=1, tooth_number=ThirdGearTeeth, width=IntermidiateGearThickness, bore=Axis, pressure_angle=20, helix_angle=20*Inwards, optimized=true);
    ExitGear(AxisDiameter = Axis, Direction = Inwards);
}

module SecondGear(){
    Axis = IntermidiateGearAxis;
    //Ângulo de hélice para saida é -20 e entrada 20
    //Esta é uma engranagem de entrada
    herringbone_gear(modul=1, tooth_number=SecondGearTeeth, width=IntermidiateGearThickness, bore=Axis, pressure_angle=20, helix_angle=20*Outwards, optimized=true);
    ExitGear(AxisDiameter = Axis, Direction = Outwards, Modulus = FirstGearModulus);
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
        cylinder(d=SpoolInternalDiameter + 3 * Gap, h=SpoolUsefulWidth + 1, center=true);
        for (i = [0:7]){
            rotate([0,0,i*22.5])
                cube([SpoolInternalDiameter + 2 * (2*Gap + PartsMinThickness), 2*Gap + PartsMinThickness, SpoolUsefulWidth + 1], center=true);
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
        translate([0,0,SpoolUsefulWidth/2+PartsMinThickness])
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

//Peça principal que suporta o carretel e a engrenagem primária
module SpoolGear(){
    translate([0,0,HubHeigth/2]){   
        difference(){
            union(){
                //Corpo da peça
                difference(){
                    union(){
                        //Chanfro de encaixe
                        translate([0,0,(SpoolWidth + 2 * PartsMinThickness + IntermidiateGearThickness)/2-PartsMinThickness])
                            cylinder(d1=SpoolInternalDiameter - 2 * Gap, d2=SpoolInternalDiameter - PartsMinThickness, h=PartsMinThickness);
                        //Cilindro central
                        translate([0,0,(PartsMinThickness + IntermidiateGearThickness / 2)-PartsMinThickness/2])
                            cylinder(d=SpoolInternalDiameter - 2 * Gap, h = SpoolWidth-PartsMinThickness, center=true);
                        //Base
                        translate([0,0,-SpoolWidth/2])
                            cylinder(d=SpoolInternalDiameter + 3 * PartsMinThickness, h= 2 * PartsMinThickness + IntermidiateGearThickness, center=true);
                    }        
                    cylinder(d=SpoolInternalDiameter - 2 * PartsMinThickness, h = HubHeigth + 1, center=true);
                }
                //Aletas de fixação
                for (i = [0:3]){
                    rotate([0,0,i*45]){
                        //Aletas principais de encaixe
                        translate([0,0,-PartsMinThickness])
                            cube([SpoolInternalDiameter + 2 * (PartsMinThickness - Gap), PartsMinThickness - Gap, HubHeigth-2*PartsMinThickness], center=true);
                        //Aletas internas de suporte
                        cube([SpoolInternalDiameter - PartsMinThickness - Gap, PartsMinThickness - Gap, HubHeigth], center=true);
                        //Chanfros de encaixe
                        for (i=[0,1]){
                            rotate([0,0,i*180])
                                translate([(SpoolInternalDiameter-Gap)/2,0,(SpoolWidth + 2 * PartsMinThickness + IntermidiateGearThickness)/2-2*PartsMinThickness])
                                    scale([(2*PartsMinThickness-Gap)/(PartsMinThickness-Gap),1,1])
                                        rotate([0,0,45]) 
                                            cylinder(d1=sqrt(2) * (PartsMinThickness-Gap), d2=0, h=PartsMinThickness, $fn=4);
                        }
                    }
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
        herringbone_gear(modul=FirstGearModulus, tooth_number=FirstGearTeeth/FirstGearModulus, width=IntermidiateGearThickness, bore=SpoolInternalDiameter + 2 * PartsMinThickness, pressure_angle=20, helix_angle=20, optimized=false);
    }
}

module SpoolGearAxis(){
    AxisHeigth = HubHeigth - 2 * Bearing608Width - M8SwcreewHeadWidth + Gap;
    translate([0,0,AxisHeigth/2])
    difference(){
        cylinder(d = Bearing608MeanDiamenter - 2 * Gap, h=AxisHeigth, center=true);
        cylinder(d = M8SwcreewDiameter + 2 * Gap, h=AxisHeigth + 1, center=true);
    }
}

module M8Swcreew(){
    
    cylinder(d=M8SwcreewDiameter,h=M8SwcreewLength);
    cylinder(d=M8SwcreewNutDiameter,h=M8SwcreewNutWidth, $fn=6);
    translate([0,0,M8SwcreewLength-M8SwcreewHeadWidth])
        cylinder(d=M8SwcreewNutDiameter,h=M8SwcreewHeadWidth, $fn=6);

}

module Assembly(){

    module Head(){    
        module CompleteSpool(){
            Spool();
            translate([0,0,SpoolUsefulWidth+1.5*PartsMinThickness])
                Spool(true);
        }
        translate([0,0,IntermidiateGearThickness + 2 * PartsMinThickness])
        //color("blue") 
            %CompleteSpool();
        SpoolGear();
        translate([0,0,HubHeigth-M8SwcreewLength])
        color("black")
            M8Swcreew();
    }
    PositionFirstGear()
        Head();
    PositionSecondGear()
        translate([0,0,-IntermidiateGearThickness-InterGearGap])
            //color("red") 
                %SecondGear();
    PositionThirdGear()
        translate([0,0, IntermidiateGearThickness])
            rotate([180,0,0])
                color("green") ThirdGear();
    PositionFourthGear()
        translate([0, 0, -IntermidiateGearThickness - 2 * InterGearGap - MotorGearThickness]) 
            color("gray")
                FourthGear();
        
}

module Spacer(dIn = 10, dOut = 4, h = 1){
    difference(){
        cylinder(d = dOut, h = h, center = true);
        cylinder(d = dIn, h = h + 1, center = true);
    }
}

//rotate([90,0,0]) Assembly();
//SpoolGear();
//SecondGear();
//ThirdGear();
//FourthGear();
//ExitGear();
MotorGear();

//Espaçador para a engrenagem primária
//Spacer(dIn=M8SwcreewDiameter+4*Gap, dOut = Bearing608MeanDiamenter - 2*Gap, h=IntermidiateGearThickness+3*InterGearGap + MotorGearThickness);

//Espaçador para a segunda e terceira engrenagens
//Spacer(dIn=IntermidiateGearAxis+2*Gap, dOut = ExitGearTeeth - 2*Gap, h=MotorGearThickness+2*InterGearGap);

//Espaçador frontal
//Spacer(dIn=IntermidiateGearAxis+2*Gap, dOut = ExitGearTeeth - 2*Gap, h=InterGearGap);

//Espaçador dos parafusos

//Spacer(dIn=3.5, dOut=10, h=MotorGearThickness+2*IntermidiateGearThickness+4*InterGearGap);

//translate([0,0,Bearing608Width])
//SpoolGearAxis();
