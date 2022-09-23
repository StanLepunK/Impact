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
					println("BINGO im_0", im_0, "id a", lc.id_a(), "im_1", im_1, "id b", lc.id_b(),"circle", index_c);
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
		// println("main", m_index, "heart", lh, "circle",lc);
		create_polygon_center(lh, lc, imp.get_main(im_0), imp.get_main(im_1));
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