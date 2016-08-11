// Rotary encoder
shaft_radius = 3.2;
board_thickness = 1.7;
board_height = 10;
board_width = 80;
display_radius = 30;
// Inside box end
end_cap_overlap = 3;
end_cap_thickness = 5;
// Thumbwheel version settings
thumbwheel_overlap = 12;
thumbwheel_thickness = 8;

module board() {
    translate([-board_height/2,0,-board_thickness/2]) cube([board_height, board_width, board_thickness]);
}


module board_ring() {
  // Create all the boards
  for (i = [270/12 : 270/12 : 270]) {
    rotate(i, [0,1,0]) translate([0, 0, display_radius]) board();
  }
}

module end_cap(overlap, thickness) {
    difference() {
        rotate([90,0,0]) translate([0,0,-thickness]) difference() {
            cylinder(r=display_radius+overlap, h=thickness, $fn=18);
            translate([0,0,-thickness/2]) cylinder(r=shaft_radius, h=thickness*2);
        }
        #translate([0,thickness/2,0]) board_ring();
    }
}

translate([0,0,(thumbwheel_overlap+display_radius)*2]) end_cap(thumbwheel_overlap, thumbwheel_thickness);
//end_cap(end_cap_overlap, end_cap_thickness);
