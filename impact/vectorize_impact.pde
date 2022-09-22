import rope.vector.vec3;
import rope.mesh.R_Shape;
ArrayList<vec3> imp_pts = new ArrayList<vec3>();
ArrayList<R_Shape> imp_shapes_circle = new ArrayList<R_Shape>();
ArrayList<R_Shape> imp_shapes_heart = new ArrayList<R_Shape>();

void vectorize_build(R_Impact imp) {
	add_cloud_points(imp);
	build_polygon_impact(imp);
}


void vectorize_show() {
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
	println("circle total",imp.get_num_circle());
	ArrayList<vec2>poly = new ArrayList<vec2>();
	// clear polygon
	imp_shapes_circle.clear();
	imp_shapes_heart.clear();

	int count_info = 0;
	int max_main = imp.get_num_main();
	// main branch by main branch
	for(int m_index = 0 ; m_index < max_main ; m_index++) {
		// println("------------- MAIN ---------------------------",m_index);
		int main1 = m_index;
		int main2 = m_index+1;
		if(main2 == max_main) {
			main2 = 0;
		}
		build_single_basic_polygon_from_circle(m_index, main1, main2, imp.get_num_circle());
		build_single_polygon_from_heart(m_index, main1, main2);
	}
	println("there is",imp_shapes_heart.size(),"polygons");
}

// POLYGON HEART
void build_single_polygon_from_heart(int index_m, int main1, int main2) {
	boolean heart_is = false;
	R_Line2DX lh = null;
	R_Line2DX lc = null;

	// SPIRAL
	// if(imp.get_circle(0).size() > 0 && index < imp.get_circle(0).size()) {
	// 	println("CIRCLE SPIRAL   main index",index);
	// 	lc = imp.get_circle(0).get(index);
	// }

	// REGULAR
	boolean bingo_is = false;
	for(int index_c = 1 ; index_c < imp.get_num_circle() ; index_c++) { // why k must be 1 ????
		if(imp.get_heart().size() > 0 && index_m < imp.get_heart().size()) {
			lh = imp.get_heart().get(index_m);
		}

		if(imp.get_circle(index_c) != null && imp.get_circle(index_c).size() > 0) {
			for(int index_lc = 0 ; index_lc < imp.get_circle(index_c).size() ; index_lc++) {
				lc = imp.get_circle(index_c).get(index_lc);
				if(lc.id_a() == index_m) { // break temporary
				// if(lc.id_a() == m_index && !lc.mute_is()) { // break temporary
					println("BINGO main", index_m, "circle", index_c, "id", lc.id_a(), "coord", lc);
					bingo_is = true;
					break; 
				}
			}
		}
		if(bingo_is) {
			bingo_is = false;
			break;
		}
	}

	// algo is here
	if(lc != null) {
		// println("main", m_index, "heart", lh, "circle",lc);
		create_polygon_center(lh, lc, imp.get_main(main1), imp.get_main(main2));
	}
}

void create_polygon_center(R_Line2DX lh, R_Line2DX lc, ArrayList<R_Line2DX> main_a, ArrayList<R_Line2DX> main_b) {
	R_Shape shape = new R_Shape(this);
	float marge = 3;
	println("root lc to create polygon", lc);
	shape.add_points(lc.a(), lc.b()); // may be need to switch if that's meet main a or main b
	shape.add_point(imp.pos().x(), imp.pos().y()); // test point to center impact

	// check if lc meet any main a or b
	boolean lc_a_is = false;
	boolean lc_b_is = false;
	boolean main_a_is = false;
	boolean main_b_is = false;
	// check main a
	for(int i = 1 ; i < main_a.size() ; i++) { // avoid the first element because the heart is active
		R_Line2DX lm_a = main_a.get(i);
		lc_a_is = r.in_line(lm_a.a(), lm_a.b(), lc.a(), marge);
		lc_b_is = r.in_line(lm_a.a(), lm_a.b(), lc.b(), marge);
		if(lc_a_is || lc_b_is) {
			main_a_is = true;
			// shape.add_points(lm_a.a(), lh.a());
			// shape.add_points(lm_a.a(), lh.b()); // reverse the starting point heart
			break;
		}
	}

	// check main b
	for(int i = 1 ; i < main_b.size() ; i++) { // avoid the first element because the heart is active
		R_Line2DX lm_b = main_b.get(i);
		lc_a_is = r.in_line(lm_b.a(), lm_b.b(), lc.a(), marge);
		lc_b_is = r.in_line(lm_b.a(), lm_b.b(), lc.b(), marge);
		if(lc_a_is || lc_b_is) {
			main_b_is = true;
			// shape.add_points(lm_b.a(), lh.b());
			// shape.add_points(lm_b.a(), lh.a()); // reverse the starting point heart
			break;
		}
	}

	// if there a meeting

	



	// algo is here
	imp_shapes_heart.add(shape);
}




// POLYGON CIRCLE
void build_single_basic_polygon_from_circle(int index, int main1, int main2, int max_circle) {
	boolean done_is = false;
	for(int k = 0 ; k < max_circle ; k++) {
		done_is = false;
		for(R_Line2DX lc1 : imp.get_circle(k)) {
			if(lc1.id_a() == index && !lc1.mute_is()) {
				for(int m = k + 1 ; m < max_circle ;m++) {
					for(R_Line2DX lc2 : imp.get_circle(m)) {
						if(lc2.id_a() == index && !lc2.mute_is()) {
							create_polygon_from_circle(lc1, lc2, imp.get_main(main1), imp.get_main(main2));
							done_is = true;
							break;
						}
					}
					if(done_is) break;
				}
			}
			if(done_is) break;
		}
	}
}

@Deprecated ArrayList<R_Line2DX> get_heart_plus_main(ArrayList<R_Line2DX> original, int index) {
	ArrayList<R_Line2DX> buf = new ArrayList<R_Line2DX>(original);
	boolean heart_is = false;
	if(index < imp.get_heart().size()) {
		R_Line2DX heart_line = imp.get_heart().get(index);
		heart_is = true;
		buf.add(0,heart_line);
	}
	return buf;
}




void create_polygon_from_circle(R_Line2DX l1, R_Line2DX l2, ArrayList<R_Line2DX> main_a, ArrayList<R_Line2DX> main_b) {
	R_Shape shape = new R_Shape(this);
	shape.add_points(l1.a(), l1.b());
	add_points_go(l1.b(),l2.b(), main_b, shape);
	shape.add_points(l2.b(), l2.a());
	add_points_return(l2.a(),l1.a(), main_a, shape);
	imp_shapes_circle.add(shape);
}



void add_points_go(vec2 a, vec2 b, ArrayList<R_Line2DX> lines, R_Shape shape) {
	float marge = 3;
	int first = 0;
	int last = 0;
	for(int i = 0 ; i < lines.size() ; i++) {
		if(r.in_line(lines.get(i).a(),lines.get(i).b(), a, marge)) {
			first = i;
		}
		if(r.in_line(lines.get(i).a(),lines.get(i).b(), b, marge)) {
			last = i;
		}
	}
	
	if(first < last) {
		int count = 0;
		for(int i = first ; i < last ; i++) {
			vec2 buf = lines.get(i).b();
			shape.add_point(buf.x(), buf.y());
			count++;
		}
	}
}

void add_points_return(vec2 a, vec2 b, ArrayList<R_Line2DX> lines, R_Shape shape) {
	float marge = 3;
	int first = 0;
	int last = 0;
	for(int i = 0 ; i < lines.size() ; i++) {
		if(r.in_line(lines.get(i).a(),lines.get(i).b(), a, marge)) {
			first = i;
		}
		if(r.in_line(lines.get(i).a(),lines.get(i).b(), b, marge)) {
			last = i;
		}
	}

	
	if(first > last) {
		int count = 0;
		for(int i = first ; i > last ; i--) {
			vec2 buf = lines.get(i).a();
			shape.add_point(buf.x(), buf.y());
			count++;
		}
	}
	
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