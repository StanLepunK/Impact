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
	switch(which_display()) {
		case 0 : show_polygon(1); impact_draw(); break;
		case 1 : impact_draw(); break;
		case 2 : show_polygon(1); break;
		case 3 : show_polygon(0); break;
		case 4 : show_polygon(-1); break;
		case 5 : show_polygon(1); impact_draw(); imp.show_cloud(); break;
		case 6 : impact_draw(); imp.show_cloud(); break;
		default : show_polygon(1); impact_draw(); imp.show_cloud(); break;
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
			println("shape #", count, "clicked polygon");
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
