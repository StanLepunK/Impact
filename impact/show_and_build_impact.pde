

void impact_setup(R_Impact imp) {
	impact_build();	
	imp.pixel_mode(2);
	imp.use_mute(true);
	// print_setting();
}

void impact_draw() {
	if(use_pixels_is) {
		show_lines_pixel();
	} else {
		show_lines();
	}
}


void circle_draw(int mode) {
	noFill();
	strokeWeight(4);
	if(mode == 0) {
		float start_colour = g.colorModeX - (g.colorModeX / 4);
		float step_colour = g.colorModeX / imp.get_num_circle() / 2;
		for(int i = 0 ; i < imp.get_num_circle() ; i++) {
			stroke(start_colour -= step_colour);
			imp.show_line_circle(i);
		}
	} else if (mode == 1) {
		float start_colour = g.colorModeX - (g.colorModeX / 4);
		float step_colour = g.colorModeX / imp.get_num_circle() / 2;
		for(int i = 0 ; i < imp.get_num_main() ; i++) {
			stroke(start_colour -= step_colour);
			imp.show_line_branch(i);
		}
	}
}



// BUILD
/////////////////
void impact_build() {
	imp.build_struct(width/2, height/2);
	imp.set_pixels(0.3, r.RED);
	impact_build_polygon();
}

void impact_build_polygon() {
	set_mute_circle();
	imp.build_polygon();
}

// NODES
////////////////////

void update_nodes(R_Node node, float diam) {
	if(node.id().a() == 0) {
		vec3 mouse = new vec3(mouseX, mouseY, 0);
		if(node.pos().compare(mouse, diam * 0.5)) {
			if(mousePressed) {
				node.pos(mouse.xy());
			}
			fill(r.MAGENTA);
		} else {
			noFill();
		}
	}
}

void show_nodes() {
	// imp.show_nodes(); basic show who depend of the id node
	noFill();
	stroke(r.WHITE);
	for(R_Node node : imp.get_nodes()) {
		float size = node.id().b();
		update_nodes(node, size);
		switch(node.id().a()) {
			case 0:
				stroke(r.CYAN);
				circle(node.x(), node.y(), size);
				break;
			case 1:
				stroke(r.MAGENTA);
				circle(node.x(), node.y(), size);
				break;
			case 2:
				stroke(r.YELLOW);
				circle(node.x(), node.y(), size);
				break;
			default:
				stroke(r.WHITE);
				circle(node.x(), node.y(), size);
				break;
		}
	}
}




// SHOW POLYGON
void show_polygon(int mode) {
	imp.show_polygon(mode);
}


// SHOW LINE
///////////////
void show_lines() {
	boolean show_heart_is = true;
	noFill();
	stroke(r.WHITE);
	strokeWeight(1);
	if(imp.get_heart_lines().size() > 0 && show_heart_is) {
		int max = imp.get_main_lines(0).size();
		imp.show_line_main(1, max);
		// imp.show_line_main(0,1);
	} else {
		imp.show_line_main();
	}
	stroke(r.YELLOW);
	imp.show_line_circle();
	
	if(show_heart_is) {
		stroke(r.GREEN);
		imp.show_line_heart();
	}


	if(show_error_is) {
		stroke(r.RED);
		imp.show_line_fail();
		stroke(r.WHITE);
		imp.show_bug();
	}
}

// SHOW PIXEL
/////////////
void show_lines_pixel() {
	imp.show_pixels_main(0.1, r.CYAN, r.CYAN, r.MAGENTA);
	imp.show_pixels_circle(0.1, r.MAGENTA, r.MAGENTA ,r.YELLOW);
	imp.show_pixels_heart(0.1, r.YELLOW, r.YELLOW, r.YELLOW, r.MAGENTA);
	// imp.show_pixels();
	// imp.show_pixels_main();
	// imp.show_pixels_circle();
	// imp.show_pixels_heart();
}


// SET MUTE
/////////////////

void set_mute_main() {
	int [] list_size = imp.get_size_main();
	for(int i = 0 ; i < imp.get_num_main() ; i++) {
		for(int k = 0 ; k < list_size[i] ; k++) {
			float choice = random(1);
			imp.set_mute_main(i, k, false);
			if(choice < 0.5) {
				imp.set_mute_main(i, k, true);
			}
		}
	}
}

void set_mute_circle() {
	int [] list_size = imp.get_size_circle();
	for(int i = 0 ; i < imp.get_num_circle() ; i++) {
		for(int k = 0 ; k < list_size[i] ; k++) {
			float choice = random(1);
			imp.set_mute_circle(i, k, false);
			if(choice < 0.5) {
				imp.set_mute_circle(i, k, true);
			}
		}
	}
}






