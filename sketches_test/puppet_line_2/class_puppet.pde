import rope.vector.bvec2;
import rope.utils.R_Pair;

class R_Puppet2D extends R_Line2D {
	ArrayList<R_Pair> pair_list = new ArrayList<R_Pair>();
	ArrayList<vec3> list = new ArrayList<vec3>();
	ArrayList<vec3> ref_list = new ArrayList<vec3>();
	R_Puppet2D buffer;

	vec2 start_a;
	vec2 start_b;
	R_Puppet2D (PApplet pa) {
		super(pa);
		this.start_a = new vec2();
    this.start_b = new vec2();
		
	}

	vec2 test = new vec2();
	public void update() {
		bvec2 is = new bvec2(!a.equals(ref_a), !b.equals(ref_b));
		if(is.a()) {
			update_list_a();
			ref_a(a.xy());
		}
		if(is.b()) {
			update_list_b();
			ref_b(b.xy());
		}
	}

	private void update_list_a() {
		vec2 buf_start = start_a.xy().sub(start_b.xy());
		vec2 buf = a.xy().sub(b.xy());
		vec2 buf_ref = ref_a.xy().sub(ref_b.xy());
		float ang_buf = buf.angle();
		float ang_ref_buf = buf_ref.angle();
		float dif_ang = ang_ref_buf - ang_buf;
		R_Pair <vec3, vec3>pair = new R_Pair<vec3, vec3>(b, a);
		update_list_impl(pair, dif_ang, ang_buf, buf_start.angle());
	}

	private void update_list_b() {
		vec2 buf_start = start_b.xy().sub(start_a.xy());
		vec2 buf = b.xy().sub(a.xy());
		vec2 buf_ref = ref_b.xy().sub(ref_a.xy());
		float ang_buf = buf.angle();
		float ang_ref_buf = buf_ref.angle();
		float dif_ang = ang_ref_buf - ang_buf;
		R_Pair <vec3, vec3>pair = new R_Pair<vec3, vec3>(a, b);
		update_list_impl(pair, dif_ang, ang_buf, buf_start.angle());
	}
	
	private void update_list_impl(R_Pair <vec3, vec3>pair, float dif_ang, float ang_buf, float ang_buf_start) {
		vec3 first = pair.a();
		vec3 second = pair.b();
		for(int i = 0 ; i < list.size() ; i++) {
			vec3 p = list.get(i);
			vec3 ref_p = ref_list.get(i);
			vec2 buf_p = ref_p.xy().sub(first.xy());
			float ang_buf_p = buf_p.angle();
			float new_ang = ang_buf_p + dif_ang + ang_buf + TAU - ang_buf_start;
			float dist_p = dist(ref_p,second);
			float ratio = dist() / start_a.dist(start_b);
			// println("ratio", ratio);
			// float ref_dist = this.dist_ref();
			vec2 new_pos = new vec2(projection(new_ang, dist_p));
			new_pos = add(new_pos, first.xy());
			p.set(new_pos.xyz());
		}
	}



  public void set_a(float x, float y) {
    this.a(x,y);
    this.ref_a(x,y);
    this.start_a(x,y);;
  }

	public void start_a(vec2 start_a) {
    this.start_a(start_a.x(),start_a.y());
  }
  
  public void start_a(float x, float y) {
    this.start_a.set(x,y);
  }

	public void set_b(float x, float y) {
    this.b(x,y);
    this.ref_b(x,y);
    this.start_b(x,y);
  }

	public void start_b(vec2 start_b) {
    this.start_b(start_b.x(),start_b.y());
  }
  
  public void start_b(float x, float y) {
    this.start_b.set(x,y);
  }

	public void add(vec3... children) {
		if(buffer == null) {
			buffer = new R_Puppet2D(this.pa);
			buffer.set(this.a(), this.b());
			buffer.change(100,100);
			buffer.set(buffer.a(), buffer.b());
		}

		for(int i = 0 ; i < children.length ; i++) {
			float norm = 0;
			float dist = 0;
			float dir = 1;
			
			vec2 proj = this.ortho(children[i].xy());
			norm = this.normal(proj);
			dist = proj.dist(children[i].xy());
			// line(children[i].x(),children[i].y(),proj.x(), proj.y());
			// circle(proj.x(), proj.y(),10);
			float buf_dir = proj.angle();
			println("ortho line >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>",children[i], proj);
			float ang_child_proj = children[i].xy().angle(proj.xy());
			float ang_proj_child = proj.xy().angle(children[i].xy());
			float ang_b_a = this.b().angle(this.a());
			float ang_a_b = this.a().angle(this.b());
			println("children[i].angle(proj)", ang_child_proj); // ce sont les bonnes infos
			println("proj.angle(children[i])", ang_proj_child); // ce sont les bonnes infos
			println(">>> children[i].xy().angle()",children[i].xy().angle());
			println(">>> buf_dir",buf_dir);
			println(">>> this.b().angle()",this.b().angle());
			println(">>> this.a().angle()",this.a().angle());
			println("this.b().angle(this.a()", ang_b_a); // ce sont les bonnes infos
			println("this.a().angle(this.b()", ang_a_b); // ce sont les bonnes infos

			println("ang_b_a - ang_child_proj",ang_b_a - ang_child_proj); // ok
			println("ang_child_proj - ang_b_a", ang_child_proj - ang_b_a); // ok
			println("ang_a_b - ang_proj_child",ang_b_a - ang_proj_child); // ok
			println("ang_proj_child - ang_a_b",ang_proj_child - ang_a_b); // ok

			dir = (ang_child_proj - ang_b_a) + ang_b_a;
			vec3 data = new vec3(norm, dist, dir);
			println("data",data);


			R_Pair<vec3,vec3> pair = new R_Pair<vec3,vec3>(children[i], data);
			pair_list.add(pair);
			list.add(children[i]);
			ref_list.add(children[i].copy());
		}
	}

	private void update_children() {
		for(int i = 0 ; i < ref_list.size() ; i++) {
			ref_list.get(i).set(list.get(i));
		}
	}

	public ArrayList<vec3> get_children() {
		return list;
	}

	public R_Pair get_child(int index) {
		if(index >= 0 && index < pair_list.size()) {
			return pair_list.get(index);
		}
		return null;
	}

	public void clear() {
		list.clear();
		ref_list.clear();
		pair_list.clear();
	}

	public vec2 ortho(vec2 p) {
		vec2 proj = b.xy().ortho(a.xy(), p);
		return new vec2(proj.x(), proj.y());
	}
}