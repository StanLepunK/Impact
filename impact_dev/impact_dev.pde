/**
*
* Create a broken network like an bullet impact or spider web
* Stanislas Marçais alias Stan le Punk / Knupel
* v 0.1.0
* 2022-2022 copyleft (l)
* 
*/

R_Impact imp;
import rope.core.Rope;

Rope r = new Rope();

void setup() {
	size(800,800,P2D);
	imp = new R_Impact(this);
	impact_setup(imp);
}


void draw() {
	// float alpha_bg = map(abs(sin(frameCount * 0.002)),0,1, 0,20);
	// bg(r.BLACK, alpha_bg);
	background(r.GRIS[1]);
	// println("frameRate", (int)frameRate, imp.get_num_main(), imp.get_num_circle());
	

	switch(which_display(10)) {
		case 0 : show_polygon(1); impact_draw(); break;
		case 1 : imp.show_polygon_from(imp.get_polygons()); break;
		case 2 : impact_draw(); break;
		case 3 : show_polygon(1); break;
		case 4 : show_polygon(0); break;
		case 5 : show_polygon(-1); break;
		case 6 : show_polygon(1); impact_draw(); show_nodes(); break;
		case 7 : impact_draw(); show_nodes(); break;
		// case 7 : show_nodes(); break;
		case 8 : impact_draw(); break;
		case 9 : circle_draw(0); break;
		case 10 : circle_draw(1); break;
		// default : show_polygon(1); impact_draw(); imp.show_cloud(); break;
	}
	

	impact_update();

	
	String info = mouseX + " / " + mouseY;
	fill(r.CYAN);
	text(info, mouseX,mouseY);
}



void mousePressed() {
	println("---------------------------------- souris ::::::::::::::::::::::::: ----------- ::::>",mouseX,mouseY);
	int count = 0;
	for(R_Shape shape : imp.get_all_polygons()) {
		count++;
		int area_min = 20;
		vec3 [] arr = shape.get_points();
		
		if(r.in_polygon(shape, new vec2(mouseX,mouseY))) {
			println("shape #", count);
			int id_branch = shape.id().b();
			println("shape ", shape.id().a(), id_branch);
			printArray(arr);
			if(id_branch != -1) {
				if(imp.get_heart_lines().size() > 0) {
					println("line heart", imp.get_heart_lines().get(id_branch));
				}
			
				println("line branch circle from this pie:",id_branch);
				println("num branch circle on this pie",imp.get_branch_lines(id_branch, true).size());
				for(R_Line2D line : imp.get_branch_lines(id_branch, true)) {
					println("line circle",line, "len", line.dist());
				}
				int num_poly = 0;
				for(R_Shape shape_info : imp.get_polygons()) {
					if(shape_info.id().b() == id_branch) {
						num_poly++;
						// println("polygon");
						// printArray(shape_info.get_points());
					}
				}
				println("there is", num_poly, "polygons on branch", id_branch);
			} else {
				println("it's the heart by sweet heart");
			}

		}
	}
}

void keyPressed() {
	impact_keypressed();
}

// Utils background with alpha
//////////////////////////////

void bg(int colour, float alpha) {
	noStroke();
	fill(colour, alpha);
	rect(0,0,width, height);
}
