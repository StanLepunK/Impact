import rope.vector.vec3;
import rope.mesh.R_Shape;

// Polygon list
ArrayList<R_Shape> imp_shapes_circle = new ArrayList<R_Shape>();
ArrayList<R_Shape> imp_shapes_heart = new ArrayList<R_Shape>();
ArrayList<R_Shape> imp_shapes_rest = new ArrayList<R_Shape>();
// help point list
ArrayList<vec3> imp_pts = new ArrayList<vec3>();

void polygon_build(R_Impact imp) {
	add_cloud_points(imp);
	build_polygon_impact(imp);
}





//////////
// ANNEXE
///////////


//////////////////////////////
// ANNEXE HELP 
// BUILD POINT
///////////////////////////////

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

///////////////////////
// ANNEXE BUILD POLYGON
////////////////////////

void build_polygon_impact(R_Impact imp) {
	println("NEW BUILD POLYGON====================================");
	ArrayList<vec2>poly = new ArrayList<vec2>();
	// clear polygon
	imp_shapes_circle.clear();
	imp_shapes_heart.clear();
	imp_shapes_rest.clear();

	int count_info = 0;
	int max_main = imp.get_num_main();
	// main branch by main branch
	for(int m_index = 0 ; m_index < max_main ; m_index++) {
		int im_0 = m_index;
		int im_1 = m_index+1;
		if(im_1 == max_main) {
			im_1 = 0;
		}
		build_single_basic_polygon_from_circle(im_0, im_1);
		build_single_polygon_from_heart(im_0, im_1);
		build_single_polygon_rest(im_0, im_1);
	}
	println("there is",imp_shapes_circle.size(),"basic polygons");
	println("there is",imp_shapes_heart.size(),"heart polygons");
	println("there is",imp_shapes_rest.size(),"rest polygons");
}


// POLYGON REST
/////////////////
void build_single_polygon_rest(int im_0, int im_1) {
	R_Shape shape = new R_Shape(this);
	shape.id(r.BLOOD);

	// find the last circle elem not mute and add it
	int max_circle = imp.get_num_circle()-1;
	boolean bingo_is = false;
	// go from the max to minimum
	for(int k = max_circle ; k >= 0 ; k--) {
		for(R_Line2DX lc : imp.get_circle(k)) {
			
			if(lc.id_a() == im_0 && !lc.mute_is()) {
				// println(lc, index_main, lc.id_a());
				create_polygon_rest(lc, shape, imp.get_main(im_0), imp.get_main(im_1));
				bingo_is = true;
				break;

			}
		}
		if(bingo_is) {
			break;
		}
	}
	imp_shapes_rest.add(shape);

}

void create_polygon_rest(R_Line2DX lc, R_Shape shape, ArrayList<R_Line2DX> main_a, ArrayList<R_Line2DX> main_b) {
	R_Line2DX lm_0 = main_a.get(main_a.size() -1);
	R_Line2DX lm_1 = main_b.get(main_b.size() -1);
	shape.add_points(lm_0.b(), lm_1.b());
	shape.add_points(lc.b(), lc.a());
	add_points_go(main_b, shape, false);
	add_points_return(main_a, shape, false);
}




// POLYGON CIRCLE
////////////////////
void build_single_basic_polygon_from_circle(int im_0, int im_1) {
	boolean bingo_is = false;
	int max_circle = imp.get_num_circle();
	for(int k = 0 ; k < max_circle ; k++) {
		bingo_is = false;
		for(R_Line2DX lc1 : imp.get_circle(k)) {
			if(lc1.id_a() == im_0 && !lc1.mute_is()) {
				for(int m = k + 1 ; m < max_circle ;m++) {
					for(R_Line2DX lc2 : imp.get_circle(m)) {
						if(lc2.id_a() == im_0 && !lc2.mute_is()) {
							create_polygon_circle(lc1, lc2, imp.get_main(im_0), imp.get_main(im_1));
							bingo_is = true;
							break;
						}
					}
					if(bingo_is) break;
				}
			}
			if(bingo_is) break;
		}
	}
}


void create_polygon_circle(R_Line2DX lc1, R_Line2DX lc2, ArrayList<R_Line2DX> main_a, ArrayList<R_Line2DX> main_b) {
	R_Shape shape = new R_Shape(this);
	shape.id(r.BLUE);
	shape.add_points(lc1.a(), lc1.b());
	shape.add_points(lc2.b(), lc2.a());
	add_points_go(main_b, shape, false);
	add_points_return(main_a, shape, false);
	imp_shapes_circle.add(shape);
}









//////////////////
// UTILS
///////////////////

// ADD POINT CLASSIC
////////////////////
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

// ADD POINT POLYGON
////////////////////
void add_points_go(ArrayList<R_Line2DX> lms, R_Shape shape, boolean swap_is) {
	float marge = 3;
	int first = 0;
	int last = 0;
	int index = 1;
	int index_next = shape.get_summits() -2;
	vec3 a = shape.get_point(index);
	vec3 b = shape.get_point(index_next);

	for(int i = 0 ; i < lms.size() ; i++) {
		if(r.in_line(lms.get(i).a(),lms.get(i).b(), a.xy(), marge)) {
			first = i;
		}
		if(r.in_line(lms.get(i).a(),lms.get(i).b(), b.xy(), marge)) {
			last = i;
		}
	}

	// the most of cases
	if(first < last) {
		for(int i = first ; i < last ; i++) {
			vec2 buf = lms.get(i).b();
			index++;
			shape.add_point(index, buf.x(), buf.y());
		}
	}
	// it's for the center, because the order is reverse
	else if(first > last) {
		int count = first;
		for(int i = last ; i < first ; i++) {
			// reverse the order to put the point where this nust be
			count--;
			vec2 buf = lms.get(count).b();
			index++;
			shape.add_point(index, buf.x(), buf.y());
		}
	}
}


void add_points_return(ArrayList<R_Line2DX> lms, R_Shape shape, boolean swap_is) {
	float marge = 3;
	int first = 0;
	int last = 0;
	int index = shape.get_summits() -1;
	int index_next = 0;
	vec3 a = shape.get_point(index);
	vec3 b = shape.get_point(index_next);

	for(int i = 0 ; i < lms.size() ; i++) {
		if(r.in_line(lms.get(i).a(),lms.get(i).b(), a.xy(), marge)) {
			first = i;
		}
		if(r.in_line(lms.get(i).a(),lms.get(i).b(), b.xy(), marge)) {
			last = i;
		}
	}

	// the most of cases
	if(first > last) {
		for(int i = first ; i > last ; i--) {
			vec2 buf = lms.get(i).a();
			index++;
			shape.add_point(index, buf.x(), buf.y());
		}
	}
	// it's for the center, because the order is reverse
	else if(last > first) {
		int count = first;
		for(int i = last ; i > first ; i--) {
			// reverse the order to put the point where this nust be
			count++;
			vec2 buf = lms.get(count).a();
			index++;
			shape.add_point(index, buf.x(), buf.y());
		}
	}
}










////////////////////:
// SHOW
///////////////////



void show_polygon() {
	show_polygon_from(imp_shapes_circle);
	show_polygon_from(imp_shapes_heart);
	show_polygon_from(imp_shapes_rest);
}

void show_polygon_from(ArrayList<R_Shape> list) {
	stroke(r.YELLOW);
	for(R_Shape shape : list) {
		if(shape.id()!= 0) {
			fill(shape.id());
		} else {
			fill(r.MAGENTA);
		}
		beginShape();
		for(int i = 0 ; i < shape.get_summits() ; i++) {
			vertex(shape.get_x(i), shape.get_y(i));
		}
		endShape(CLOSE);
	}
}



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