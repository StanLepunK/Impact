//////////////////////////////////
// Find polygon close from center
//////////////////////////////////

void build_single_polygon_from_heart(int im_0, int im_1) {
	R_Line2DX lh = null;
	R_Line2DX lc = null;
	R_Line2DX prev_lc = null;
	int max_circle = imp.get_num_circle();

	// REGULAR
	boolean bingo_is = false;
	for(int index_c = 0 ; index_c < max_circle ; index_c++) {
		if(imp.get_heart().size() > 0 && im_0 < imp.get_heart().size()) {
			lh = imp.get_heart().get(im_0);
		}
		if(imp.get_circle(index_c) != null && imp.get_circle(index_c).size() > 0) {
		// if(lh != null && imp.get_circle(index_c) != null && imp.get_circle(index_c).size() > 0) {
			for(int index_lc = 0 ; index_lc < imp.get_circle(index_c).size() ; index_lc++) {
				lc = imp.get_circle(index_c).get(index_lc);
				if(r.all(!lc.mute_is(), r.any(lc.id_a() == im_0, lc.id_b() == im_1))) {
					create_polygon_center(lh, lc, prev_lc, imp.get_main(im_0), imp.get_main(im_1));
					prev_lc = lc.copy();
					bingo_is = true;
					break; 
				}
				lc = null;
			}
		} 	
		if(bingo_is) {
			bingo_is = false;
			if(break_if(lh, lc)) {
				break;
			}
		}
	}
}

boolean break_if(R_Line2DX lh, R_Line2DX lc) {
	if(r.any(lh == null)) {
		return true;
	}
	float marge = 3;
	return !r.any(r.in_line(lh.a(),lh.b(), lc.a(),marge), r.in_line(lh.a(),lh.b(), lc.b(),marge));
}


void create_polygon_center(R_Line2DX lh, R_Line2DX lc, R_Line2DX prev_lc, ArrayList<R_Line2DX> main_a, ArrayList<R_Line2DX> main_b) {
	R_Shape shape = new R_Shape(this);
	float marge = 3;
	shape.add_points(lc.a(), lc.b()); // may be need to switch if that's meet main a or main b
	if(lh != null) {
		boolean bingo_is = false;
		for(R_Line2DX lb : main_b) {
			if(r.in_line(lb.a(),lb.b(), lc.a(), marge) || r.in_line(lb.a(),lb.b(), lc.b(), marge)) {
				if(prev_lc == null) {
					add_point_first_level_polygon_center(shape, lh, lc, lh.b());
				} else {
					add_points_next_level_polygon_center(shape, lh, lc, prev_lc);
				}
				bingo_is = true;
				break;
			}	
		}
		if(!bingo_is) {
			for(R_Line2DX la : main_a) {
				if(r.in_line(la.a(),la.b(), lc.a(), marge) || r.in_line(la.a(),la.b(), lc.b(), marge)) {
					if(prev_lc == null) {
						add_point_first_level_polygon_center(shape, lh, lc, lh.a());
					} else {
						add_points_next_level_polygon_center(shape, lh, lc, prev_lc);
					}
					break;
				}	
			}
		}	
	} else {
		shape.add_point(imp.pos().x(), imp.pos().y());
	}

	add_points_go(main_b, shape, true);
	add_points_return(main_a, shape, true);
	imp_shapes_heart.add(shape);
}

void add_point_first_level_polygon_center(R_Shape shape, R_Line2DX lh, R_Line2DX lc, vec2 point) {
	float marge = 3;
	boolean a_is = r.in_line(lh.a(),lh.b(), lc.a(), marge);
	boolean b_is = r.in_line(lh.a(),lh.b(), lc.b(), marge);
	if(r.all(!a_is, !b_is)) {
		shape.add_points(lh.b(),lh.a());
	} else {
		shape.add_points(point);
	}
}

void add_points_next_level_polygon_center(R_Shape shape, R_Line2DX lh, R_Line2DX lc, R_Line2DX prev_lc) {
	float marge = 3;
	boolean a_prev_is = false;
	boolean b_prev_is = false;
	boolean a_is = r.in_line(lh.a(),lh.b(), lc.a(), marge);
	boolean b_is = r.in_line(lh.a(),lh.b(), lc.b(), marge);

	if(r.all(!a_is, !b_is)) {
		a_prev_is = r.in_line(lh.a(),lh.b(), prev_lc.a(), marge);
		b_prev_is = r.in_line(lh.a(),lh.b(), prev_lc.b(), marge);
		if(a_prev_is) {
			shape.id(r.CYAN);
			shape.add_points(prev_lc.b(), prev_lc.a(), lh.a());
			return;
		}
		if(b_prev_is) {
			shape.id(r.GREEN);
			shape.add_points(lh.b(), prev_lc.b(), prev_lc.a());
			return;
		}
	}
	shape.add_points(prev_lc.b(),prev_lc.a());
}

