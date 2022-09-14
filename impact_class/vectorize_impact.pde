import rope.vector.vec3;
ArrayList<vec3> imp_pts = new ArrayList<vec3>();

void add_cloud_points(R_Impact imp) {
	imp_pts.clear();
	int family = 0;
	for(int i = 0 ; i < imp.get_num_main() ; i++) {
		family = 0;
		add_points(imp.get_main(i), imp, family, false);
	}
	for(int i = 0 ; i < imp.get_num_circle() ; i++) {
		family = 1;
		add_points(imp.get_circle(i), imp, family, false);
	}
	family = 2;
	add_points(imp.get_heart(), imp, family, true);
}

void show_impact_cloud() {
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

void add_points(ArrayList<R_Line2D> list, R_Impact imp, int family, boolean add_is) {
	vec2 [] polygon = imp.get_heart_polygon();

	for(R_Line2D line : list) {
		boolean a_is = r.in_polygon(polygon, line.a());
		boolean b_is = r.in_polygon(polygon, line.b());
		// if(r.any(r.all(!a_is, !b_is,),add_is)) { // don't use the mute option
		if(r.any(r.all(!a_is, !b_is, !line.mute_is()),add_is)) {
			vec3 a = new vec3(line.a().x(), line.a().y(), family);
			imp_pts.add(a);
			vec3 b = new vec3(line.b().x(), line.b().y(), family);
			imp_pts.add(b);
		}
		
	}
}