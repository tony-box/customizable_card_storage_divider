/* 
Customizable dividers for card collections.

Original .scad file created by Zlomy https://www.thingiverse.com/thing:3329096/files

Changelog by fellowapeman https://www.printables.com/social/221869-fellowapeman/:
    - cleanup 
    - extra params added
    - modified to use 90deg tabs
    - modified to use hex grid to save material (and look cool!)
    - additional help text

In order to get the Hex grid to render, your OpenSCAD must have the BOSL2 library installed:
    - https://github.com/revarbat/BOSL2

The below hex grid modules were created by https://www.printables.com/social/50148-james-evans-the-mnmlmaker/about -- you can use them in your own project here! https://www.printables.com/model/86604-hexagonal-grid-generator-in-openscad/files

If you want to use MTG Set or Mana/Card Symbols:
    
    - Install MTG Set/Keyrune Fonts: https://keyrune.andrewgioia.com/
    - Install MTG Mana Symbol Fonts: https://mana.andrewgioia.com/
    
    ***IMPORTANT*** In Windows, OpenSCAD requires you to install fonts for ALL USERS in order to use them. Ensure you do this! Search google if you need help!

    After the font packs are installed for all users, input either "mana" or "keyrune" into the fontL or fontR parameters depending on which font you'd like to use. Then use andrewgioia's cheat sheets (see links below) to copy/paste the desired symbol into the textL or textR parameters.
    If everything was installed and configured properly, you should see the set symbols rendered in OpenSCAD!
    
    Cheat sheets can be found here:
    https://keyrune.andrewgioia.com/cheatsheet.html
    https://mana.andrewgioia.com/cheatsheet.html
    
*/
include <BOSL2/std.scad>

/* [Divider Properties] */

// Width of the divider. Default = 94 for BCW Boxes
width = 94;
// Height of the divider. Default = 64 for BCW Boxes
height = 64;
// Thickness of the divider. Also acts as the diameter of all the rounded edges. Default = 0.6
thickness = 1;
// Spacing between hexes
hexSpacing = 27;
// Wall widths
wallWidth = 3;
tabPositions = "both"; // [left,right,both,none]

/* [Left Tab Config] */
tabWidthL = 23;
tabHeightL = 9;
// Left tab's text. If using "mana" or "keyrune" fonts, copy/paste the icon from the appropriate andrewgioia cheatsheet
textL = "MIR";
// Left tab's font
fontL = "Liberation Sans";
// Left tab's font size
fontSizeL = 5;
// Left tab's text padding-left
tabPaddingLeftL = 1;
// Left tab's text padding-top
tabPaddingTopL = 2;

/* [Right Tab Config] */
// Right tab's width
tabWidthR = 12;
// Right tab's height
tabHeightR = 9;
// Right tab's text. If using "mana" or "keyrune" fonts, copy/paste the icon from the appropriate andrewgioia cheatsheet
textR = "";
// Right tab's font
fontR = "keyrune";
// Right tab's font size
fontSizeR = 6;
// Right tab's text padding-left
tabPaddingLeftR = 2;
// Right tab's text padding-bottom
tabPaddingTopR = 3.1;

////////////////////////////////////////////////////////////////////
// cell: takes three parameters and returns a single hexagonal cell
//
//   SW_hole: scalar value that specifies the width across the flats
//     of the interior hexagon
//   height: scalar value that specifies the height/depth of the 
//     cell (i.e. distance from from front to back
//   wall: scalar vale that specifies the thickness of the wall 
//     surrounding the interior hex (hole). e.g. if SW_hole is 8 
//     and wall is 2 then the total width across the flats of the
//     cell is 8 + 2(2) = 12.
////////////////////////////////////////////////////////////////////
module cell(SW_hole, height, wall) {
  tol = 0.001; // used to clean up difference artifacts
  difference() {
    cyl(d=SW_hole+2*wall,h=height,$fn=6,circum=true);
    cyl(d=SW_hole,h=height+tol,$fn=6,circum=true);
  }
}

////////////////////////////////////////////////////////////////////
// grid: takes three parameters and returns the initial grid of 
//    hexagons
//
//    size: 3-vector (x,y,z) that specifies the  size of the cube 
//      that contains the hex grid
//    cell_hole: scalar value specifying width across flats of the 
//      interior hexagon (hole)
//    cell_wall: scalar value that specifies wall thickness of the
//      hexagon
////////////////////////////////////////////////////////////////////
module grid(size,cell_hole,cell_wall) {
  dx=cell_hole*sqrt(3)+cell_wall*sqrt(3);
  dy=cell_hole+cell_wall;

  ycopies(spacing=dy,l=size[1])    
    xcopies(spacing=dx,l=size[0]) {
      cell(SW_hole=cell_hole,
           height=size[2],
           wall=cell_wall);
      right(dx/2)fwd(dy/2)
      cell(SW_hole=cell_hole,
          height=size[2],
          wall=cell_wall);
    }
 }

////////////////////////////////////////////////////////////////////
// mask: creates a mask that is used by the module create_grid()
//   The mask is used to remove extra cells that are outside the 
//   cube that holds the final grid
////////////////////////////////////////////////////////////////////
module mask(size) {
  difference() {
    cuboid(size=2*size);
    cuboid(size=size);
  }
}

////////////////////////////////////////////////////////////////////
// create_grid: creates a rectangular grid of hexagons with a border
//   thickness specified in the parameter (wall).
//
//   size: 3-vector (x,y,z) that specifies the length, width, and 
//     depth of the final grid
//   SW: scalar value that specifies the width across the flats of
//     the interior hexagon (the hole)
//   wall: scalar value that specifies the width of each hexagon's 
//     wall thickness and the thickness of the surrounding
//     rectangular frame
////////////////////////////////////////////////////////////////////
module create_grid(size,SW,wall) {
  b = 2*wall;
  union() {
    difference () {
      cuboid(size=size);
      cuboid(size=[size[0]-b,size[1]-b,size[2]+b]);
    }
  }
  
  difference() {
    grid(size=size,cell_hole=SW,cell_wall=wall);
    mask(size);
  }
}

////////////// Create the actual divider and tabs //////////////
module divider(width,thickness,height){
    totalHeight = height + thickness;
    translate([0, 0, thickness]) {
        rotate([0,0,0]) {
            create_grid(size=[width,height,thickness],SW=hexSpacing,wall=wallWidth);

            if (tabPositions == "left" || tabPositions == "both"){
                translate([-(width/2),height/2,-thickness/2]){
                        cube([tabWidthL,thickness,tabHeightL]);
                }
                translate([-(width/2)+tabPaddingLeftL,(height/2)+thickness,0+(tabHeightL/2)+tabPaddingTopL]) {
                    rotate([270,0,0]) {
                        linear_extrude(.4) {
                            text(text = str(textL), font = fontL, size = fontSizeL);
                        }
                    }
                }
            }
            if (tabPositions == "right" || tabPositions == "both"){
                translate([width/2-tabWidthR,height/2,-thickness/2]){
                    cube([tabWidthR,thickness,tabHeightR]);
                }
                translate([width/2-tabWidthR+tabPaddingLeftR,(height/2)+thickness,0+(tabHeightR/2)+tabPaddingTopR]) {
                    rotate([270,0,0]) {
                        linear_extrude(0.4) {
                            text(text = str(textR), font = fontR, size = fontSizeR);
                        }
                    }
                }
            }
        }
    }
}

divider(width,thickness,height);
