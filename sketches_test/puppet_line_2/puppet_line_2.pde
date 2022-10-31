import rope.mesh.R_Line2D;
import rope.vector.vec2;
import rope.vector.vec3;
import rope.core.Rope;

Rope r = new Rope();
R_Puppet2D puppet;


void setup() {
	size(500,500);
	puppet = new R_Puppet2D(this);
	new_distribution();
}

void draw() {
	background(r.MAGENTA);
	vec2 mouse = new vec2(mouseX,mouseY);
	float radius = 10;
	puppet.show();
	fill(r.YELLOW);
	circle(puppet.a().x(), puppet.a().y(), radius *2);
	fill(r.CYAN);
	circle(puppet.b().x(), puppet.b().y(), radius *2);

	for(vec3 v : puppet.get_children()) {
		// r.line(v,puppet);
		fill(r.WHITE);
		circle(v.x(),v.y(), 50);
	}


	if(puppet.a().compare(mouse, radius *2)) {
		// puppet.set_a(mouse);
		puppet.a(mouse);
		puppet.update();
		// make something here to find the angle between the two positions
		puppet.ref_a(mouse);
	}

	if(puppet.b().compare(mouse, radius *2)) {
		// puppet.set_b(mouse);
		puppet.b(mouse);
		puppet.update();
		// make something here to find the angle between the two positions
		puppet.ref_b(mouse);
	}

	// display
		fill(r.BLACK);
		circle(puppet.test.x(),puppet.test.y(), 20);
		// for(vec3 p : list) {
		// 	circle(p.x(),p.y(), 20);
		// }

	

	// puppet.update();
}

void keyPressed() {
	if(key == 'n' || key == 'N') {
		new_distribution();
	}
}

void new_distribution() {
	puppet.set(new vec2().rand(0,width), new vec2().rand(0,width));
	puppet.clear();
	vec3 child = new vec3().rand(new vec3(), new vec3(width, height,0));
	puppet.add(child);
}


class R_Puppet2D extends R_Line2D {
	ArrayList<vec3> list = new ArrayList<vec3>();
	R_Puppet2D buffer;

	vec2 start_a;
	vec2 start_b;
	R_Puppet2D (PApplet pa) {
		super(pa);
		this.start_a = new vec2();
    this.start_b = new vec2();
		
	}

	vec2 test = new vec2();
	void update() {
		// a move
		if(!a.equals(ref_a)) {
			// start_b.set(ref_b.xy());
			vec2 buf_start_a = start_a.xy().sub(start_b.xy());
			vec2 buf_a = a.xy().sub(b.xy());
			vec2 buf_ref_a = ref_a.xy().sub(ref_b.xy());
			float ang_buf_a = buf_a.angle();
			float ang_ref_buf_a = buf_ref_a.angle();
			float dif_ang = ang_ref_buf_a - ang_buf_a;

			for(vec3 p : list) {
				vec2 buf_p = p.xy().sub(b.xy());
				float ang_buf_p = buf_p.angle();
				float new_ang = ang_buf_p + dif_ang + ang_buf_a + TAU - buf_start_a.angle();;
				float dist = dist(p,b);
				vec2 new_pos = new vec2(projection(new_ang, dist));
				new_pos = add(new_pos, b.xy());
				test.set(new_pos);
				// p.x(new_pos.x());
				// p.y(new_pos.y());

			}
		}

		// b move
		if(!b.equals(ref_b)) {
			// start_a.set(ref_a.xy());
			vec2 buf_start_b = start_b.xy().sub(start_a.xy());
			vec2 buf_b = b.xy().sub(a.xy());
			vec2 buf_ref_b = ref_b.xy().sub(ref_a.xy());
			float ang_buf_b = buf_b.angle();
			float ang_ref_buf_b = buf_ref_b.angle();
			float dif_ang = ang_ref_buf_b - ang_buf_b;

			for(vec3 p : list) {
				vec2 buf_p = p.xy().sub(a.xy());
				float ang_buf_p = buf_p.angle();
				float new_ang = ang_buf_p + dif_ang + ang_buf_b + TAU - buf_start_b.angle();;
				float dist = dist(p,a);
				vec2 new_pos = new vec2(projection(new_ang, dist));
				new_pos = add(new_pos, a.xy());
				test.set(new_pos);
				// p.x(new_pos.x());
				// p.y(new_pos.y());

			}
		}

	}


  public void set_a(float x, float y) {
    this.a(x,y);
    this.ref_a(x,y);
    this.start_a(x,y);;
  }

	public void ref_a(vec2 ref_a) {
    this.ref_a(ref_a.x(),ref_a.y());
  }
  
  public void ref_a(float x, float y) {
    this.ref_a.set(x,y,0);
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

	public void ref_b(vec2 ref_b) {
    this.ref_b(ref_b.x(),ref_b.y());
  }
  
  public void ref_b(float x, float y) {
    this.ref_b.set(x,y,0);
  }

	public void start_b(vec2 start_b) {
    this.start_b(start_b.x(),start_b.y());
  }
  
  public void start_b(float x, float y) {
    this.start_b.set(x,y);
  }

	void add(vec3... children) {
		if(buffer == null) {
			buffer = new R_Puppet2D(this.pa);
			buffer.set(this.a(), this.b());
			buffer.change(100,100);
			buffer.set(buffer.a(), buffer.b());
		}

		for(int i = 0 ; i < children.length ; i++) {
			list.add(children[i]);
		}
	}

	ArrayList<vec3> get_children() {
		return list;
	}

	void clear() {
		list.clear();
	}

	public vec2 ortho(vec2 p) {
		vec2 proj = b.xy().ortho(a.xy(), p);
		return new vec2(proj.x(), proj.y());
	}
}