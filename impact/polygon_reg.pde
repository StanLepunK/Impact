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
	
	
	show_polygon_from(imp_shapes_circle);
	show_polygon_from(imp_shapes_heart);
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


//////////
// ANNEXE
///////////


/////////////////////
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

///////////////////////
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
	add_points_go(main_b, shape);
	add_points_return(main_a, shape);
	imp_shapes_circle.add(shape);
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
void add_points_go(ArrayList<R_Line2DX> lines, R_Shape shape) {
	int index = 1;
	vec3 a = shape.get_point(index);
	vec3 b = shape.get_point(shape.get_summits() -2);
	println("b",b);
	float marge = 3;
	int first = 0;
	int last = 0;
	for(int i = 0 ; i < lines.size() ; i++) {
		if(r.in_line(lines.get(i).a(),lines.get(i).b(), a.xy(), marge)) {
			first = i;
		}
		if(r.in_line(lines.get(i).a(),lines.get(i).b(), b.xy(), marge)) {
			last = i;
		}
	}
	
	if(first < last) {
		for(int i = first ; i < last ; i++) {
			vec2 buf = lines.get(i).b();
			index++;
			shape.add_point(index, buf.x(), buf.y());
		}
	}
}


void add_points_return(ArrayList<R_Line2DX> lines, R_Shape shape) {
	int index = shape.get_summits() -1;
	vec3 a = shape.get_point(index);
	vec3 b = shape.get_point(0);
	float marge = 3;
	int first = 0;
	int last = 0;
	for(int i = 0 ; i < lines.size() ; i++) {
		if(r.in_line(lines.get(i).a(),lines.get(i).b(), a.xy(), marge)) {
			first = i;
		}
		if(r.in_line(lines.get(i).a(),lines.get(i).b(), b.xy(), marge)) {
			last = i;
		}
	}

	if(first > last) {
		int count = 0;
		for(int i = first ; i > last ; i--) {
			vec2 buf = lines.get(i).a();
			index++;
			shape.add_point(index, buf.x(), buf.y());
			count++;
		}
	}
}