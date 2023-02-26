/*
*Author: Eduardo Foltran
*All dimensions are in mm
*Date: 2020-05-31
*Version: 1.0 - Initial design
*License: Creative Commons CC-BY (Attribution)
*Thingiverse: https://www.thingiverse.com/thing:NotPublisheYet
*Visit my portifolio at
*https://www.thingiverse.com/EduardoFoltran/designs
*Inspired on a design by Russell Cantos
*https://www.slideshare.net/RussellCantos/shopdrawing-hand-grinder
*Original PDF avaliable on Thingiverse
*/

//MType, Diametro, espessura
    Sizes=[
            [1.6,3.2,1.3], //M1.6
            [2,4.00,1.6], //M2
            [2.5,5,2], //M2.5
            [3,6,2.4], //M3
            [4,7,3.2], //M4
            [5,8,4.7], //M5
            [6,10,5.2], //M6
            [8,13,6.8], //M8
            [10,15,9.1], //M10
            [12,19,10]  //M12
            ];

function GetType(M=3,i=0) = (i == len(Sizes))?[0,0,0]:(M == Sizes[i][0])?Sizes[i]:GetType(M = M, i = i + 1);
function GetThickness(M=3) = GetType(M = M)[2];
function GetWidth(M=3) = GetType(M = M)[1];
function GetMaxWidth(M=3) = GetWidth(M = M)*2*sqrt(3)/3;

module MNut(M=3, Insert=0, Folga=0){
    i=GetType(M);    
    D=(i[1]+Folga)*2*sqrt(3)/3;
    translate([0,0,-Folga/2]){
        cylinder(d=D,h=i[2]+Folga,$fn=6);
        if (Insert!=0){
            L=i[1]+Folga;
            translate([0,-L/2,0])
                cube([Insert,L,i[2]+Folga]);
        }
    }
}

MNut(5,10,0);