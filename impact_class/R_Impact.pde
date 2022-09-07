/**
 * Impact or R_Impact
 * is an object to simulate the impact of hard object in glass
 * by extension that can simulate the spider web too
 * This algorithm make a part of the project "Éclat d'Ukraine"
 * 
 * v 0.1.0
 * copyleft(c) 2022-2022
 * by Stan le Punk aka Stanislas Marçais
 * 
 * 
 * 
 * */
 import rope.core.Rope;
import rope.costume.R_Line2D;
import rope.vector.vec2;


public class R_Impact extends Rope {
	PApplet pa;
	private ArrayList<R_Line2D>[] main_branch;
	private ArrayList<R_Line2D>[] circle_branch;

	private int mode = LINE;

	private int length_main_branch = 250;
	private int length_circle_branch = 250;
	private float resistance = 50;

	private int base = 5;
	private int num_branch = base;
	private int num_circle = base;
	private int num_iter = base;
	
	public R_Impact(PApplet pa) {
		this.pa = pa;
	}

	public R_Impact(PApplet pa, int base) {
		this.pa = pa;
		this.base = base;
		this.num_branch = base;
    this.num_circle = base;
    this.num_iter = base;
	}

	public void mode_spiral(int num_branch, int num_circle, int num_iter) {
		this.mode = SPIRAL;
		this.num_branch = num_branch;
		this.num_circle = num_circle;
		this.num_iter = num_iter;
	}

	public void mode_line(int num_branch, int num_circle, int num_iter) {
		this.mode = LINE;
		this.num_branch = num_branch;
		this.num_circle = num_circle;
		this.num_iter = num_iter;
	}

	public void build(int x, int y) {
		build_main_branch(x,y);
  	build_circle_branches(x,y);
	}

	//////////////
	// MAIN BRANCH
	//////////////


	public void build_main_branch(int x, int y) {
		main_branch = new ArrayList[num_branch];
		float angle_step = TAU / num_branch;
		float angle = 0;

		for(int i = 0 ; i < num_branch ; i++) {
			main_branch[i] = new ArrayList<R_Line2D>();
			main_branch_impl(i, x, y, angle);
			angle += angle_step;
		}
	}

	private void main_branch_impl(int index, float px, float py, float angle) {
		// float ref_power = power;
		float len = length_main_branch;
		float range_jit = TAU / num_branch * 0.1;
		float ax = px;
		float ay = py;
		float bx = 0;
		float by = 0;

		while(len > 0) {
			// distance
			float jit_distance = random(-resistance, resistance);
			len -= (resistance + jit_distance);
			float dist = length_main_branch - len;
			// direction
			float jit_direction = random(-range_jit, range_jit);
			float x = sin(angle + jit_direction) * dist;
			float y = cos(angle + jit_direction) * dist;
			bx = x + px;
			by = y + py;
			R_Line2D line = new R_Line2D(this.pa, ax, ay, bx, by);
			main_branch[index].add(line);
			ax = bx;
			ay = by;
		}
	}


	//////////////////////////
	// CIRCLE BRANCHES
	//////////////////////////

	private void build_circle_branches(int x, int y) {
	  circle_branch = new ArrayList[num_circle];

	  /////////////////////////////////////////////////
	  // A CHANGER, PAS BON cette histoire de distance
	  /////////////////////////////////////////////////
		float dist = 0;
		float dist_step = length_circle_branch / num_branch; 
		dist_step *= 1.2;

		for(int i = 0 ; i < num_circle ; i++) {
			circle_branch[i] = new ArrayList<R_Line2D>();
			dist += dist_step;
			circle_branch_impl(circle_branch[i], new vec2(x,y), dist);
		}
	}


	private void circle_branch_impl(ArrayList<R_Line2D> web_string, vec2 offset, float dist) {
		float start_angle = 0;

		////////////////////////////////////////////////////////////////////////////////////
		// peut-être il faudrait passer directement la valeur d'angle plutot que la calculer
		///////////////////////////////////////////////////////////////////////////////////
		float step_angle = TAU / num_branch;
		vec2 ang_set = new vec2(start_angle, step_angle);
		float fact_growth = 0.4;
		vec2 buf_meet = new vec2(-1);
		int count = 0;
		boolean jump_is = false;
		float buf_dist = dist;

	  while(count < num_iter) {
			R_Line2D line = draw_string_web(ang_set, offset, buf_dist, fact_growth);

			// here we catch the meeting point with the main branches
			vec2 [] tupple = meet_point(line, true);
			boolean good_tupple_is = false;
			if(tupple[0] != null && tupple[1] != null) {
				good_tupple_is = true;
			}
			jump_is = adjust_string_web(web_string, line, buf_meet, tupple, good_tupple_is, jump_is);
			// end part
			count++;
			if(mode == SPIRAL) {
				buf_dist = dist(line.b(),offset);
			}
			if(mode == LINE && count%num_branch == 0 && count <= web_string.size()) {
				int which_one = count - num_branch;
				close_string_web(web_string, which_one);
			}
	  }
	}


	/////////////////////////////
	// SHOW
	////////////////////////////
	public void show() {
		show_branch(main_branch);
		show_branch(circle_branch);
	}

	private void show_branch(ArrayList<R_Line2D>[] list) {
		for(int i = 0 ; i < list.length ; i++) {
			for(R_Line2D line : list[i]) {
				line.show();
			}
		}
	}



	/////////////////////////
	// ALGO CIRCLE BRANCH
	/////////////////////////

	private R_Line2D draw_string_web(vec2 ang_set, vec2 offset, float dist, float fact_growth) {
		float final_angle = ang_set.x();
		float ref_dist = dist;
		float ax = sin(final_angle) * dist + offset.x();
		float ay = cos(final_angle) * dist + offset.y();
		ang_set.x(ang_set.x() + ang_set.y());
		final_angle = ang_set.x();
		if(mode == SPIRAL) {
			dist += (fact_growth*8);
		}
		float bx = sin(final_angle) * dist + offset.x();
		float by = cos(final_angle) * dist + offset.y();
		R_Line2D line = new R_Line2D(this.pa , ax, ay, bx, by);
		line.change(fact_growth, fact_growth);
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
	  for(int i = 0; i < main_branch.length ; i++) {
	    for(R_Line2D buff_line : main_branch[i]) {
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
}