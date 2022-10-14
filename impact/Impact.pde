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
	// println("frameRate", (int)frameRate, "alpha bg",alpha_bg);
	// noFill();
	// stroke(255);
	// strokeWeight(1);
	switch(which_display(10)) {
		// case 0 : imp.show_line(); break; // ok
		// case 1 : imp.show_line_branch(1); break;
		// case 2 : imp.show_line_branch(2); break;
		// case 3 : imp.show_line_branch(3); break;
		// case 4 : imp.show_line_branch(4); break;
		// case 5 : imp.show_line_branch(5); break;
		// case 6 : imp.show_line_branch(6); break;

		// case 0 : imp.show_line(); break; // ok
		// case 1 : imp.show_line_circle(1); break;
		// case 2 : imp.show_line_circle(2); break;
		// case 3 : imp.show_line_circle(3); break;
		// case 4 : imp.show_line_circle(4); break;
		// case 5 : imp.show_line_circle(5); break;
		// case 6 : imp.show_line_circle(6); break;

		case 0 : show_polygon(1); impact_draw(); break;
		case 1 : imp.show_polygon_from(imp.get_orphan_polygons()); break;
		case 2 : impact_draw(); break;
		case 3 : show_polygon(1); break;
		case 4 : show_polygon(0); break;
		case 5 : show_polygon(-1); break;
		case 6 : show_polygon(1); impact_draw(); imp.show_cloud(); break;
		case 7 : impact_draw(); imp.show_cloud(); break;
		case 8 : impact_draw(); break;
		case 9 : circle_draw(0); break;
		case 10 : circle_draw(1); break;
		// default : show_polygon(1); impact_draw(); imp.show_cloud(); break;
	}

	String info = mouseX + " / " + mouseY;
	fill(r.CYAN);
	text(info, mouseX,mouseY);
}

void mousePressed() {
	println("---------------------------------- souris ::::::::::::::::::::::::: ----------- ::::>",mouseX,mouseY);
	int count = 0;
	for(R_Shape shape : imp.get_polygons()) {
		count++;
		int area_min = 20;
		vec3 [] arr = shape.get_points();
		if(arr.length > 0 && arr[0].compare(arr[1], 2)) {
			println("shape #", count, "les deux premiers sont égaux",arr[0],arr[1]);
		}
		// if(shape.area() < area_min) {
		// 	println("shape #", count, "inferior to",area_min);
		// 	println("shape.area()",shape.area());
		// 	printArray(shape.get_points());
		// }
		if(r.in_polygon(shape, new vec2(mouseX,mouseY))) {
			println("shape #", count, "id", shape.id(), "clicked polygon");
			println("shape.area()",shape.area());
			printArray(arr);
		}
	}
}

void keyPressed() {
	impact_keypressed();
	//println("which_display()",which_display());
}

// Utils background with alpha
//////////////////////////////

void bg(int colour, float alpha) {
	noStroke();
	fill(colour, alpha);
	rect(0,0,width, height);
}
