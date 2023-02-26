module roundCube(size = [ 10, 10, 10 ], r = 0, d = 0, center = false) {
  R1 = r > 0 ? r : d > 0 ? d / 2 : 0;
  Size = size[0] == undef ? [ size, size, size ] : size;
  R = min(R1, min(Size / 2 - .001 * [ 1, 1, 1 ]));
  MinkSize = Size - 2 * R * [ 1, 1, 1 ];
  Center = center == true || center == false ? center : false;
  Translation = Center ? -Size / 2 : [ 0, 0, 0 ];
  translate(Translation) translate(R * [ 1, 1, 1 ]) minkowski() {
    cube(MinkSize);
    sphere(r = R);
  }
}
/*
module roundCube(size = [10, 10, 10], r = 0, d = 0, center = false){
    R = r > 0 ? r : d > 0 ? d/2 : 0;
    Size = size[0] == undef ? [size, size, size] : size;
    Center = center == true || center == false ? center : false;
    Translation = center ? -Size / 2 : [0, 0, 0];
    translate(Translation){
        union(){
            for (i = [0, 1]){
                for (j = [0, 1]){
                    for (k = [0, 1]){
                        translate([R + i*(Size[0]-2*R),
                                   R + j*(Size[1]-2*R),
                                   R + k*(Size[2]-2*R)])
                            sphere(r = R);
                        if (i + j + k == 2){
                            TrVec = R * [i, j, k];
                            LocAxis = [1, 1, 1] - [i, j, k];
                            RotMatrix = [[LocAxis[2], LocAxis[0], LocAxis[1]],
                                         [LocAxis[1], LocAxis[2], LocAxis[0]],
                                         [LocAxis[0], LocAxis[1], LocAxis[2]],];
                            LocVec = RotMatrix * Size;
                            //echo(TrVec, LocAxis, LocVec);
                            translate(TrVec)
                                cube(Size - 2 * TrVec);
                            rotate([90,0,90] * LocAxis[0] + [ 0, -90, -90] *
LocAxis[1]) for (x = [0, 1]){ for (y = [0, 1]){ translate([R + x *
(LocVec[0]-2*R), R + y * (LocVec[1]-2*R), R]) cylinder(r = R, h = Size * LocAxis
- 2 * R);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
*/
roundCube([ 300, 200, 100 ], r = 30, center = true, $fa = 1);