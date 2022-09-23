import rope.vector.vec3;
import rope.mesh.R_Shape;
ArrayList<vec3> imp_pts = new ArrayList<vec3>();
ArrayList<R_Shape> imp_shapes_circle = new ArrayList<R_Shape>();
ArrayList<R_Shape> imp_shapes_heart = new ArrayList<R_Shape>();

void polygon_build(R_Impact imp) {
	add_cloud_points(imp);
	build_polygon_impact(imp);
}


void polygon_show() {
	stroke(r.YELLOW);
	fill(r.MAGENTA);
	// show_polygon_from(imp_shapes_circle);
	show_polygon_from(imp_shapes_heart);
}

void show_polygon_from(ArrayList<R_Shape> list) {
	for(R_Shape shape : list) {
		beginShape();
		for(int i = 0 ; i < shape.get_summits() ; i++) {
			vertex(shape.get_x(i), shape.get_y(i));
		}
		endShape(CLOSE);
	}
}


//////////
// ANNEXE
///////////



// ANNEXE BUILD POINT
//////////////////////

void add_cloud_points(R_Impact imp) {
	imp_pts.clear();
	int family = 0;
	// main point
	for(int i = 0 ; i < imp.get_num_main() ; i++) {
		family = 0;
		add_points(imp.get_main(i), imp, family);
	}

	// circle point
	for(int i = 0 ; i < imp.get_num_circle() ; i++) {
		family = 1;
		add_points(imp.get_circle(i), imp, family);
	}
	// heart
	family = 2;
	add_points(imp.get_heart(), imp, family);
	if(imp.get_heart_polygon() != null) {
		vec2 [] polygon = imp.get_heart_polygon();
	} else {
		imp_pts.add(new vec3(imp.pos().x(),imp.pos().y(),family));
	}
}


// ANNEXE BUILD POLYGON
////////////////////////

void build_polygon_impact(R_Impact imp) {
	println("NEW BUILD POLYGON====================================");
	ArrayList<vec2>poly = new ArrayList<vec2>();
	// clear polygon
	imp_shapes_circle.clear();
	imp_shapes_heart.clear();

	int count_info = 0;
	int max_main = imp.get_num_main();
	// main branch by main branch
	for(int m_index = 0 ; m_index < max_main ; m_index++) {
		// println("------------- MAIN ---------------------------",m_index);
		int im_0 = m_index;
		int im_1 = m_index+1;
		if(im_1 == max_main) {
			im_1 = 0;
		}
		build_single_basic_polygon_from_circle(im_0, im_1);
		build_single_polygon_from_heart(im_0, im_1);
	}
	// println("there is",imp_shapes_circle.size(),"basic polygons");
	println("there is",imp_shapes_heart.size(),"heart polygons");
}








////////////////////:
// ANNEXE SHOW
///////////////////

void show_impact_cloud() {
	noFill();
	stroke(r.WHITE);
	for(vec3 p : imp_pts) {
		switch((int)p.z()) {
			case 0:
				stroke(r.CYAN);
				circle(p.x(), p.y(), 15);
				break;
			case 1:
				stroke(r.MAGENTA);
				circle(p.x(), p.y(), 15);
				break;
			case 2:
				stroke(r.YELLOW);
				circle(p.x(), p.y(), 15);
				break;
			default:
				stroke(r.WHITE);
				circle(p.x(), p.y(), 15);
				break;
		}
	}
}



//////////////////
// UTILS
///////////////////

void add_points(ArrayList<R_Line2DX> list, R_Impact imp, int family) {
	float marge = 3;
	for(R_Line2DX line : list) {
		// check the center
		boolean a_is = imp.pos().compare(line.a(), new vec2(marge));
		boolean b_is = imp.pos().compare(line.b(), new vec2(marge));
		if(r.all((r.any(r.all(!a_is, !b_is, !line.mute_is()),!imp.use_mute_is())),!a_is,!b_is)) { // that's work but too much complex
			vec3 a = new vec3(line.a().x(), line.a().y(), family);
			imp_pts.add(a);
			vec3 b = new vec3(line.b().x(), line.b().y(), family);
			imp_pts.add(b);
		}
	}
}