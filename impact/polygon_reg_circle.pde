// POLYGON CIRCLE
void build_single_basic_polygon_from_circle(int im_0, int im_1) {
	boolean done_is = false;
	int max_circle = imp.get_num_circle();
	for(int k = 0 ; k < max_circle ; k++) {
		done_is = false;
		for(R_Line2DX lc1 : imp.get_circle(k)) {
			if(lc1.id_a() == im_0 && !lc1.mute_is()) {
				for(int m = k + 1 ; m < max_circle ;m++) {
					for(R_Line2DX lc2 : imp.get_circle(m)) {
						if(lc2.id_a() == im_0 && !lc2.mute_is()) {
							create_polygon_circle(lc1, lc2, imp.get_main(im_0), imp.get_main(im_1));
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




void create_polygon_circle(R_Line2DX l1, R_Line2DX l2, ArrayList<R_Line2DX> main_a, ArrayList<R_Line2DX> main_b) {
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