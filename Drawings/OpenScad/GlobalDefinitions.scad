/**
 * Project Name :Pet-o-Nator
 *
 * Author: Carlos Eduardo Foltran
 * GitHub: [GitHub Repository URL]
 * Thingiverse: [Thingiverse Project URL]
 * License: Creative Commons CC0 1.0 Universal (CC0 1.0)
 * Description: This file must be included on all drawings
 *
 * Date Created: 2025-03-07
 * Last Updated: [Date of last modification]
 *
 * This OpenSCAD file is provided under the Creative Commons CC0 1.0 Universal (CC0 1.0) License.
 * You are free to use, modify, and distribute this design for any purpose, without any restrictions.
 *
 * For more details about the CC0 license, visit: https://creativecommons.org/publicdomain/zero/1.0/
 */

/************************************
*** Definições estruturais gerais ***
*************************************/
// Menor espessura de uma peça que suportará esforço mecânico

PartsMinThickness = 3;

// Espessura a ser usada onde surgirem bordas afiadas por cortes que gerem
//  ângulos menores que 45 graus, como em cones
Lip = 1;

/******************************
*** Dimensões das ferragens ***
*******************************/
// Diâmetro externo do cano de cobre usado como bronzina
CopperInsertDiameter = 6.35;

// Diâmetro do prego usado como eixo
StealAxisDiamenter = 4.5;

/****************************
*** Dimensões do carretel ***
*****************************/
// Estabelecendo a circunferência do carretel. Representa a quantidade de
// filamento recolhido por rotação
SpoolCircunfetence = 250;

// Estabelecendo a largura útil do carretel. O comprimento do parafuso
// eixo é calculado levando em conta este valor
SpoolUsefulWidth = 30;

// Estabelecendo a altura útil do carretel. Determina a quantidade de filamento
// recolhido.
SpoolUsefulHeight = 25;

// Calculando as dimensões vinculadas às pre estabelecidas

// Diametro esterno do centro do carretel
SpoolExternalDiameter = SpoolCircunfetence / PI;

// Diametro interno do cado centro do carretel
SpoolInternalDiameter = SpoolExternalDiameter - 4 * PartsMinThickness;

// A largura total do carretel é a largura útil mais a espessura de duas
// defenças
SpoolWidth = SpoolUsefulWidth + 2 * PartsMinThickness;

// Estabelece o diâmetro esterno da defença do carretel
SpoolFenseDiameter = SpoolExternalDiameter + 2 * SpoolUsefulHeight;

Gap = .25;

$fa = ($preview) ? $fa : 2;
$fs = ($preview) ? $fs : .2;

module ScrewM2(lenght = 10, passThrough = 4, deepness = 0)
{
    bodyD = 1.9;
    headD = 4.3;
    cylinder(h = deepness + .25, d = headD, center = false);
    rotate(a = [ 0, 180, 0 ])
    {
        // Corpo
        cylinder(h = lenght, d = bodyD, center = false);
        // Alargamento do furo para passar desempedido
        cylinder(h = passThrough, d = 2.2, center = false);
        // Cabeça do parafuso
        hull()
        {
            cylinder(h = .5, d = headD, center = true);
            cylinder(h = 1.5, d = bodyD, center = false);
        }
    }
}

module ScrewM3(lenght = 10, passThrough = 4, deepness = 0)
{
    bodyD = 2.6;
    headD = 5.5;
    cylinder(h = deepness + .25, d = headD, center = false);

    rotate(a = [ 0, 180, 0 ])
    {
        // Corpo
        cylinder(h = lenght, d = bodyD, center = false);
        // Alargamento do furo para passar desempedido
        cylinder(h = passThrough, d = 2.9, center = false);
        // Cabeça do parafuso
        hull()
        {
            cylinder(h = .5, d = headD, center = true);
            cylinder(h = 1.5, d = bodyD, center = false);
        }
    }
}