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


  //////////////////////////////
  // CHILDREN
  /////////////////////////////////

	public void add(vec3... children) {
		if(buffer == null) {
			buffer = new R_Puppet2D(this.pa);
			buffer.set(this.a(), this.b());
			buffer.change(100,100);
			buffer.set(buffer.a(), buffer.b());
		}

		for(int i = 0 ; i < children.length ; i++) {
			vec3 data = new vec3();
			set_data_child(children[i], data);
			R_Pair<vec3,vec3> pair = new R_Pair<vec3,vec3>(children[i], data);
			pair_list.add(pair);
		}
	}

	private void set_data_child(vec3 src, vec3 data) {
		float norm = 0;
		float dist = 0;
		float ang = 0;
		vec2 proj = this.ortho(src.xy());
		norm = this.normal(proj);
		dist = proj.dist(src.xy());
		ang = angle_impl(src.xy(), proj, true);
		data.set(norm, dist, ang);
	}



	public void update_children() {
		for(int i = 0 ; i < pair_list.size() ; i++) {
			R_Pair<vec3,vec3> pair = pair_list.get(i);
			float norm = get_child_normal(i);
			float dist = get_child_dist(i);
			vec2 src = get_child_point(i).xy();
			vec2 proj = this.ortho(src);
			float ang = angle_impl(src, proj, true);
			println("angle", ang);
			pair.b().set(norm, dist, ang);

		}
	}

	private float angle_impl(vec2 point, vec2 proj, boolean classic) {
		if(classic) {
			float ang_proj_point = proj.angle(point);
			float ang_a_b = this.a().angle(this.b());
			return (ang_proj_point - ang_a_b) + ang_a_b;
		}
		float ang_point_proj = point.angle(proj);
		float ang_b_a = this.b().angle(this.a());
		return (ang_point_proj - ang_b_a) + ang_b_a;
	}


	public ArrayList<R_Pair> get_children() {
		return pair_list;
	}

	public Float get_child_normal(int index) {
		if(index >= 0 && index < pair_list.size()) {
			R_Pair<vec3,vec3> pair = this.get_child(index);
			return pair.b().x();
		}
		return Float.NaN;
	}

	public Float get_child_dist(int index) {
		if(index >= 0 && index < pair_list.size()) {
			R_Pair<vec3,vec3> pair = this.get_child(index);
			return pair.b().y();
		}
		return Float.NaN;
	}

	public Float get_child_angle(int index) {
		if(index >= 0 && index < pair_list.size()) {
			R_Pair<vec3,vec3> pair = this.get_child(index);
			return pair.b().z();
		}
		return Float.NaN;
	}

	public vec3 get_child_point(int index) {
		if(index >= 0 && index < pair_list.size()) {
			R_Pair<vec3,vec3> pair = this.get_child(index);
			return pair.a();
		}
		return null;
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