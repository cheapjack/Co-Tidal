// Rotary encoder
board_thickness = 3;
board_height = 10;
board_width = 80;
display_radius = 30;
end_cap_overlap = 3;
end_cap_thickness = 5;
shaft_radius = 3;

module board() {
    translate([-board_height/2,0,-board_thickness/2]) cube([board_height, board_width, board_thickness]);
}


module board_ring() {
  // Create all the boards
  for (i = [270/12 : 270/12 : 270]) {
    rotate(i, [0,1,0]) translate([0, 0, display_radius]) board();
  }
}

difference() {
  rotate([90,0,0]) translate([0,0,-end_cap_thickness/2]) difference() {
      cylinder(r=display_radius+end_cap_overlap, h=end_cap_thickness);
      translate([0,0,-end_cap_thickness/2]) cylinder(r=shaft_radius, h=end_cap_thickness*2);
  }
  #board_ring();
}