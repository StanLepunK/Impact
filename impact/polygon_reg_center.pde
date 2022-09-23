// POLYGON HEART
void build_single_polygon_from_heart(int im_0, int im_1) {
	boolean heart_is = false;
	R_Line2DX lh = null;
	R_Line2DX lc = null;
	int max_circle = imp.get_num_circle();

	// REGULAR
	boolean bingo_is = false;
	for(int index_c = 1 ; index_c < max_circle ; index_c++) { // why k must be 1 ????
		if(imp.get_heart().size() > 0 && im_0 < imp.get_heart().size()) {
			lh = imp.get_heart().get(im_0);
		}

		if(imp.get_circle(index_c) != null && imp.get_circle(index_c).size() > 0) {
			for(int index_lc = 0 ; index_lc < imp.get_circle(index_c).size() ; index_lc++) {
				lc = imp.get_circle(index_c).get(index_lc);
				if(lc.id_a() == im_0 || lc.id_b() == im_1) { // break temporary
					// println("BINGO im_0", im_0, "id a", lc.id_a(), "im_1", im_1, "id b", lc.id_b(),"circle", index_c,  "coord", lc);
					// println("BINGO im_0", im_0, "id a", lc.id_a(), "im_1", im_1, "id b", lc.id_b(),"circle", index_c);
					bingo_is = true;
					break; 
				}
				lc = null;
			}
		}
		if(bingo_is) {
			bingo_is = false;
			break;
		}
	}

	// algo is here
	if(lc != null) {
		create_polygon_center(lh, lc, imp.get_main(im_0), imp.get_main(im_1));
	}
}


void create_polygon_center(R_Line2DX lh, R_Line2DX lc, ArrayList<R_Line2DX> main_a, ArrayList<R_Line2DX> main_b) {
	R_Shape shape = new R_Shape(this);
	float marge = 3;
	// println("root lc to create polygon", lc);
	shape.add_points(lc.a(), lc.b()); // may be need to switch if that's meet main a or main b
	println("lh", lh);

	if(lh != null) {
		boolean bingo_is = false;
		for(R_Line2DX lb : main_b) {
			if(r.in_line(lb.a(),lb.b(), lc.a(), marge) || r.in_line(lb.a(),lb.b(), lc.b(), marge)) {
				shape.add_points(lh.b());
				break;
			}	
		}
		for(R_Line2DX la : main_a) {
			if(r.in_line(la.a(),la.b(), lc.a(), marge) || r.in_line(la.a(),la.b(), lc.b(), marge)) {
				shape.add_points(lh.a());
				break;
			}	
		}
	} else {
		shape.add_point(imp.pos().x(), imp.pos().y()); // test point to center impact
	}
	imp_shapes_heart.add(shape);
}

