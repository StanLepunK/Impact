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

	private int mode = LINE;

	private boolean use_mute_is = false;


	private float growth_fact_spiral = 1;

	private int base = 5;
	private vec5 data_main = new vec5();
	private vec3 data_circle = new vec3();
	
	public R_Impact(PApplet pa) {
		this.pa = pa;
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


	///////////////////////////
	// BUILD
	///////////////////////////

	public void build(int x, int y) {
		vec2 pos = new vec2(x,y);
		build_main(pos);
		build_heart();
  	
  	// hack algo to avoid the bug center when the spiral don't start
  	float start_value = 0;
  	if(mode == SPIRAL) {
  		boolean spiral_is_good = false;
  		vec2 area = new vec2(2);
  		int threshold_critic = get_num_main() * 2;
	  	while(!spiral_is_good) {
				int threshold = 0;
	  		build_circle(pos,start_value);
	  		for(int i = 0 ; i < get_num_circle() ; i++) {
	  			for(R_Line2D line : circle[i]) {
						if(line.a().compare(pos,area)) {
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
  	build_circle(pos, 0);	

	}


	/////////////////////
	// BUILD MAIN BRANCH
	/////////////////////

	public void build_main(vec2 pos) {
		main = new ArrayList[get_num_main()];
		float angle_step = TAU / get_num_main();
		float angle = 0;

		for(int i = 0 ; i < get_num_main() ; i++) {
			main[i] = new ArrayList<R_Line2D>();
			main_impl(i, pos, angle);
			angle += angle_step;
		}
	}

	public void build_heart() {
		heart = new ArrayList<R_Line2D>();
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

	private void main_impl(int index, vec2 pos, float angle) {
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
			bx = x + pos.x();
			by = y + pos.y();
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

	private void build_circle(vec2 pos, float start_value) {
	  circle = new ArrayList[get_num_circle()];

		float dist = 0;
		float dist_step = get_growth_circle() / get_num_main(); 

		for(int i = 0 ; i < get_num_circle() ; i++) {
			circle[i] = new ArrayList<R_Line2D>();
			float fact = i + start_value; // that work but to far from the center

			dist = (dist_step * fact);
			circle_impl(circle[i], pos, dist);
		}
	}

	private void circle_impl(ArrayList<R_Line2D> web_string, vec2 offset, float dist) {
		float start_angle = 0;
		float step_angle = TAU / get_num_main();
		vec2 ang_set = new vec2(start_angle, step_angle);
		vec2 buf_meet = new vec2(-1);
		int count = 0;
		boolean jump_is = false;
		float buf_dist = dist;

	  while(count < get_iter_circle()) {
			R_Line2D line = draw_string_web(ang_set, offset, buf_dist);
			// here we catch the meeting point with the main branches
			vec2 [] tupple = meet_point(line, true);
			boolean good_tupple_is = false;
			if(tupple[0] != null && tupple[1] != null) {
				good_tupple_is = true;
				// the moment where the turn is done and it's time to go to next level
				if((count+1)%get_num_main() == 0 && mode == SPIRAL) {
					vec2 swap = tupple[0];
					tupple[0] = tupple[1];
					tupple[1] = swap;
				}
			}
			jump_is = adjust_string_web(web_string, line, buf_meet, tupple, good_tupple_is, jump_is);

			count++;
			if(mode == SPIRAL) {
				buf_dist = dist(line.b(),offset);
			}

			if(mode == LINE && count%get_num_main() == 0 && count <= web_string.size()) {
				int which_one = count - get_num_main();
				close_string_web(web_string, which_one);
			}
	  }
	}




	/////////////////////////
	// ALGO CIRCLE BRANCH
	/////////////////////////

	private R_Line2D draw_string_web(vec2 ang_set, vec2 offset, float dist) {
		float final_angle = ang_set.x();
		// float ref_dist = dist;
		float ax = sin(final_angle) * dist + offset.x();
		float ay = cos(final_angle) * dist + offset.y();
		ang_set.x(ang_set.x() + ang_set.y());
		final_angle = ang_set.x();
		if(mode == SPIRAL) {
			dist += get_growth_spiral();
			// println("dist", dist, "get_growth_spiral()",get_growth_spiral());
		}
		float bx = sin(final_angle) * dist + offset.x();
		float by = cos(final_angle) * dist + offset.y();
		R_Line2D line = new R_Line2D(this.pa, ax, ay, bx, by);
		// increase the size of line to meet the main branches and find the meeting point to next step
		line.change(0.5, 0.5);
		line.set(line.a(),line.b());
		return line;
	}

	private boolean adjust_string_web(ArrayList<R_Line2D> web_string, R_Line2D line, vec2 buf_meet, vec2 [] tupple, boolean good_tupple_is, boolean jump_is) {
		if(!good_tupple_is) {
			jump_is = true;
	  } else {
			if(buf_meet.equals(-1) || jump_is) {  
				line.set(tupple[0],tupple[1]);
				web_string.add(line);
				buf_meet.set(tupple[1].x(),tupple[1].y());
				jump_is = false;
			} else {
				line.set(buf_meet,tupple[1]);
				web_string.add(line);
				buf_meet.set(tupple[1]);
			}
		}
		return jump_is;
	}


	private void close_string_web(ArrayList<R_Line2D> web_string, int whitch_one) {
		vec2 last = web_string.get(whitch_one).a();
		int max = web_string.size() -1;
		R_Line2D line = new R_Line2D(this.pa ,web_string.get(max).a(), last);
		web_string.remove(max);
		web_string.add(line);
	}

	private vec2 [] meet_point(R_Line2D line, boolean two_points_is) {
		vec2 [] meet = new vec2[2];
		for(int i = 0; i < main.length ; i++) {
			for(R_Line2D buff_line : main[i]) {
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




	/////////////////////////////
	// SHOW
	////////////////////////////
	public void show() {
		show_main();
		show_circle();
		show_heart();
	}

	public void show_main() {
		show_impl(main);
	}

	public void show_circle() {
		show_impl(circle);
	}

	public void show_heart() {
		show_lines(heart);
	}


	private void show_impl(ArrayList<R_Line2D>[] list) {
		for(int i = 0 ; i < list.length ; i++) {
			show_lines(list[i]);
			// for(R_Line2D line : list[i]) {
			// 	if(use_mute_is()) {
			// 		if(!line.mute_is()) {
			// 			line.show();
			// 		}
			// 	} else {
			// 		line.show();
			// 	}
			// }
		}
	}


	private void show_lines(ArrayList<R_Line2D> lines) {
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
}