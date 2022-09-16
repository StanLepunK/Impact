import rope.vector.vec3;
import rope.mesh.R_Shape;
ArrayList<vec3> imp_pts = new ArrayList<vec3>();
ArrayList<R_Shape> imp_shapes = new ArrayList<R_Shape>();

void vectorize_build(R_Impact imp) {
	add_cloud_points(imp);
	build_polygon_impact(imp);
}


void vectorize_show() {
	stroke(r.YELLOW);
	fill(r.MAGENTA);
	for(R_Shape shape : imp_shapes) {
		beginShape();
		for(int i = 0 ; i < shape.get_summits() ; i++) {
			vertex(shape.get_x(i), shape.get_y(i));
		}
		endShape(CLOSE);
	}
}

void add_cloud_points(R_Impact imp) {
	imp_pts.clear();
	int family = 0;
	// heart

	// the rest
	for(int i = 0 ; i < imp.get_num_main() ; i++) {
		family = 0;
		add_points(imp.get_main(i), imp, family);
	}
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


void build_polygon_impact(R_Impact imp) {
	boolean done_is = false;
	ArrayList<vec2>poly = new ArrayList<vec2>();
	imp_shapes.clear();
	int count_info = 0;
	int max_main = imp.get_num_main();
	// main branch by main branch
	for(int i = 0 ; i < max_main ; i++) {
		int main1 = i;
		int main2 = i+1;
		if(main2 == max_main) main2 = 0;
		// now go deep to find the basic shape
		for(int k = 0 ; k < imp.get_num_circle() ; k++) {
			done_is = false;
			for(R_Line2DX lc1 : imp.get_circle(k)) {
				if(lc1.id_a() == i && !lc1.mute_is()) {
					for(int m = k + 1 ; m < imp.get_num_circle() ;m++) {
						for(R_Line2DX lc2 : imp.get_circle(m)) {
							if(lc2.id_a() == i && !lc2.mute_is()) {
								create_polygon(lc1, lc2, imp.get_main(main1), imp.get_main(main2));
								done_is = true;
								break;
							}
							count_info++;
						}
						if(done_is) break;
					}
				}
				if(done_is) break;
			}
		}
	}
	println("combien d'itération:", count_info);
}

void create_polygon(R_Line2DX l1, R_Line2DX l2, ArrayList<R_Line2DX> main_a, ArrayList<R_Line2DX> main_b) {
	R_Shape shape = new R_Shape(this);
	shape.add_points(l1.a(), l1.b());
	add_points_go(l1.b(),l2.b(), main_b, shape);
	shape.add_points(l2.b(), l2.a());
	add_points_return(l2.a(),l1.b(), main_a, shape);
	
	// shape.add_points(l1.a(), l1.b(), l2.b(), l2.a()); // OK
	imp_shapes.add(shape);
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
		for(int i = first ; i < last ; i++) {
			// vec2 buf = lines.get(i).a(); // may be the choice of the point is not the good one
			vec2 buf = lines.get(i).b();
			shape.add_point(buf.x(), buf.y());
		}
	}
}

void add_points_return(vec2 a, vec2 b, ArrayList<R_Line2DX> lines, R_Shape shape) {
	float marge = 3;
	int first = 0;
	int last = 0;
	for(int i = lines.size() -1 ; i >= 0 ; i--) {
		if(r.in_line(lines.get(i).a(),lines.get(i).b(), a, marge)) {
			first = i;
		}
		if(r.in_line(lines.get(i).a(),lines.get(i).b(), b, marge)) {
			last = i;
		}
	}

	if(first > last) {
		for(int i = first ; i < last ; i--) {
			// vec2 buf = lines.get(i).b(); // may be the choice of the point is not the good one
			vec2 buf = lines.get(i).a();
			shape.add_point(buf.x(), buf.y());
		}
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



//////////////////
// UTILS
///////////////////

void add_points(ArrayList<R_Line2DX> list, R_Impact imp, int family) {
	float marge = 3;
	// r.print_err("------------------------------");
	for(R_Line2DX line : list) {
		// r.print_err("line id",line.id_a(), line.id_b());
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