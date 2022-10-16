/**
 * Impact or R_Impact
 * is an object to simulate the impact of hard object in glass
 * by extension that can simulate the spider web too
 * This algorithm make a part of the project "Éclat d'Ukraine"
 * 
 * v 0.2.0
 * copyleft(c) 2022-2022
 * Stanislas Marçais aka Knupel aka Stan le Punk
 * 
 * 
 * 
 * */

import rope.core.Rope;

import rope.mesh.R_Shape;

import rope.vector.vec2;
import rope.vector.vec3;
import rope.vector.vec4;
import rope.vector.vec5;


public class R_Impact extends Rope {
	private PApplet pa;
	// LINE
	private ArrayList<R_Line2DX>[] main;
	private ArrayList<R_Line2DX>[] circle;
	private ArrayList<R_Line2DX> heart;
	private ArrayList<R_Line2DX> fail;
	// SHAPE
	// private ArrayList<R_Shape> imp_shapes_circle = new ArrayList<R_Shape>();
	private ArrayList<R_Shape> imp_shapes_center = new ArrayList<R_Shape>();
	// private ArrayList<R_Shape> imp_shapes_rest = new ArrayList<R_Shape>();
	private ArrayList<R_Shape> imp_shapes_orphan = new ArrayList<R_Shape>();
	// POINT
	private ArrayList<vec3> cloud = new ArrayList<vec3>();

	private vec2 pos;

	private int mode = LINE;
	private float marge = 2; // use for in_line detection

	private boolean use_mute_is = false;
	private int mode_pixel_x = 1;

	private float growth_fact_spiral = 1;

	private int base = 5;
	private vec5 data_main = new vec5();
	private vec3 data_circle = new vec3();

	
	
	public R_Impact(PApplet pa) {
		this.pa = pa;
		pos = new vec2();
		float growth = sqrt(pow(this.pa.width,2) + pow(this.pa.height,2))/this.base;
		// It's very small value for the result, there is something weird
		float main_growth_angle = PI * 0.02;
		float heart = 0;
		data_main.set(this.base, this.base, growth, main_growth_angle, heart);
		data_circle.set(this.base, this.base, growth);	
	}

	public R_Impact(PApplet pa, int base) {
		this.pa = pa;
		this.base = base;
		pos = new vec2();
		float growth = sqrt(pow(this.pa.width,2) + pow(this.pa.height,2))/this.base;
		// It's very small value for the result, there is something weird
		float main_growth_angle = PI * 0.02;
		float heart = 0;
		data_main.set(this.base, this.base, growth, main_growth_angle, heart);
		data_circle.set(this.base, this.base, growth);
	}

	////////////////////////////////
	// SETTING
	/////////////////////////////////

	public R_Impact growth_factor_spiral(float growth) {
		this.growth_fact_spiral = abs(growth);
		return this;
	}

	public R_Impact spiral() {
		this.mode = SPIRAL;
		return this;
	}

	public R_Impact normal() {
		this.mode = LINE;
		return this;
	}


	// SET DATA MAIN
	///////////////////

	public R_Impact set_num_main(int num) {
		this.data_main.a(num);
		return this;
	}

	public R_Impact set_iter_main(int iter) {
		this.data_main.b(iter);
		return this;
	}

	public R_Impact set_growth_main(float growth) {
		this.data_main.c(growth);
		return this;
	}

	public R_Impact set_angle_main(float angle) {
		this.data_main.d(angle);
		return this;
	}

	public R_Impact set_heart_main(float norm_size) {
		norm_size = abs(norm_size);
		if(norm_size > 1.0f) {
			norm_size = 1.0f;
		}
		data_main.e(norm_size);
		return this;
	}


	// SET DATA CIRCLE
	///////////////////


	public R_Impact set_num_circle(int num) {
		this.data_circle.x(num);
		return this;
	}

	public R_Impact set_iter_circle(int iter) {
		this.data_circle.y(iter);
		return this;
	}

	public R_Impact set_growth_circle(float growth) {
		this.data_circle.z(growth);
		return this;
	}




	//////////////////////////////
	// GETING
	//////////////////////////////

	public vec2 pos() {
		return this.pos;
	}

	public int get_mode() {
		return this.mode;
	}

	public float get_growth_spiral() {
		return this.growth_fact_spiral;
	}

	// GET DATA MAIN
	///////////////////

	public vec5 get_data_main() {
		return this.data_main;
	}

	public int get_num_main() {
		return (int)this.data_main.a();
	}

	public int get_iter_main() {
		return (int)this.data_main.b();
	}

	public float get_growth_main() {
		return this.data_main.c();
	}

	public float get_angle_main() {
		return this.data_main.d();
	}

	public float get_heart_normal_radius() {
		return this.data_main.e();
	}


	// GET DATA CIRCLE
	///////////////////

	public vec3 get_data_circle() {
		return this.data_circle;
	}

	public int get_num_circle() {
		return (int)this.data_circle.x();
	}

	public int get_iter_circle() {
		return (int)this.data_circle.y();
	}

	public float get_growth_circle() {
		return this.data_circle.z();
	}

	// GET SIZE
	////////////////////////

	public int [] get_size_main() {
		return get_size_impl(main, get_num_main());
	}

	public int [] get_size_circle() {
		return get_size_impl(circle, get_num_circle());
	}

	private int [] get_size_impl(ArrayList<R_Line2DX>[] list, int len) {
		int [] size = new int[len];
		for(int i = 0 ; i < len ; i++) {
			if(list != null && i < list.length) {
				size[i] = list[i].size();
			}	else {
				size[i] = 0;
			}
		}
		return size;
	}

	// GET LIST
	/////////////////////

	public ArrayList<R_Line2DX> get_lines() {
		ArrayList<R_Line2DX> buf = new ArrayList<R_Line2DX>();
		for(int i = 0 ; i <  main.length ; i++) {
			buf.addAll(main[i]);
		}
		for(int i = 0 ; i <  circle.length ; i++) {
			buf.addAll(circle[i]);
		}
		buf.addAll(heart);
		return buf;
	}

	public ArrayList<R_Line2DX> get_main_lines(int index) {
		if(index >= 0 && index < main.length) {
			return main[index];
		}
		return null;
	}

	/**
	* return circle
	 */
	public ArrayList<R_Line2DX> get_circle_lines(int index) {
		if(index >= 0 && index < circle.length) {
			return circle[index];
		}
		return null;
	}

	/**
	* return branch of all circle, it's attached to main id
	 */
	public ArrayList<R_Line2DX> get_branch_lines(int index) {
		ArrayList<R_Line2DX> list = new ArrayList<R_Line2DX>();
		for(int i = 0 ; i < circle.length ; i++) {
			for(int k = 0 ; k < circle[i].size() ; k++) {
				if(index == get_abs_id(circle[i].get(k).id_a())) {
					list.add(circle[i].get(k));
				}		
			}
		}
		return list;
	}

	public ArrayList<R_Line2DX> get_heart_lines() {
		return heart;
	}

	public ArrayList<R_Line2DX> get_fail_lines() {
		return fail;
	}

	public ArrayList<vec3> get_cloud() {
		return cloud;
	}

	// get polygon
	public ArrayList<R_Shape> get_polygons() {
		ArrayList<R_Shape> buf = new ArrayList<R_Shape>();
		buf.addAll(imp_shapes_center);
		// buf.addAll(imp_shapes_circle);
		// buf.addAll(imp_shapes_rest);
		buf.addAll(imp_shapes_orphan);
		return buf;
	}

	// public ArrayList<R_Shape> get_circle_polygons() {
	// 	return imp_shapes_circle;
	// }

	// public ArrayList<R_Shape> get_rest_polygons() {
	// 	return imp_shapes_rest;
	// }

	public ArrayList<R_Shape> get_center_polygons() {
		return imp_shapes_center;
	}

	public ArrayList<R_Shape> get_orphan_polygons() {
		return imp_shapes_orphan;
	}

	// may be need to be refactoring to arrayList or R_Shape
	public vec2 [] get_heart_polygon() {
		if(heart.size() == 0) {
			return null;
		}
		vec2 [] polygon = new vec2[get_num_main()];
		for(int i = 0 ; i < polygon.length ; i++) {
			polygon[i] = heart.get(i).a().copy();
		}
		return polygon;
	}

	// get line heart from lc
	//////////////////////////

	private R_Line2DX get_line_heart(R_Line2DX lc) {
		if(heart.size() > 0) {
			if(lc.id().a() < 0) {
				return heart.get(get_abs_id(lc.id().a()));
			} else if (lc.id().b() < 0) {
				return heart.get(get_abs_id(lc.id().b()));
			} else {
				return heart.get(lc.id().a());
			}
		}
		return null;
	}

	// ID
	/////////////////

	private int get_abs_id(int raw_id) {
		int id = raw_id;
		// for line heart case
		if(id < 0) {
			id = abs(id + 1);
		}
		return id;
	}






























	///////////////////////////
	// BUILD GLOBAL
	///////////////////////////

	public void build_struct() {
		build_struct(0,0);
	}

	public void build_struct(int x, int y) {
		this.pos.set(x,y);
		build_main();
		build_heart();
  	
  	// hack algo to avoid the bug center when the spiral don't start
  	float start_value = 0;
  	if(mode == SPIRAL) {
  		boolean spiral_is_good = false;
  		vec2 area = new vec2(2);
  		int threshold_critic = get_num_main() * 2;
	  	while(!spiral_is_good) {
				int threshold = 0;
	  		build_circle(start_value);
	  		for(int i = 0 ; i < get_num_circle() ; i++) {
	  			for(R_Line2DX line : circle[i]) {
						if(line.a().compare(this.pos,area)) {
	  					threshold++;
	  				}
	  			}
	  		}
	  		if(threshold < threshold_critic) {
	  			spiral_is_good = true;
	  		}
	  		start_value += 0.05;
			}
			return;
  	}
  	build_circle(0);
		set_id_circle();
		add_cloud_points();	
	}


	////////////////////////
	// BUILD STRUCTURE
	/////////////////////////

	// BUILD MAIN BRANCH
	/////////////////////
	private void build_main() {
		main = new ArrayList[get_num_main()];
		float angle_step = TAU / get_num_main();
		float angle = 0;

		for(int i = 0 ; i < get_num_main() ; i++) {
			main[i] = new ArrayList<R_Line2DX>();
			main_impl(i, angle);
			angle += angle_step;
		}
	}

	private void build_heart() {
		heart = new ArrayList<R_Line2DX>();
		if(get_heart_normal_radius() > 0 ) {
			for(int i = 1 ; i < main.length ; i++) {
				vec2 a = main[i -1].get(0).a();
				vec2 b = main[i].get(0).a();
				R_Line2DX line = new R_Line2DX(this.pa, a, b);
				heart.add(line);
			}
			vec2 a = main[main.length -1].get(0).a();
			vec2 b = main[0].get(0).a();
			R_Line2DX line = new R_Line2DX(this.pa, a, b);
			heart.add(line);
		}
	}

	private void main_impl(int index, float angle) {
		float range_jit = TAU / get_num_main() * 0.1;

		float ax = pos.x();
		float ay = pos.y();
		float bx = 0;
		float by = 0;

		float dist = 0;
		for(int i = 0 ; i < get_iter_main() ; i++) {
			// distance
			float buf_dist = random(get_growth_main()/10,get_growth_main());
			dist += buf_dist;
			// direction
			float range = get_angle_main();
			float dir = random(-range, range);
			float final_angle = angle + dir;
			float x = sin(final_angle) * dist;
			float y = cos(final_angle) * dist;
			bx = x + this.pos.x();
			by = y + this.pos.y();
			R_Line2DX line = new R_Line2DX(this.pa, ax, ay, bx, by);
			if(i == 0 && get_heart_normal_radius() > 0) {
				line.change(-get_heart_normal_radius(),0);
				// to make the changement for ever !!!
				line.set(line.a(),line.b());
			}
			main[index].add(line);
			ax = bx;
			ay = by;
		}
	}



	// BUILD CIRCLE
	//////////////////////////



	private void build_circle(float start_value) {
	  circle = new ArrayList[get_num_circle()];
	  fail = new ArrayList<R_Line2DX>();
		float dist = 0;
		float dist_step = get_growth_circle() / get_num_main(); 

		for(int i = 0 ; i < get_num_circle() ; i++) {
			circle[i] = new ArrayList<R_Line2DX>();
			float fact = i + start_value; // that work but to far from the center
			dist = (dist_step * fact);
			circle_impl(circle[i], dist);
			sort_circle(circle[i]);
		}
	}

	private void sort_circle(ArrayList<R_Line2DX> circle_lines) {
		if(get_heart_normal_radius() > 0) {
			ArrayList<R_Line2DX> selected_list = new ArrayList<R_Line2DX>();
			ArrayList<R_Line2DX> working_list = new ArrayList<R_Line2DX>();
			ArrayList<R_Line2DX> remove_list = new ArrayList<R_Line2DX>();
			// list of vec2 point of the heart
			vec2 [] polygon = get_heart_polygon();
			// check all the lines web string point
			for(R_Line2DX line : circle_lines) {
				boolean a_is = in_polygon(polygon, line.a());
				boolean b_is = in_polygon(polygon, line.b());
				if(a_is && b_is) {
					remove_list.add(line);
				} else if(!a_is && b_is) {
					working_list.add(line);
				} else if(a_is && !b_is) {
					working_list.add(line);
				} else {
					selected_list.add(line);
				}
			}

			// clear and add the good ones
			circle_lines.clear();
			for(R_Line2DX line : selected_list) {
				circle_lines.add(line);
			}
			// cut the line if necessary
			for(R_Line2DX line : working_list) {
				boolean a_is = in_polygon(polygon, line.a());
				vec2 inter = null;
				for(R_Line2DX line_heart : heart) {
					inter = line_heart.intersection(line);
					if(inter != null) {
						R_Line2DX new_line = new R_Line2DX(this.pa);
						if(a_is) {
							new_line.set(inter, line.b());
						} else {
							new_line.set(line.a(), inter);
						}
						circle_lines.add(new_line);
						break;
					}
				}
			}
		}
	}



	private void circle_impl(ArrayList<R_Line2DX> circle_lines, float dist) {
		float start_angle = 0;
		float step_angle = TAU / get_num_main();
		vec2 ang_set = new vec2(start_angle, step_angle);
		vec2 buf_meet = new vec2(-1);
		boolean jump_is = false;
		float buf_dist = dist;

	  for(int count = 0 ; count < get_iter_circle();  count++){
			R_Line2DX line = draw_string_web(ang_set, buf_dist);
			// here we catch the meeting point with the main branches
			vec2 [] tupple = meet_point(line, true);
			boolean good_tupple_is = false;
			if(tupple[0] != null && tupple[1] != null) {
				good_tupple_is = true;
				// the moment where the turn is done and it's time to go to next level
				if((count)%get_num_main() == 0 && mode == SPIRAL) {
					vec2 swap = tupple[0];
					tupple[0] = tupple[1];
					tupple[1] = swap;
				}
			}
			jump_is = adjust_string_web(circle_lines, line, buf_meet, tupple, good_tupple_is, jump_is);

			if(mode == SPIRAL) {
				buf_dist = dist(line.b(),this.pos);
			}

			// close the circle line
			int index = count + 1;
			if(mode == LINE && index%get_num_main() == 0) {
				int which_one = index - get_num_main();
				close_string_web(circle_lines, which_one);
			}
	  }
	}

	// ALGO CIRCLE BRANCH
	/////////////////////////

	private R_Line2DX draw_string_web(vec2 ang_set, float dist) {
		float final_angle = ang_set.x();
		float ax = sin(final_angle) * dist + this.pos.x();
		float ay = cos(final_angle) * dist + this.pos.y();
		ang_set.x(ang_set.x() + ang_set.y());
		final_angle = ang_set.x();
		if(mode == SPIRAL) {
			dist += get_growth_spiral();
		}
		float bx = sin(final_angle) * dist + this.pos.x();
		float by = cos(final_angle) * dist + this.pos.y();
		R_Line2DX line = new R_Line2DX(this.pa, ax, ay, bx, by);
		// increase the size of line to meet the main branches and find the meeting point to next step
		line.change(0.5, 0.5);
		line.set(line.a(),line.b());
		return line;
	}

	private boolean adjust_string_web(ArrayList<R_Line2DX> circle_lines, R_Line2DX line, vec2 buf_meet, vec2 [] tupple, boolean good_tupple_is, boolean jump_is) {
		if(!good_tupple_is) {
			jump_is = true;
			fail.add(line);
	  } else {
			if(buf_meet.equals(-1) || jump_is) {  
				line.set(tupple[0],tupple[1]);
				circle_lines.add(line);
				buf_meet.set(tupple[1].x(),tupple[1].y());
				jump_is = false;
				add_err(line, buf_meet, tupple, "FAIL 1", false);
			} else {
				line.set(buf_meet,tupple[1]);
				add_err(line, buf_meet, tupple, "FAIL 2", false);
				circle_lines.add(line);
				buf_meet.set(tupple[1]);
			}	
		}
		return jump_is;
	}


	private void close_string_web(ArrayList<R_Line2DX> circle_lines, int index) {
		if(index < circle_lines.size()) {
			vec2 last = circle_lines.get(index).a();
			int max = circle_lines.size() -1;
			R_Line2DX line = new R_Line2DX(this.pa ,circle_lines.get(max).a(), last);
			circle_lines.remove(max);
			circle_lines.add(line);
		}
	}

	private vec2 [] meet_point(R_Line2DX line, boolean two_points_is) {
		// the temporary list to work
		ArrayList<ArrayList> buf_list = new ArrayList<ArrayList>();
		for(int i = 0; i < main.length ; i++) {
			ArrayList<R_Line2DX> temp = new ArrayList<R_Line2DX>();
			// put the first point to center of the impact
			R_Line2DX temp_line_first = main[i].get(0);
			temp_line_first.a(this.pos.x(), this.pos.y());
			temp.add(temp_line_first.copy());
			for(int k = 1 ; k < main[i].size(); k++) {
				R_Line2DX temp_line_next = main[i].get(k).copy();
				temp.add(temp_line_next);
			}
			buf_list.add(temp);
		}

		// the sort
		vec2 [] meet = new vec2[2];
		for(ArrayList<R_Line2DX> list : buf_list) {
			for(R_Line2DX buff_line : list) {
				if(meet[0] == null) {
					meet[0] = buff_line.intersection(line);
					if(two_points_is && meet[0] != null) {
						break;
					}
				}
				if(meet[0] != null && meet[1] == null) {
					meet[1] = buff_line.intersection(line);
				}
				if(meet[0] != null && meet[1] != null) {
					return meet;
				}
			}		
		}
		return meet;
	}



	private void set_id_circle() {
		for(int i = 0 ; i < circle.length ; i++) {
			for(int k = 0 ; k < main.length ; k++) {
				for(R_Line2DX lc : circle[i]) {
					// id from main
					for(R_Line2DX lm : main[k]) {
						if(in_line(lm,lc.a(),marge)) lc.id_a(k);
						if(in_line(lm,lc.b(),marge)) lc.id_b(k);
					}
					// ???????????????????????????????????????????????????????
					// J'ai l'impression que ça rajoute des bugs
					// Alors que cela ne devrait pas
					// ???????????????????????????????????????????????????????
					// id from heart, we minus by one to avoid a conflict with the 0 ID
					for(int m = 0 ; m <  heart.size() ; m++) {
						R_Line2DX lh = heart.get(m);
						if(lc.id_a() == Integer.MIN_VALUE && in_line(lh,lc.a(),marge)) {
							lc.id_a(-m-1);
						}
						if(lc.id_b() == Integer.MIN_VALUE && in_line(lh,lc.b(),marge)) {
							lc.id_b(-m-1);
						}
					}

				}
			}
		}
	}








































	/////////////////////////////
	// BUILD POLYGON
	///////////////////////////

	public void build_polygon() {
		println("<<<<<<<<<<<<< ============= >>>>>>> NEW BUILD POLYGON <<<<<<<<<< ============= >>>>>>>>>>>>>>>");
		ArrayList<vec2>poly = new ArrayList<vec2>();
		// clear polygon
		// imp_shapes_circle.clear();
		imp_shapes_center.clear();
		// imp_shapes_rest.clear();
		imp_shapes_orphan.clear();

		int count_info = 0;
		int max_main = this.get_num_main();
		// main branch by main branch
		for(int m_index = 0 ; m_index < max_main ; m_index++) {
			int im_0 = m_index;
			int im_1 = m_index+1;
			if(im_1 == max_main) {
				im_1 = 0;
			}
			// build_polygons_circle(im_0, im_1);
			// build_polygons_center(im_0, im_1);
			// build_polygons_rest(im_0, im_1);
		}
		build_polygon_heart();
		for(int i = 0 ; i < get_num_main() ; i++) {
			build_polygons_orphan(i);
		}
	}




	// BUILD POLYGON ORPHAN
	////////////////////////
	private void build_polygons_orphan(int id_branch) {
		int len = get_branch_lines(id_branch).size();
		R_Line2DX [] arr_branch = new R_Line2DX[len];
		arr_branch = get_branch_lines(id_branch).toArray(arr_branch);
		// first element
		for(int i = 0 ; i < len -1 ; i++) {
			R_Line2DX line =  arr_branch[i];
			if(r.all(!line.mute_is(), line.id().c() == Integer.MIN_VALUE)) {
				create_polygon_first(line);
				break;
			}
		}
		// curent element
		int last_index = 0;
		for(int i = 0 ; i < len -1 ; i++) {
			R_Line2DX line =  arr_branch[i];
			for(int k = i + 1 ; k < len ; k++) {
				R_Line2DX next_line =  arr_branch[k];
				if(r.all(!line.mute_is(), ! next_line.mute_is(), line.id().c() == Integer.MIN_VALUE)) {
					create_polygon_current(line, next_line);
					last_index = k;
					break;
				} 
			}	
		}
		// last element
		if(arr_branch.length > 0) {
			R_Line2DX last_line = null;
			if(last_index > 0) {
				last_line = arr_branch[last_index];
			} else if (last_index == 0 && heart.size() > 0) {
				last_line = heart.get(id_branch);
			} else {
				// here we make a line like a point to keep the structure shape with 4 points, for the go and return function

				last_line = new R_Line2DX(this.pa, pos, pos);
				last_line.id_a(id_branch);
			}
			if(last_line != null) {
				create_polygon_last(last_line, id_branch);
			}
		}
	}


	private void create_polygon_last(R_Line2DX line, int id_branch) {
		R_Shape shape = new R_Shape(this.pa);
		shape.id(r.GRIS[15]);
		int next_id_branch = id_branch + 1;
		if(next_id_branch >= get_num_main()) {
			next_id_branch = 0;
		}
		ArrayList<R_Line2DX>[] main = tupple_main(id_branch, next_id_branch);
		R_Line2DX next_line = new R_Line2DX(this.pa, main[0].get(main[0].size() -1).b(), main[1].get(main[1].size() -1).b());
		if(r.all(main[0] != null,main[1] != null)) {
			shape.add_points(line.a(),line.b(), next_line.b(),  next_line.a());
		}
		R_Line2DX lh = null;
		// ID PROBLEM
		///////////////////////////
		/////////////////////////
		// NEED SOLUTION
		// line.id_a(id_branch);
		junction_lh_lc(shape, lh, line, next_line);
		add_points_go(main[1], shape, lh);
		add_points_return(main[0], shape, lh);
		// add_points_go(main[1], shape, null);
		// add_points_return(main[0], shape, null);
		imp_shapes_orphan.add(shape);
	}


	private void create_polygon_current(R_Line2DX lc, R_Line2DX next_lc) {
		R_Shape shape = new R_Shape(this.pa);
		set_use_for_polygon(lc);
		// shape.id(BLOOD);
		shape.id(r.GRIS[10]);
		shape.add_points(next_lc.a(),next_lc.b(), lc.b(), lc.a());
		R_Line2DX lh = null;
		junction_lh_lc(shape, lh, lc, next_lc);
		ArrayList<R_Line2DX>[] main = tupple_main(lc.id().a(), lc.id().b());
		add_points_go(main[1], shape, lh);
		add_points_return(main[0], shape, lh);
		imp_shapes_orphan.add(shape);
	}

	private void create_polygon_first(R_Line2DX lc) {
		R_Shape shape = new R_Shape(this.pa);
		shape.id(r.GRIS[5]);
		R_Line2DX lh = null;
		ArrayList<R_Line2DX> [] main = tupple_main(lc.id().a(), lc.id().b());
		if(heart.size() > 0) {
			if(r.any(lc.id().a() < 0, lc.id().b() < 0)) {
				lh = get_line_heart(lc);
				vec2 point = get_point_line_heart(lh, lc, main[0], main[1]);
				add_point_first_level_polygon_center(shape, lh, lc, point);
			} else {
				lh = get_line_heart(lc);
				shape.add_points(lh.a(), lh.b());
			}
		} else {
			shape.add_points(pos, pos);
		}
		// not in first to keep the same order thant current polygon
		shape.add_points(lc.b(), lc.a());
		add_points_go(main[1], shape, lh);
		add_points_return(main[0], shape, lh);
		imp_shapes_orphan.add(shape);
	}







	private void junction_lh_lc(R_Shape shape, R_Line2DX lh, R_Line2DX lc, R_Line2DX next_lc) {
		int id_heart = get_abs_id(lc.id().a());
		if(id_heart >= get_num_main()) {
			println("Quoi:", lh, lc, next_lc);
			println("heart size:", heart.size());
		}
		if(heart.size() > 0 && id_heart < get_num_main()) {
			lh = heart.get(id_heart);
			boolean lc_a_is = r.in_line(lh, lc.a(), marge);
			boolean lc_b_is = r.in_line(lh, lc.b(), marge);
			boolean next_lc_a_is = r.in_line(lh, next_lc.a(), marge);
			boolean next_lc_b_is = r.in_line(lh, next_lc.b(), marge);
			if(lc_a_is && r.all(!next_lc_a_is, !next_lc_b_is)) {
				shape.add_points(lh.a());
			} else if(lc_b_is && r.all(!next_lc_a_is, !next_lc_b_is)) {
				shape.add_points(2,lh.b());
			}
		}
	}

	private ArrayList<R_Line2DX>[] tupple_main(int id_a, int id_b) {
		ArrayList<R_Line2DX> [] arr = new ArrayList[2];
		int im_0 = id_a;
		int im_1 = im_0 + 1;
		if(id_a < 0) {
			im_1 = id_b;
			im_0 = im_1 -1;
		}

		if(im_1 >= get_num_main()) {
			im_1 = 0;
		}
		if(im_0 < 0) {
			im_0 = get_num_main() -1;
		}

		arr[0] = this.get_main_lines(im_0);
		arr[1] = this.get_main_lines(im_1);
		return arr;
	}


				















	// BUILD POLYGON CIRCLE
	/////////////////////////

	// private void build_polygons_circle(int im_0, int im_1) {
	// 	boolean bingo_is = false;
	// 	int max_circle = this.get_num_circle();
	// 	for(int level = 0 ; level < max_circle ; level++) {
	// 		bingo_is = false;
	// 		for(R_Line2DX lc1 : this.get_circle_lines(level)) {
	// 			if(lc1.id_a() == im_0 && !lc1.mute_is()) {
	// 				for(int m = level + 1 ; m < max_circle ; m++) {
	// 					for(R_Line2DX lc2 : this.get_circle_lines(m)) {
	// 						if(lc2.id_a() == im_0 && !lc2.mute_is()) {
	// 							create_polygon_circle(lc1, lc2, im_0, im_1, level);
	// 							bingo_is = true;
	// 							break;
	// 						}
	// 					}
	// 					if(bingo_is) break;
	// 				}
	// 			}
	// 			if(bingo_is) break;
	// 		}
	// 	}
	// }

	// private void create_polygon_circle(R_Line2DX lc1, R_Line2DX lc2, int im_0, int im_1, int level) {
	// 	if(heart.size() > 0) {
	// 		if(touch_heart_is(lc1, lc2, heart.get(im_0))) {
	// 			return;
	// 		}
	// 	}
	// 	// get R_Line2DX Main
	// 	ArrayList<R_Line2DX> main_a = this.get_main_lines(im_0);
	// 	ArrayList<R_Line2DX> main_b = this.get_main_lines(im_1);
	// 	// set shape
	// 	R_Shape shape = new R_Shape(this.pa);
	// 	set_use_for_polygon(lc1);
	// 	set_use_for_polygon(lc2);
	// 	shape.id(r.GRIS[4]);
	// 	shape.add_points(lc1.a(), lc1.b());
	// 	boolean add_alert_is = false;
	// 	if(heart.size() > 0 && shape.get_point(0).compare(shape.get_point(1), marge)) {
	// 		R_Line2DX lh = heart.get(im_0);
	// 		vec2 p0 = shape.get_point(0).xy();
	// 		vec2 p1 = shape.get_point(1).xy();

	// 		if(!add_alert_is) {
	// 			add_alert_is = add_point_alert(shape, lh, lc2, p0);
	// 		}

	// 		if(!add_alert_is) {
	// 			add_alert_is = add_point_alert(shape, lh, lc2, p1);
	// 		}

	// 		if(!add_alert_is && level > 1) {
	// 			for(int k = level - 1 ; k > 0 ; k--) {
	// 				if(this.get_circle_lines(k) != null && this.get_circle_lines(k).size() > im_0) {
	// 					R_Line2DX lc_previous = this.get_circle_lines(k).get(im_0);
	// 					if(!lc_previous.mute_is()) {
	// 						// we keep because is not realy fix, but that's happen very rarely
	// 						// println("HEART CIRCLE ALERT add lc_previous", lc_previous);
	// 						shape.add_points(lc_previous.a(), lc_previous.b());
	// 						add_alert_is = true;
	// 						break;
	// 					}
	// 				}
	// 			}
	// 		}

	// 		if(!add_alert_is) {	
	// 			if(lh.b().compare(p0, marge +3)) {
	// 				// we keep because is not realy fix, but that's happen very rarely
	// 				// println("HEART CIRCLE ALERT add lh [b][a]", lh.b(), lh.a());
	// 				shape.add_points(lh.b(), lh.a());
	// 			} else {
	// 				shape.add_points(lh.a(), lh.b());
	// 			}
	// 			add_alert_is = true;
	// 		}
	// 	}
	// 	shape.add_points(lc2.b(), lc2.a());
	// 	if(add_alert_is) {
	// 		add_points_go_alert_circle(main_b, shape, null);
	// 	} else {
	// 		add_points_go(main_b, shape, null);
	// 	}

	// 	add_points_return(main_a, shape, null);
	// 	imp_shapes_circle.add(shape);
	// }

	// POLYGON HEART
	//////////////////
		private void build_polygon_heart() {
		R_Shape shape = new R_Shape(this.pa);
		shape.id(r.GRIS[1]);
		for(R_Line2DX lh : this.get_heart_lines()) {
			shape.add_points(lh.a());
		}
		imp_shapes_center.add(shape);
	}

	boolean add_point_alert(R_Shape shape, R_Line2DX lh, R_Line2DX lc2, vec2 point) {
		if(lh.a().compare(point, marge)) {	
			if(r.in_line(lh, lc2.a(), marge)) {
				shape.add_points(lc2.a()); 
			} else if(r.in_line(lh, lc2.b(), marge)) { 
				shape.add_points(lc2.b()); 
			} else {
				shape.add_points(lh.b());
			}
			return true;
		}

		if(lh.b().compare(point, marge)) {
			if(r.in_line(lh, lc2.a(), marge)) {
				shape.add_points(lc2.a()); 
			} else if(r.in_line(lh, lc2.b(), marge)) { 
				shape.add_points(lc2.b()); 
			} else {
				shape.add_points(lh.a());
			}
			return true;
		}
		return false;
	}


	// BUILD POLYGON CENTER
	///////////////////////////

	// private void build_polygons_center(int im_0, int im_1) {
	// 	R_Line2DX lh = null;
	// 	R_Line2DX lc = null;
	// 	R_Line2DX prev_lc = null;
	// 	int max_circle = this.get_num_circle();
	// 	// REGULAR
	// 	boolean bingo_is = false;
	// 	for(int index_c = 0 ; index_c < max_circle ; index_c++) {
	// 		if(this.get_heart_lines().size() > 0 && im_0 < this.get_heart_lines().size()) {
	// 			lh = this.get_heart_lines().get(im_0);
	// 		}
	// 		if(this.get_circle_lines(index_c) != null && this.get_circle_lines(index_c).size() > 0) {
	// 			for(int index_lc = 0 ; index_lc < this.get_circle_lines(index_c).size() ; index_lc++) {
	// 				lc = this.get_circle_lines(index_c).get(index_lc);
	// 				if(r.all(!lc.mute_is(), id_line_circle_is(lc, im_0, im_1))) {
	// 					create_polygon_center(lh, lc, prev_lc, this.get_main_lines(im_0), this.get_main_lines(im_1));
	// 					prev_lc = lc.copy();
	// 					bingo_is = true;
	// 					break; 
	// 				}
	// 				lc = null;
	// 			}
	// 		} 	
	// 		if(bingo_is) {
	// 			bingo_is = false;
	// 			if(break_if(lh, lc)) {
	// 				break;
	// 			}
	// 		}
	// 	}
	// }



	// private boolean break_if(R_Line2DX lh, R_Line2DX lc) {
	// 	if(r.any(lh == null)) {
	// 		return true;
	// 	}
	// 	return !r.any(r.in_line(lh.a(),lh.b(), lc.a(),marge), r.in_line(lh.a(),lh.b(), lc.b(),marge));
	// }



	// private void create_polygon_center(R_Line2DX lh, R_Line2DX lc, R_Line2DX prev_lc, ArrayList<R_Line2DX> main_a, ArrayList<R_Line2DX> main_b) {
	// 	if(lc.a().compare(lc.b(), marge)) {
	// 		lc.id_c(Integer.MAX_VALUE); 
	// 		// we set to Integer.MAX_VALUE to exprim the desire to don't use in the fure
	// 		// for memory Integer.MIN_VALUE exprim the fact the line has never used to build polygon
	// 		return;
	// 	}
	// 	set_use_for_polygon(lc);
	// 	// int id_before = lc.id().c();
	// 	// set_use_for_polygon(lc);
	// 	// if(lc.id().c() == id_before) {
	// 	// 	println("id problem", id_before, lc.id().c());
	// 	// }
	// 	R_Shape shape = new R_Shape(this.pa);
	// 	shape.add_points(lc.a(), lc.b()); // ELEM 0 AND 1
	// 	if(lh != null) {
	// 		if(prev_lc == null) {
	// 			vec2 point = get_point_line_heart(lh, lc, main_a, main_b);
	// 			add_point_first_level_polygon_center(shape, lh, lc, point);
	// 		} else {
	// 			add_points_next_level_polygon_center(shape, lh, lc, prev_lc);
	// 		}	
	// 	} else {
	// 		shape.id(r.GRIS[14]);
	// 		// add double pos to avoir the "GO" bug when there only three points for the ArrayList acces on a square shape.
	// 		shape.add_points(pos, pos); 
	// 	}
	// 	add_points_go(main_b, shape, lh);
	// 	add_points_return(main_a, shape, lh);

	// 	imp_shapes_center.add(shape);
	// }
	
	// // first level
	// //////////////

	private vec2 get_point_line_heart(R_Line2DX lh, R_Line2DX lc, ArrayList<R_Line2DX> main_a, ArrayList<R_Line2DX> main_b) {
		float dist_a = r.dist(pos, lh.a());
		float dist_b = r.dist(pos, lh.b());
		if(dist_a < dist_b) {
			return lh.a();
		}
		return lh.b();
	}

	private void add_point_first_level_polygon_center(R_Shape shape, R_Line2DX lh, R_Line2DX lc, vec2 lh_point) {
		boolean a_is = r.in_line(lh, lc.a(), marge);
		boolean b_is = r.in_line(lh, lc.b(), marge);
		shape.id(r.GRIS[14]);
		if(r.all(!a_is, !b_is)) {
			shape.add_points(lh.b(),lh.a());
		} else {
			shape.add_points(lh_point, lh_point); // to avoid access problem list when there is only 3 points
		}
	}

	// // next level
	// ////////////////

	// private void add_points_next_level_polygon_center(R_Shape shape, R_Line2DX lh, R_Line2DX lc, R_Line2DX prev_lc) {
	// 	boolean a_prev_is = false;
	// 	boolean b_prev_is = false;
	// 	boolean a_is = r.in_line(lh, lc.a(), marge);
	// 	boolean b_is = r.in_line(lh, lc.b(), marge);
	// 	shape.id(r.GRIS[12]);
	// 	if(r.all(!a_is, !b_is)) {
	// 		a_prev_is = r.in_line(lh, prev_lc.a(), marge);
	// 		b_prev_is = r.in_line(lh, prev_lc.b(), marge);
	// 		if(r.all(a_prev_is,b_prev_is)) {
	// 			shape.id(r.GRIS[10]);
	// 			shape.add_points(lh.b(), lh.a());
	// 			return;
	// 		}
	// 		if(a_prev_is) {
	// 			shape.id(r.GRIS[8]);
	// 			shape.add_points(prev_lc.b(), prev_lc.a(), lh.a());
	// 			return;
	// 		}
	// 		if(b_prev_is) {
	// 			shape.id(r.GRIS[6]);
	// 			shape.add_points(lh.b(), prev_lc.b(), prev_lc.a());
	// 			return;
	// 		}
	// 	}
	// 	shape.add_points(prev_lc.b(),prev_lc.a());
	// }








	// BUILD POLYGON REST
	//////////////////////////

	// private void build_polygons_rest(int im_0, int im_1) {
	// 	R_Shape shape = new R_Shape(this.pa);
	// 	shape.id(r.GRIS[2]);

	// 	// find the last circle elem not mute and add it
	// 	int max_circle = this.get_num_circle()-1;
	// 	boolean bingo_is = false;
	// 	// go from the max to minimum
	// 	for(int k = max_circle ; k >= 0 ; k--) {
	// 		for(R_Line2DX lc : this.get_circle_lines(k)) {
	// 			if(r.any(lc.id_a() == im_0, lc.id_b() == im_1) && !lc.mute_is()) {
	// 				create_polygon_rest(lc, shape, im_0, im_1);
	// 				bingo_is = true;
	// 				break;
	// 			}
	// 		}
	// 		if(bingo_is) {
	// 			break;
	// 		}
	// 	}
	// 	if(!bingo_is) {
	// 		create_polygon_rest(null, shape, im_0, im_1);		
	// 	}
		
	// 	imp_shapes_rest.add(shape);
	// }

	// private void create_polygon_rest(R_Line2DX lc, R_Shape shape, int im_0, int im_1) {
	// 	ArrayList<R_Line2DX> main_a = this.get_main_lines(im_0);
	// 	ArrayList<R_Line2DX> main_b = this.get_main_lines(im_1);

	// 	R_Line2DX lm_0_last = main_a.get(main_a.size() -1);
	// 	R_Line2DX lm_1_last = main_b.get(main_b.size() -1);
	// 	R_Line2DX lh = null;
	// 	if(this.get_heart_lines().size() > 0) {
	// 		lh = this.get_heart_lines().get(im_0);
	// 	}

	// 	shape.add_points(lm_0_last.b(), lm_1_last.b());
	// 	int what = 0;
	// 	if(r.all(lc == null, lh == null)) what = 0;
	// 	else if(lc != null && lh == null) what = 1;
	// 	else if(lc == null && lh != null) what = 2;
	// 	else if(lc != null && lh != null) what = 3;
		
	// 	if(lc != null) {
	// 		set_use_for_polygon(lc);
	// 	}

	// 	switch(what) {
	// 		// case 0 : double the center points to avoid the getting problem when we catch the point in the GO function
	// 		case 0 : shape.add_points(pos, pos); break; 
	// 		case 1 : shape.add_points(lc.b(), lc.a()); break;
	// 		case 2 : shape.add_points(lh.b(), lh.a()); break;
	// 		case 3 :
	// 			boolean lc_is_a = r.in_line(lh, lc.a(), marge);
	// 			boolean lc_is_b = r.in_line(lh, lc.b(), marge);
	// 			if(r.all(lc_is_a,lc_is_b)) {
	// 				shape.add_points(lh.b(), lh.a());
	// 			}
	// 			if(lc_is_a) {
	// 				shape.add_points(lc.b(), lc.a(), lh.a());
	// 				break;
	// 			}
	// 			if(lc_is_b) {
	// 				shape.add_points(lh.b(), lc.b(), lc.a());
	// 				break;
	// 			}
	// 			shape.add_points(lc.b(), lc.a());
	// 			break;
	// 	}
	// 	// if(lc != null) {
	// 	// 	set_use_for_polygon(lc);
	// 	// }

	// 	if(heart.size() > 0) {
	// 		check_same_rest(shape.get_points(), marge, lh, im_0, im_1, shape);
	// 	}

	// 	add_points_go(main_b, shape, lh);
	// 	add_points_return(main_a, shape, lh);
	// }


	// private boolean check_same_rest(vec3 [] list, float marge, R_Line2DX lh, int im_0, int im_1, R_Shape shape) {
	// 	int same_same = 0;
	// 	vec2 ref = new vec2();
	// 	boolean lh_a_is = false;
	// 	boolean lh_b_is = false;
	// 	boolean lc_a_is = false;
	// 	boolean lc_b_is = false;
	// 	R_Line2DX lc = null;
	// 	for(int i = 0 ; i < list.length ; i++) {
	// 		vec2 v = list[i].xy();
	// 		if(v.compare(ref, marge) && r.all(r.greaterThanEqual(v, new vec2()))) {
	// 			same_same++;
	// 		}
	// 		if(lh != null) {
	// 			if(v.compare(lh.a(), marge)) lh_a_is = true;
	// 			if(v.compare(lh.b(), marge)) lh_b_is = true;
	// 		}
	// 		boolean bingo_is = false;
	// 		for(int k = get_num_circle() -1 ; k >= 0 ; k--) {
	// 			lc = null;
	// 			for(int icl = 0 ; icl < this.get_circle_lines(k).size() ; icl++) {
	// 				lc = null;
	// 				if(this.get_circle_lines(k).get(icl).id_a() == im_0) {
	// 					lc = this.get_circle_lines(k).get(icl);
	// 					if(!lc.mute_is()) {
	// 						if(v.compare(lc.a(), marge)) lc_a_is = true;
	// 						if(v.compare(lc.b(), marge)) lc_b_is = true;
	// 						bingo_is = true;
	// 						break;
	// 					}
	// 				}
	// 			}
	// 			if(bingo_is) {
	// 				break;
	// 			}
	// 		}
	// 		ref = v;
	// 	}
	// 	if(same_same > 0) {
	// 		if(r.any(lc == null, r.all(!lc_a_is, !lc_b_is)) && r.only(lh_a_is, lh_b_is)) {
	// 			if(lh_a_is) {
	// 				println("HEART LH", lh);
	// 				println("LH AAAAA is ", lh_a_is);
	// 				printArray(list);
	// 				println("add lh.a()",lh.a());
	// 				shape.add_points(lh.b());
	// 				return true;
	// 			}
	// 			if(lh_b_is) {
	// 				println("HEART LH", lh);
	// 				println("LH BBBBB is ", lh_b_is);
	// 				println("add lh.a()",lh.a());
	// 				shape.add_points(lh.a());
	// 				return true;
	// 			}
	// 		} else if(r.only(lc_a_is, lc_b_is)) {
	// 			if(lc_a_is) {
	// 				shape.add_points(lc.b());
	// 				return true;
	// 			}
	// 			if(lc_b_is) {
	// 				shape.add_points(lc.a());
	// 				return true;
	// 			}
	// 		} else if(r.all(lc == null, !lc_a_is, !lc_b_is, !lh_a_is, !lh_b_is)) {
	// 			println("HEART LH", lh);
	// 			printArray(list);
	// 			println("add lh",lh);
	// 			shape.add_points(lh.b(),lh.a());
	// 			// shape.add_points(lh.a(),lh.b());
	// 			return true;
	// 		}
	// 		// } else {
	// 		// 	if(lc != null) {
	// 		// 		println("======================== NOTHING HAPPEN ============================");
	// 		// 		println("LC", lc);
	// 		// 		println("LH", lh);
	// 		// 	} else {
	// 		// 		println("----------------------- NOTHING HAPPEN ------------------------------");
	// 		// 		println("LC", lc);
	// 		// 		println("LH", lh);
	// 		// 	}
	// 		// }
	// 	}
	// 	return false;
	// }







	// UTILS POLYGON
	//////////////////

	private boolean id_line_circle_is(R_Line2DX lc, int im_0, int im_1) {
		int id_a = lc.id_a();
		int id_b = lc.id_b();
		// check for id line on heart
		
		if(id_a < 0 && abs(id_a) <= heart.size()) {
			id_a -= 1;
		}
		if(id_b < 0 && abs(id_b) <= heart.size()) {
			id_b -= 1;
		}
		// if(r.all(id_a != im_0, id_b != im_1)) {
		// 	println("TOUT FAUX", id_a, im_0, id_b, im_1, "LC", lc);
		// }
		// if(r.any(id_a < 0, id_b < 0)) {
		// 	println("A", id_a, "B", id_b, "LC",lc);
		// }
		// return r.any(abs(id_a) == im_0, abs(id_b) == im_1); // to check the negative id from heart // VERY BAD IDEA
		return r.any(id_a == im_0, id_b == im_1);
	}


	// ADD POINT POLYGON
	////////////////////

	// Big fix, for a messy code it's just trick to avoid the big refactoring
	private void add_points_go_alert_circle(ArrayList<R_Line2DX> list_main_b, R_Shape shape, R_Line2DX lh) {
		int index = 1;
		int index_next = shape.get_summits() -2;
		if(shape.get_summits() == 5) {
			index = 2;
		} else if (shape.get_summits() == 6) {
			index = 3;
		}
		add_points_go_impl(list_main_b, shape, lh, index, index_next);
	}

	private void add_points_go(ArrayList<R_Line2DX> list_main_b, R_Shape shape, R_Line2DX lh) {
		int index = 1;
		int index_next = shape.get_summits() -2;
		if(shape.get_summits() == 5) {
			index_next = shape.get_summits() -3;
		}
		add_points_go_impl(list_main_b, shape, lh, index, index_next);
	}

	private void add_points_go_impl(ArrayList<R_Line2DX> list_main_b, R_Shape shape, R_Line2DX lh, int index, int index_next) {
		int first = 0;
		int last = 0;
		vec3 a = shape.get_point(index);
		vec3 b = shape.get_point(index_next);

		for(int i = 0 ; i < list_main_b.size() ; i++) {
			R_Line2DX line = list_main_b.get(i);
			if(r.in_line(line, a.xy(), marge)) first = i;
			if(r.in_line(line, b.xy(), marge)) last = i;
		}

		// add point
		if(first < last) {
			for(int i = first ; i < last ; i++) {
				vec2 buf = list_main_b.get(i).b();
				index++;
				shape.add_point(index, buf.x(), buf.y());
			}
		} else if(first > last) {
			// it's for the center, because the order is reverse
			int count = first;
			for(int i = last ; i < first ; i++) {
				// reverse the order to put the point where this nust be
				count--;
				vec2 buf = list_main_b.get(count).b();
				index++;
				shape.add_point(index, buf.x(), buf.y());
			}
		}
		// heart_connexion(shape, lh, first, last);
	}




	private void add_points_return(ArrayList<R_Line2DX> list_main_a, R_Shape shape, R_Line2DX lh) {
		int first = 0;
		int last = 0;
		int index = shape.get_summits() -1;
		int index_next = 0;
		vec3 a = shape.get_point(index);
		vec3 b = shape.get_point(index_next);

		for(int i = 0 ; i < list_main_a.size() ; i++) {
			R_Line2DX line = list_main_a.get(i);
			// first
			if(r.in_line(line, a.xy(), marge)) first = i;
			// last
			if(r.in_line(line, b.xy(), marge)) last = i;
		}

		// the most of cases
		if(first > last) {
			for(int i = first ; i > last ; i--) {
				vec2 buf = list_main_a.get(i).a();
				index++;
				shape.add_point(index, buf.x(), buf.y());
			}
		}
		else if(first < last) {
			// it's for the center, because the order is reverse
			int count = first;
			for(int i = last ; i > first ; i--) {
				// reverse the order to put the point where this nust be
				count++;
				vec2 buf = list_main_a.get(count).a();
				index++;
				shape.add_point(index, buf.x(), buf.y());
			}
		} 
	}



	private void set_use_for_polygon(R_Line2DX line) {
		if(line.id_c() == Integer.MIN_VALUE) {
			line.id_c(1);
		} else {
			line.id_c(line.id_c() + 1);
		}
	}

	// private int get_use_for_polygon(R_Line2DX line) {
	// 	return line.id_c();
	// }

	private boolean touch_heart_is(R_Line2DX lc1, R_Line2DX lc2, R_Line2DX lh) {
		if(in_line(lh, lc1.a(), marge)) return true;
		if(in_line(lh, lc1.b(), marge)) return true;
		if(in_line(lh, lc2.a(), marge)) return true;
		if(in_line(lh, lc2.b(), marge)) return true;
		return false;
	}






































	



	////////////////////////////////
	// ADD POINT TO CLOUD
	////////////////////////////////

	// BUILD CLOUD POINT
	//////////////////////////////////

	private void add_cloud_points() {
		cloud.clear();
		int family = 0;
		// main point
		for(int i = 0 ; i < this.get_num_main() ; i++) {
			family = 0;
			add_points(this.get_main_lines(i), imp, family);
		}
		// circle point
		for(int i = 0 ; i < this.get_num_circle() ; i++) {
			family = 1;
			add_points(this.get_circle_lines(i), imp, family);
		}
		// heart
		family = 2;
		add_points(this.get_heart_lines(), imp, family);
		if(this.get_heart_polygon() != null) {
			vec2 [] polygon = this.get_heart_polygon();
		} else {
			cloud.add(new vec3(this.pos().x(),this.pos().y(),family));
		}
	}



	private void add_points(ArrayList<R_Line2DX> list, R_Impact imp, int family) {
		for(R_Line2DX line : list) {
			// check the center
			boolean a_is = this.pos().compare(line.a(), new vec2(marge));
			boolean b_is = this.pos().compare(line.b(), new vec2(marge));
			if(r.all((r.any(r.all(!a_is, !b_is, !line.mute_is()),!this.use_mute_is())),!a_is,!b_is)) { // that's work but too much complex
				vec3 a = new vec3(line.a().x(), line.a().y(), family);
				cloud.add(a);
				vec3 b = new vec3(line.b().x(), line.b().y(), family);
				cloud.add(b);
			}
		}
	}

	






































	///////////////////////////
	// PIXELS
	///////////////////////////

	public void pixel_mode(int mode) {
		this.mode_pixel_x = mode;
	}

	private int get_pixel_mode() {
		return this.mode_pixel_x;
	}

	// SET PIXELS
	///////////////////////////

	public void set_pixels(float normal_value, int... colour) {
		set_pixels_main(normal_value, colour);
		set_pixels_circle(normal_value, colour);
		set_pixels_heart(normal_value, colour);
	}

	public void set_pixels_main(float normal_value, int... colour) {
		set_pixels_list_impl(main, normal_value, colour);
	}

	public void set_pixels_circle(float normal_value, int... colour) {
		set_pixels_list_impl(circle, normal_value, colour);
	}

	public void set_pixels_heart(float normal_value, int... colour) {
		set_pixels_lines_impl(heart, normal_value, colour);
	}

	public void set_pixels_fail(float normal_value, int... colour) {
		set_pixels_lines_impl(fail, normal_value, colour);
	}

	private void set_pixels_list_impl(ArrayList<R_Line2DX>[] list, float normal_value, int... colour) {
		for(int i = 0 ; i < list.length ; i++) {
			set_pixels_lines_impl(list[i], normal_value, colour);
		}
	}

	private void set_pixels_lines_impl(ArrayList<R_Line2DX> lines, float normal_value, int... colour) {
		for(R_Line2DX line : lines) {
			line.set_pixels(normal_value, colour);
		}
	}

































	/////////////////////////////////
	// ANNEXE
	//////////////////////////////////



	// MUTE
	///////////////////

	public void set_mute_main(int main_index, int line_index, boolean state) {
		if(main_index >= 0 && line_index >= 0 && main_index < main.length && line_index < main[main_index].size()) {
			main[main_index].get(line_index).mute(state);
		} else {
			print_err("class R_Impact set_mute_main(int main_index, int line_index, boolean state): There is no list matching with main_index:",main_index, "or line_index:", line_index);
			this.pa.exit();
		}
	}

	public void set_mute_circle(int circle_index, int line_index, boolean state) {
		if(circle_index >= 0 && line_index >= 0 && circle_index < circle.length && line_index < circle[circle_index].size()) {
			circle[circle_index].get(line_index).mute(state);
		} else {
			print_err("class R_Impact set_mute_circle(int circle_index, int line_index, boolean state): There is no list matching with circle_index:",circle_index, "or line_index:", line_index);
			this.pa.exit();
		}
	}

	public void use_mute(boolean is) {
		this.use_mute_is = is;
	}

	public boolean use_mute_is() {
		return this.use_mute_is;
	}

	// ERROR
	////////////////////////////

	private void add_err(R_Line2DX line, vec2 buf_meet, vec2 [] tupple, String mess, boolean print_is) {
		int marge_error = 5;
		if(line.a().compare(line.b(),new vec2(marge_error))) {
			R_Line2DX fail_line = new R_Line2DX(this.pa,tupple[0], tupple[1]);
			fail.add(fail_line);
			if(print_is) {
				println("-------------------------------------------------------");
				println(mess);
				println("buf_meet", buf_meet);
				println("tupple  ", tupple[0], tupple[1]);
				println("ADDED FAIL LINE", fail_line);
				println("ligne en usage", line);
			}	
		}
	}


	

































	/////////////////////////////
	// SHOW
	////////////////////////////

	// SHOW PIXELS STATIC
	///////////////////////////

	public void show_pixels() {
		show_pixels_main();
		show_pixels_circle();
		show_pixels_heart();
	}

	public void show_pixels_main() {
		show_pixels_list_impl(main);
	}

	public void show_pixels_circle() {
		show_pixels_list_impl(circle);
	}

	public void show_pixels_heart() {
		show_pixels_lines_impl(heart);
	}

	public void show_pixels_fail() {
		show_pixels_lines_impl(fail);
	}

	private void show_pixels_list_impl(ArrayList<R_Line2DX>[] list) {
		for(int i = 0 ; i < list.length ; i++) {
			show_pixels_lines_impl(list[i]);
		}
	}

	private void show_pixels_lines_impl(ArrayList<R_Line2DX> lines) {
		for(R_Line2DX line : lines) {
			if(use_mute_is()) {
				if(!line.mute_is()) {
					line.show_pixels();
				}
			} else {
				line.show_pixels();
			}
		}
	}


	// SHOW PIXELS DYNAMIC
	///////////////////////////

	public void show_pixels(float normal_value, int... colour) {
		show_pixels_main(normal_value, colour);
		show_pixels_circle(normal_value, colour);
		show_pixels_heart(normal_value, colour);
	}

	public void show_pixels_main(float normal_value, int... colour) {
		show_pixels_list_impl(main, normal_value, colour);
	}

	public void show_pixels_circle(float normal_value, int... colour) {
		show_pixels_list_impl(circle, normal_value, colour);
	}

	public void show_pixels_heart(float normal_value, int... colour) {
		show_pixels_lines_impl(heart, normal_value, colour);
	}

	public void show_pixels_fail(float normal_value, int... colour) {
		show_pixels_lines_impl(fail, normal_value, colour);
	}

	private void show_pixels_list_impl(ArrayList<R_Line2DX>[] list, float normal_value, int... colour) {
		for(int i = 0 ; i < list.length ; i++) {
			show_pixels_lines_impl(list[i], normal_value, colour);
		}
	}

	private void show_pixels_lines_impl(ArrayList<R_Line2DX> lines, float normal_value, int... colour) {
		switch(get_pixel_mode()) {
			case 1: show_pixels_lines_impl_x1(lines, normal_value, colour); break;
			case 2: show_pixels_lines_impl_x2(lines, normal_value, colour); break;
			default: show_pixels_lines_impl_x1(lines, normal_value, colour); break;
		}
	}

	private void show_pixels_lines_impl_x1(ArrayList<R_Line2DX> lines, float normal_value, int... colour) {
		for(R_Line2DX line : lines) {
			if(use_mute_is()) {
				if(!line.mute_is()) {
					line.show_pixels(normal_value, colour);
				}
			} else {
				line.show_pixels(normal_value, colour);
			}
		}
	}

	private void show_pixels_lines_impl_x2(ArrayList<R_Line2DX> lines, float normal_value, int... colour) {
		for(R_Line2DX line : lines) {
			if(use_mute_is()) {
				if(!line.mute_is()) {
					line.show_pixels_x2(normal_value, colour);
				}
			} else {
				line.show_pixels_x2(normal_value, colour);
			}
		}
	}

	// SHOW LINE
	////////////////////////////

	public void show_line() {
		show_line_main();
		show_line_circle();
		show_line_heart();
	}

	public void show_line_main() {
		show_list_impl(main);
	}

	public void show_line_main(int index) {
		if(index >= 0 && index < main.length) {
			show_lines_impl(main[index]);	
		}
	}

	public void show_line_circle() {
		show_list_impl(circle);
	}
	
	public void show_line_circle(int index) {
		if(index >= 0 && index < circle.length) {
			show_lines_impl(circle[index]);	
		}
	}

	public void show_line_branch(int index) {
		for(int i = 0 ; i < circle.length ; i++) {
			for(int k = 0 ; k < circle[i].size() ; k++) {
				if(index == get_abs_id(circle[i].get(k).id().a())) {
					show_single_line_impl(circle[i].get(k));
				}		
			}
		}
	}

	public void show_line_heart() {
		show_lines_impl(heart);
	}

	public void show_line_fail() {
		show_lines_impl(fail);
	}

	private void show_list_impl(ArrayList<R_Line2DX>[] list) {
		for(int i = 0 ; i < list.length ; i++) {
			show_lines_impl(list[i]);
		}
	}

	private void show_lines_impl(ArrayList<R_Line2DX> lines) {
		for(R_Line2DX line : lines) {		
			show_single_line_impl(line);
			// if(use_mute_is()) {	
			// 	if(!line.mute_is()) {
			// 		line.show();
			// 	}
			// } else {
			// 	line.show();
			// }
		}
	}

	private void show_single_line_impl(R_Line2DX line) {
		if(use_mute_is()) {	
			if(!line.mute_is()) {
				line.show();
			}
		} else {
			line.show();
		}
	}

	// SHOW POLYGON
	////////////////////////

	public void show_polygon(int mode) {
		if(mode == -1) {
			noStroke();
			strokeWeight(0);
		} else if(mode == 0) {
			strokeWeight(2);
			stroke(r.GRIS[13]);
		} else {
			stroke(r.YELLOW);
		}
		// show_polygon_from(imp_shapes_circle);
		show_polygon_from(imp_shapes_center);
		// show_polygon_from(imp_shapes_rest);
		show_polygon_from(imp_shapes_orphan);
	}

	private void show_polygon_from(ArrayList<R_Shape> list) {
		boolean display_all = !keyPressed;
		for(R_Shape shape : list) {
			if(r.any(shape.id() == r.GRIS[4], 
								shape.id() == r.MAGENTA, 
								shape.id() == r.RED,
								shape.id() == r.GREEN, 
								shape.id() == r.CYAN,
								display_all)) {
				if(shape.id() != 0) {
					fill(shape.id());
				} else {
					fill(MAGENTA);
				}
				beginShape();
				for(int i = 0 ; i < shape.get_summits() ; i++) {
					vertex(shape.get_x(i), shape.get_y(i));
				}
				endShape(CLOSE);
			}
		}
	}



	// SHOW POINT
	//////////////////

	public void show_cloud() {
		noFill();
		stroke(WHITE);
		for(vec3 p : cloud) {
			switch((int)p.z()) {
				case 0:
					stroke(CYAN);
					circle(p.x(), p.y(), 15);
					break;
				case 1:
					stroke(MAGENTA);
					circle(p.x(), p.y(), 15);
					break;
				case 2:
					stroke(YELLOW);
					circle(p.x(), p.y(), 15);
					break;
				default:
					stroke(WHITE);
					circle(p.x(), p.y(), 15);
					break;
			}
		}
	}

	// SHOW DEBUGGER
	//////////////////

	public void show_bug() {
		show_bug_impl(main);
		show_bug_impl(circle);
		show_lines_bug_impl(heart);
		show_lines_bug_impl(fail);
	}

	private void show_bug_impl(ArrayList<R_Line2DX>[] list) {
		for(int i = 0 ; i < list.length ; i++) {
			show_lines_bug_impl(list[i]);
		}
	}

	private void show_lines_bug_impl(ArrayList<R_Line2DX> lines) {
		int marge_err = 5;
		for(R_Line2DX line : lines) {
			if(line.a().compare(line.b(),new vec2(marge_err))) {
				circle(line.a().x(),line.a().y(), 10);
			}
		}
	}


































	/////////////////////////////////////////////////////////
	// TEST
	//////////////////////////////////////////////////////////
	private ArrayList<vec3> heart_connexion(R_Shape shape, R_Line2DX lh, int first, int last) {
		ArrayList<vec3> buf = new ArrayList<vec3>();
		int same_same = 0;
		// int res = 0;
		if(lh != null) {
			vec3 ref = new vec3();
			for(vec3 v : shape.get_points()) {
				if(v.compare(ref, marge)) {
					same_same++;
					
				} else {
					if(v.xy().compare(lh.a(), marge)) buf.add(v);
					if(v.xy().compare(lh.b(), marge)) buf.add(v);
				}
				ref = v;
				// if(r.in_line(lh,v,marge) && !prev.compare(v, marge)) {
				// 	buf.add(v);
				// }
			}
		}
		if(buf.size() == 1 && same_same >= 2) {
			println("----------------------------------");
			if(first == 0 && last == 0) {
				println("DOUBLE ZERO", first, last);
			}
			println("connexion", buf.size());
			println("same", same_same);
			println("lh",lh);
			printArray(shape.get_points());
		}
		return buf;
	}


	private void test_line_no_id(int circle_rank, int line_rank) {
		R_Line2DX line = get_circle_lines(circle_rank).get(line_rank);
		if(!line.mute_is() && line.id_c() == Integer.MIN_VALUE) {
			boolean touch_is = line.a().compare(line.b(), marge);
			float dist = r.dist(line.a(), line.b());
			if(touch_is) {
				// println("PAS d'ID ça touche on s'en fout", line, "distance", dist, "circle", circle_rank);
			} else {
				if(circle_rank > 1) {
					println(">>>>>>>>>>>>>>>>>>> PAS d'ID : ON BOSSE", line, "distance", dist, "circle", circle_rank);	
				} else {
					println(">>>>>>>>>>>>>>>>>>> PAS d'ID : TRAVAILLER C'EST TROP DUR", line, "distance", dist, "circle", circle_rank);
				}
				
			}	
		}	
	}

	private void test_line_inf_to_1(int circle_rank, int line_rank) {
		R_Line2DX line = get_circle_lines(circle_rank).get(line_rank);
		if(!line.mute_is() && line.id_c() < 1) {		
			if(!line.a().compare(line.b(), marge)) {
				println(">>>>>>>>>>>>>>>>>>> NE SE TOUCHE PAS >>>>>>>>>>>>> ON BOSSE", line, "A", line.id_a(), "B", line.id_b(), "LINK", line.id_c());
				println("line", line_rank, "circle", circle_rank, "id AA", line.id_a(),  "id BB",line.id_b(), "id LINK", line.id_c());
			} else {
				println("ON S'EN FOUT", line, "id LINK", line.id_c());
				println("id",line.id());
			}
		}	
	}

	/////////////////////////////////////////
	// FIN DE TEST
	/////////////////////////////////////////


}

