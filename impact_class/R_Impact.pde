/**
 * Impact or R_Impact
 * is an object to simulate the impact of hard object in glass
 * by extension that can simulate the spider web too
 * This algorithm make a part of the project "Éclat d'Ukraine"
 * 
 * v 0.1.2
 * copyleft(c) 2022-2022
 * by Stan le Punk aka Stanislas Marçais
 * 
 * 
 * 
 * */

import rope.core.Rope;
import rope.costume.R_Line2D;

import rope.vector.vec2;
import rope.vector.vec3;
import rope.vector.vec4;
import rope.vector.vec5;


public class R_Impact extends Rope {
	PApplet pa;
	private ArrayList<R_Line2D>[] main;
	private ArrayList<R_Line2D>[] circle;
	private ArrayList<R_Line2D> heart;
	private ArrayList<R_Line2D> fail;

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

	private int [] get_size_impl(ArrayList<R_Line2D>[] list, int len) {
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

	public ArrayList<R_Line2D> get_main(int index) {
		if(index >= 0 && index < main.length) {
			return main[index];
		}
		return null;
	}

	public ArrayList<R_Line2D> get_circle(int index) {
		if(index >= 0 && index < circle.length) {
			return circle[index];
		}
		return null;
	}

	public ArrayList<R_Line2D> get_heart() {
		return heart;
	}

	public ArrayList<R_Line2D> get_fail() {
		return fail;
	}



	///////////////////////////
	// BUILD
	///////////////////////////

	public void build(int x, int y) {
		// vec2 pos = new vec2(x,y);
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
	  			for(R_Line2D line : circle[i]) {
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

	}


	/////////////////////
	// BUILD MAIN BRANCH
	/////////////////////

	public void build_main() {
		main = new ArrayList[get_num_main()];
		float angle_step = TAU / get_num_main();
		float angle = 0;

		for(int i = 0 ; i < get_num_main() ; i++) {
			main[i] = new ArrayList<R_Line2D>();
			main_impl(i, angle);
			angle += angle_step;
		}
	}

	public void build_heart() {
		heart = new ArrayList<R_Line2D>();
		if(get_heart_main() > 0 ) {
			for(int i = 1 ; i < main.length ; i++) {
				vec2 a = main[i -1].get(0).a();
				vec2 b = main[i].get(0).a();
				R_Line2D line = new R_Line2D(this.pa, a, b);
				heart.add(line);
			}
			vec2 a = main[main.length -1].get(0).a();
			vec2 b = main[0].get(0).a();
			R_Line2D line = new R_Line2D(this.pa, a, b);
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
			R_Line2D line = new R_Line2D(this.pa, ax, ay, bx, by);
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
	//////////////////////////

	private void build_circle(float start_value) {
	  circle = new ArrayList[get_num_circle()];
	  fail = new ArrayList<R_Line2D>();

		float dist = 0;
		float dist_step = get_growth_circle() / get_num_main(); 

		for(int i = 0 ; i < get_num_circle() ; i++) {
			circle[i] = new ArrayList<R_Line2D>();
			float fact = i + start_value; // that work but to far from the center

			dist = (dist_step * fact);
			circle_impl(circle[i], dist);
			sort_circle(circle[i]);
		}
	}

	private void sort_circle(ArrayList<R_Line2D> circle_lines) {
		if(get_heart_main() > 0) {
			ArrayList<R_Line2D> selected_list = new ArrayList<R_Line2D>();
			ArrayList<R_Line2D> working_list = new ArrayList<R_Line2D>();
			ArrayList<R_Line2D> remove_list = new ArrayList<R_Line2D>();
			// list of vec2 point of the heart
			vec2 [] polygon = get_heart_polygon();
			// for(int i = 0 ; i < polygon.length ; i++) {
			// 	polygon[i] = heart.get(i).a().copy();
			// }
			// check all the lines web string point
			for(R_Line2D line : circle_lines) {
				boolean a_is = in_polygon(polygon, line.a());
				boolean b_is = in_polygon(polygon, line.b());
				// boolean a_is = in_polygon(polygon, line.a());
				// boolean b_is = in_polygon(polygon, line.b());
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
			for(R_Line2D line : selected_list) {
				circle_lines.add(line);
			}
			// cut the line if necessary
			for(R_Line2D line : working_list) {
				boolean a_is = in_polygon(polygon, line.a());
				vec2 inter = null;
				for(R_Line2D line_heart : heart) {
					inter = line_heart.intersection(line);
					if(inter != null) {
						R_Line2D new_line = new R_Line2D(this.pa);
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

	private void circle_impl(ArrayList<R_Line2D> circle_lines, float dist) {
		float start_angle = 0;
		float step_angle = TAU / get_num_main();
		vec2 ang_set = new vec2(start_angle, step_angle);
		vec2 buf_meet = new vec2(-1);
		boolean jump_is = false;
		float buf_dist = dist;

	  for(int count = 0 ; count < get_iter_circle();  count++){
			R_Line2D line = draw_string_web(ang_set, buf_dist);
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




	/////////////////////////
	// ALGO CIRCLE BRANCH
	/////////////////////////

	private R_Line2D draw_string_web(vec2 ang_set, float dist) {
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
		R_Line2D line = new R_Line2D(this.pa, ax, ay, bx, by);
		// increase the size of line to meet the main branches and find the meeting point to next step
		line.change(0.5, 0.5);
		line.set(line.a(),line.b());
		return line;
	}

	private boolean adjust_string_web(ArrayList<R_Line2D> circle_lines, R_Line2D line, vec2 buf_meet, vec2 [] tupple, boolean good_tupple_is, boolean jump_is) {
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


	private void close_string_web(ArrayList<R_Line2D> circle_lines, int index) {
		if(index < circle_lines.size()) {
			vec2 last = circle_lines.get(index).a();
			int max = circle_lines.size() -1;
			R_Line2D line = new R_Line2D(this.pa ,circle_lines.get(max).a(), last);
			circle_lines.remove(max);
			circle_lines.add(line);
		}
	}

	private vec2 [] meet_point( R_Line2D line, boolean two_points_is) {
		// the temporary list to work
		ArrayList<ArrayList> buf_list = new ArrayList<ArrayList>();
		for(int i = 0; i < main.length ; i++) {
			ArrayList<R_Line2D> temp = new ArrayList<R_Line2D>();
			// put the first point to center of the impact
			R_Line2D temp_line_first = main[i].get(0);
			temp_line_first.a(this.pos.x(), this.pos.y());
			temp.add(temp_line_first.copy());
			for(int k = 1 ; k < main[i].size(); k++) {
				R_Line2D temp_line_next = main[i].get(k).copy();
				temp.add(temp_line_next);
			}
			buf_list.add(temp);
		}

		// the sort
		vec2 [] meet = new vec2[2];
		for(ArrayList<R_Line2D> list : buf_list) {
			for(R_Line2D buff_line : list) {
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



	/////////////////////////
	// ERROR
	////////////////////////////

	private void add_err(R_Line2D line, vec2 buf_meet, vec2 [] tupple, String mess, boolean print_is) {
		int marge_error = 5;
		if(line.a().compare(line.b(),new vec2(marge_error))) {
			R_Line2D fail_line = new R_Line2D(this.pa,tupple[0], tupple[1]);
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

	private void set_pixels_list_impl(ArrayList<R_Line2D>[] list, float normal_value, int... colour) {
		for(int i = 0 ; i < list.length ; i++) {
			set_pixels_lines_impl(list[i], normal_value, colour);
		}
	}

	private void set_pixels_lines_impl(ArrayList<R_Line2D> lines, float normal_value, int... colour) {
		for(R_Line2D line : lines) {
			line.set_pixels(normal_value, colour);
		}
	}

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

	private void show_pixels_list_impl(ArrayList<R_Line2D>[] list) {
		for(int i = 0 ; i < list.length ; i++) {
			show_pixels_lines_impl(list[i]);
		}
	}

	private void show_pixels_lines_impl(ArrayList<R_Line2D> lines) {
		for(R_Line2D line : lines) {
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

	private void show_pixels_list_impl(ArrayList<R_Line2D>[] list, float normal_value, int... colour) {
		for(int i = 0 ; i < list.length ; i++) {
			show_pixels_lines_impl(list[i], normal_value, colour);
		}
	}

	private void show_pixels_lines_impl(ArrayList<R_Line2D> lines, float normal_value, int... colour) {
		switch(get_pixel_mode()) {
			case 1: show_pixels_lines_impl_x1(lines, normal_value, colour); break;
			case 2: show_pixels_lines_impl_x2(lines, normal_value, colour); break;
			default: show_pixels_lines_impl_x1(lines, normal_value, colour); break;
		}
	}

	private void show_pixels_lines_impl_x1(ArrayList<R_Line2D> lines, float normal_value, int... colour) {
		for(R_Line2D line : lines) {
			if(use_mute_is()) {
				if(!line.mute_is()) {
					line.show_pixels(normal_value, colour);
				}
			} else {
				line.show_pixels(normal_value, colour);
			}
		}
	}

	private void show_pixels_lines_impl_x2(ArrayList<R_Line2D> lines, float normal_value, int... colour) {
		for(R_Line2D line : lines) {
			if(use_mute_is()) {
				if(!line.mute_is()) {
					line.show_pixels_x2(normal_value, colour);
				}
			} else {
				line.show_pixels_x2(normal_value, colour);
			}
		}
	}





	/////////////////////////////
	// SHOW
	////////////////////////////
	public void show() {
		show_main();
		show_circle();
		show_heart();
	}

	public void show_main() {
		show_list_impl(main);
	}

	public void show_circle() {
		show_list_impl(circle);
	}

	public void show_heart() {
		show_lines_impl(heart);
	}

	public void show_fail() {
		show_lines_impl(fail);
	}

	private void show_list_impl(ArrayList<R_Line2D>[] list) {
		for(int i = 0 ; i < list.length ; i++) {
			show_lines_impl(list[i]);
		}
	}

	private void show_lines_impl(ArrayList<R_Line2D> lines) {
		for(R_Line2D line : lines) {		
			if(use_mute_is()) {
				if(!line.mute_is()) {
					line.show();
				}
			} else {
				line.show();
			}
		}
	}

	// DEBUGGER
	///////////

	public void show_bug() {
		show_bug_impl(main);
		show_bug_impl(circle);
		show_lines_bug_impl(heart);
		show_lines_bug_impl(fail);
	}

	private void show_bug_impl(ArrayList<R_Line2D>[] list) {
		for(int i = 0 ; i < list.length ; i++) {
			show_lines_bug_impl(list[i]);
		}
	}

	private void show_lines_bug_impl(ArrayList<R_Line2D> lines) {
		int marge_err = 5;
		for(R_Line2D line : lines) {
			if(line.a().compare(line.b(),new vec2(marge_err))) {
				circle(line.a().x(),line.a().y(), 10);
			}
		}
	}
}