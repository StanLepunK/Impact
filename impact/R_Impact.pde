/**
 * Impact or R_Impact
 * is an object to simulate the impact of hard object in glass
 * by extension that can simulate the spider web too
 * This algorithm make a part of the project "Éclat d'Ukraine"
 * 
 * v 0.2.0
 * copyleft(c) 2022-2022
 * by Stan le Punk aka Stanislas Marçais
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
	private ArrayList<R_Shape> imp_shapes_circle = new ArrayList<R_Shape>();
	private ArrayList<R_Shape> imp_shapes_heart = new ArrayList<R_Shape>();
	private ArrayList<R_Shape> imp_shapes_rest = new ArrayList<R_Shape>();
	// POINT
	private ArrayList<vec3> imp_pts = new ArrayList<vec3>();

	private vec2 pos;

	private int mode = LINE;

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

	public float get_heart_main() {
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

	// GET LIST LINE
	/////////////////////

	public ArrayList<R_Line2DX> get_main(int index) {
		if(index >= 0 && index < main.length) {
			return main[index];
		}
		return null;
	}

	public ArrayList<R_Line2DX> get_circle(int index) {
		if(index >= 0 && index < circle.length) {
			return circle[index];
		}
		return null;
	}

	public ArrayList<R_Line2DX> get_heart() {
		return heart;
	}

	public ArrayList<R_Line2DX> get_fail() {
		return fail;
	}



	///////////////////////////
	// BUILD
	///////////////////////////

	public void build(int x, int y) {
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
		//
		set_id_circle();
		add_cloud_points();
		build_polygon_impact();	
	}


	/////////////////////
	// BUILD MAIN BRANCH

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
		if(get_heart_main() > 0 ) {
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
			if(i == 0 && get_heart_main() > 0) {
				line.change(-get_heart_main(),0);
				// to make the changement for ever !!!
				line.set(line.a(),line.b());
			}
			main[index].add(line);
			ax = bx;
			ay = by;
		}
	}






	//////////////////////////
	// BUILD CIRCLE BRANCHES

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
		if(get_heart_main() > 0) {
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

	// BUILD CLOUD POINT
	//////////////////////////////////

	private void add_cloud_points() {
		imp_pts.clear();
		int family = 0;
		// main point
		for(int i = 0 ; i < this.get_num_main() ; i++) {
			family = 0;
			add_points(this.get_main(i), imp, family);
		}

		// circle point
		for(int i = 0 ; i < this.get_num_circle() ; i++) {
			family = 1;
			add_points(this.get_circle(i), imp, family);
		}
		// heart
		family = 2;
		add_points(this.get_heart(), imp, family);
		if(this.get_heart_polygon() != null) {
			vec2 [] polygon = this.get_heart_polygon();
		} else {
			imp_pts.add(new vec3(this.pos().x(),this.pos().y(),family));
		}
	}

	// BUILD POLYGON
	///////////////////////////

	private void build_polygon_impact() {
		// println("NEW BUILD POLYGON====================================");
		ArrayList<vec2>poly = new ArrayList<vec2>();
		// clear polygon
		imp_shapes_circle.clear();
		imp_shapes_heart.clear();
		imp_shapes_rest.clear();

		int count_info = 0;
		int max_main = this.get_num_main();
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
		// println("there is",imp_shapes_circle.size(),"basic polygons");
		// println("there is",imp_shapes_heart.size(),"heart polygons");
		// println("there is",imp_shapes_rest.size(),"rest polygons");
	}

	// BUILD POLYGON REST
	//////////////////////////

	private void build_single_polygon_rest(int im_0, int im_1) {
		R_Shape shape = new R_Shape(this.pa);
		shape.id(r.GRIS[2]);

		// find the last circle elem not mute and add it
		int max_circle = this.get_num_circle()-1;
		boolean bingo_is = false;
		// go from the max to minimum
		for(int k = max_circle ; k >= 0 ; k--) {
			for(R_Line2DX lc : this.get_circle(k)) {
				
				if(lc.id_a() == im_0 && !lc.mute_is()) {
					create_polygon_rest(lc, shape, this.get_main(im_0), this.get_main(im_1));
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

	private void create_polygon_rest(R_Line2DX lc, R_Shape shape, ArrayList<R_Line2DX> main_a, ArrayList<R_Line2DX> main_b) {
		R_Line2DX lm_0 = main_a.get(main_a.size() -1);
		R_Line2DX lm_1 = main_b.get(main_b.size() -1);
		shape.add_points(lm_0.b(), lm_1.b());
		shape.add_points(lc.b(), lc.a());
		add_points_go(main_b, shape);
		add_points_return(main_a, shape);
	}

	// BUILD POLYGON CIRCLE
	/////////////////////////

	private void build_single_basic_polygon_from_circle(int im_0, int im_1) {
		boolean bingo_is = false;
		int max_circle = this.get_num_circle();
		for(int k = 0 ; k < max_circle ; k++) {
			bingo_is = false;
			for(R_Line2DX lc1 : this.get_circle(k)) {
				if(lc1.id_a() == im_0 && !lc1.mute_is()) {
					for(int m = k + 1 ; m < max_circle ;m++) {
						for(R_Line2DX lc2 : this.get_circle(m)) {
							if(lc2.id_a() == im_0 && !lc2.mute_is()) {
								create_polygon_circle(lc1, lc2, this.get_main(im_0), this.get_main(im_1));
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


	private void create_polygon_circle(R_Line2DX lc1, R_Line2DX lc2, ArrayList<R_Line2DX> main_a, ArrayList<R_Line2DX> main_b) {
		R_Shape shape = new R_Shape(this.pa);
		shape.id(r.GRIS[4]);
		shape.add_points(lc1.a(), lc1.b());
		shape.add_points(lc2.b(), lc2.a());
		add_points_go(main_b, shape);
		add_points_return(main_a, shape);
		imp_shapes_circle.add(shape);
	}


	// BUILD POLYGON HEART
	///////////////////////////

	private void build_single_polygon_from_heart(int im_0, int im_1) {
		R_Line2DX lh = null;
		R_Line2DX lc = null;
		R_Line2DX prev_lc = null;
		int max_circle = this.get_num_circle();
		// THE PURE HEART
		create_polygon_heart();
		// REGULAR
		boolean bingo_is = false;
		for(int index_c = 0 ; index_c < max_circle ; index_c++) {
			if(this.get_heart().size() > 0 && im_0 < this.get_heart().size()) {
				lh = this.get_heart().get(im_0);
			}
			if(this.get_circle(index_c) != null && this.get_circle(index_c).size() > 0) {
				for(int index_lc = 0 ; index_lc < this.get_circle(index_c).size() ; index_lc++) {
					lc = this.get_circle(index_c).get(index_lc);
					if(r.all(!lc.mute_is(), r.any(lc.id_a() == im_0, lc.id_b() == im_1))) {
						create_polygon_center(lh, lc, prev_lc, this.get_main(im_0), this.get_main(im_1));
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

	private boolean break_if(R_Line2DX lh, R_Line2DX lc) {
		if(r.any(lh == null)) {
			return true;
		}
		float marge = 3;
		return !r.any(r.in_line(lh.a(),lh.b(), lc.a(),marge), r.in_line(lh.a(),lh.b(), lc.b(),marge));
	}

	private void create_polygon_heart() {
		R_Shape shape = new R_Shape(this.pa);
		shape.id(r.GRIS[1]);
		for(R_Line2DX lh : this.get_heart()) {
			shape.add_points(lh.a());
		}
		imp_shapes_heart.add(shape);
	}

	private void create_polygon_center(R_Line2DX lh, R_Line2DX lc, R_Line2DX prev_lc, ArrayList<R_Line2DX> main_a, ArrayList<R_Line2DX> main_b) {
		R_Shape shape = new R_Shape(this.pa);
		shape.id(r.GRIS[11]);
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
			shape.add_point(this.pos().x(), this.pos().y());
		}
		add_points_go(main_b, shape);
		add_points_return(main_a, shape);
		imp_shapes_heart.add(shape);
	}

	private void add_point_first_level_polygon_center(R_Shape shape, R_Line2DX lh, R_Line2DX lc, vec2 point) {
		float marge = 3;
		boolean a_is = r.in_line(lh.a(),lh.b(), lc.a(), marge);
		boolean b_is = r.in_line(lh.a(),lh.b(), lc.b(), marge);
		if(r.all(!a_is, !b_is)) {
			shape.add_points(lh.b(),lh.a());
		} else {
			shape.add_points(point);
		}
	}

	private void add_points_next_level_polygon_center(R_Shape shape, R_Line2DX lh, R_Line2DX lc, R_Line2DX prev_lc) {
		float marge = 3;
		boolean a_prev_is = false;
		boolean b_prev_is = false;
		boolean a_is = r.in_line(lh.a(),lh.b(), lc.a(), marge);
		boolean b_is = r.in_line(lh.a(),lh.b(), lc.b(), marge);

		if(r.all(!a_is, !b_is)) {
			a_prev_is = r.in_line(lh.a(),lh.b(), prev_lc.a(), marge);
			b_prev_is = r.in_line(lh.a(),lh.b(), prev_lc.b(), marge);
			if(a_prev_is) {
				shape.id(r.GRIS[8]);
				shape.add_points(prev_lc.b(), prev_lc.a(), lh.a());
				return;
			}
			if(b_prev_is) {
				shape.id(r.GRIS[6]);
				shape.add_points(lh.b(), prev_lc.b(), prev_lc.a());
				return;
			}
		}
		shape.add_points(prev_lc.b(),prev_lc.a());
	}




	// ADD POINT
	////////////////////

	private void add_points(ArrayList<R_Line2DX> list, R_Impact imp, int family) {
		float marge = 3;
		for(R_Line2DX line : list) {
			// check the center
			boolean a_is = this.pos().compare(line.a(), new vec2(marge));
			boolean b_is = this.pos().compare(line.b(), new vec2(marge));
			if(r.all((r.any(r.all(!a_is, !b_is, !line.mute_is()),!this.use_mute_is())),!a_is,!b_is)) { // that's work but too much complex
				vec3 a = new vec3(line.a().x(), line.a().y(), family);
				imp_pts.add(a);
				vec3 b = new vec3(line.b().x(), line.b().y(), family);
				imp_pts.add(b);
			}
		}
	}

	// ADD POINT POLYGON
	////////////////////

	private void add_points_go(ArrayList<R_Line2DX> lms, R_Shape shape) {
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


	private void add_points_return(ArrayList<R_Line2DX> lms, R_Shape shape) {
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

	// ID CIRCLE
	///////////////////////

	private void set_id_circle() {
		for(int i = 0 ; i < circle.length ; i++) {
			for(int k = 0 ; k < main.length ; k++) {
				for(R_Line2DX lc : circle[i]) {
					for(R_Line2DX lm : main[k]) {
						float marge = 2;
						if(in_line(lm.a(),lm.b(),lc.a(),marge)) {
							lc.id_a(k);
						}
						if(in_line(lm.a(),lm.b(),lc.b(),marge)) {
							lc.id_b(k);
						}
					}
				}
			}
		}
	}

	// MUTE
	///////////////////

	public void set_mute_main(int main_index, int line_index, boolean state) {
		if(main_index >= 0 && line_index >= 0 && main_index < main.length && line_index < main[main_index].size()) {
			main[main_index].get(line_index).mute(state);
		} else {
			print_err("class R_Impact set_mute_main(int main_index, int line_index, boolean state): There is no list matching with main_index:",main_index, "or line_index:", line_index);
			pa.exit();
		}
	}

	public void set_mute_circle(int circle_index, int line_index, boolean state) {
		if(circle_index >= 0 && line_index >= 0 && circle_index < circle.length && line_index < circle[circle_index].size()) {
			circle[circle_index].get(line_index).mute(state);
		} else {
			print_err("class R_Impact set_mute_circle(int circle_index, int line_index, boolean state): There is no list matching with circle_index:",circle_index, "or line_index:", line_index);
			pa.exit();
		}
	}

	public void use_mute(boolean is) {
		this.use_mute_is = is;
	}

	public boolean use_mute_is() {
		return use_mute_is;
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

	public void show_line_circle() {
		show_list_impl(circle);
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
			if(use_mute_is()) {
				if(!line.mute_is()) {
					line.show();
				}
			} else {
				line.show();
			}
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
		show_polygon_from(imp_shapes_circle);
		show_polygon_from(imp_shapes_heart);
		show_polygon_from(imp_shapes_rest);
	}

	public void show_polygon_from(ArrayList<R_Shape> list) {
		// println("list.size()", list.size());
		for(R_Shape shape : list) {
			if(shape.id()!= 0) {
				fill(shape.id());
			} else {
				fill(MAGENTA);
			}
			// println(" shape.get_summits()",  shape.get_summits());
			beginShape();
			for(int i = 0 ; i < shape.get_summits() ; i++) {
				vertex(shape.get_x(i), shape.get_y(i));
			}
			endShape(CLOSE);
		}
	}

	// SHOW POINT
	//////////////////

	public void show_cloud() {
		noFill();
		stroke(WHITE);
		for(vec3 p : imp_pts) {
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
}

