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
	fill(r.BLACK);
	textSize(24);
	textAlign(CENTER, CENTER);
	text("A",puppet.a().x(), puppet.a().y() - 12);
	fill(r.CYAN);	
	circle(puppet.b().x(), puppet.b().y(), radius *2);
	fill(r.BLACK);
	textSize(24);
	textAlign(CENTER, CENTER);
	text("B",puppet.b().x(), puppet.b().y() - 12);
	for(vec3 v : puppet.get_children()) {
		// r.line(v,puppet);
		fill(r.WHITE);
		circle(v.x(),v.y(), 50);
	}


	if(puppet.a().compare(mouse, radius *2)) {
		puppet.a(mouse);
	}

	if(puppet.b().compare(mouse, radius *2)) {
		puppet.b(mouse);
	}

	puppet.update();

	// display
	fill(r.BLACK);
	circle(puppet.test.x(),puppet.test.y(), 20);
	// for(vec3 p : list) {
	// 	circle(p.x(),p.y(), 20);
	// }
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
		if(!a.equals(ref_a)) {
			update_list_a();
			ref_a(a.xy());
			// start_a(a.xy());
		} 
		else {
			// ref_a(a.xy());
			// start_a(a.xy());
		}
		if(!b.equals(ref_b)) {
			update_list_b();
			ref_b(b.xy());
		} 
		// else {
		// 	start_b(b.xy());
		// }
		
		
	}

	private void update_list_a() {
		vec2 buf_start_a = start_a.xy().sub(start_b.xy());
		vec2 buf_a = a.xy().sub(b.xy());
		vec2 buf_ref_a = ref_a.xy().sub(ref_b.xy());
		float ang_buf_a = buf_a.angle();
		float ang_ref_buf_a = buf_ref_a.angle();
		float dif_ang = ang_ref_buf_a - ang_buf_a;

		for(int i = 0 ; i < list.size() ; i++) {
			vec3 p = list.get(i);
			vec3 ref_p = ref_list.get(i);
			vec2 buf_p = ref_p.xy().sub(b.xy());
			float ang_buf_p = buf_p.angle();
			float new_ang = ang_buf_p + dif_ang + ang_buf_a + TAU - buf_start_a.angle();
			float dist = dist(ref_p,b);
			vec2 new_pos = new vec2(projection(new_ang, dist));
			new_pos = add(new_pos, b.xy());
			p.set(new_pos.xyz());
		}
	}

	private void update_list_b() {
		vec2 buf_start_b = start_b.xy().sub(start_a.xy());
		vec2 buf_b = b.xy().sub(a.xy());
		vec2 buf_ref_b = ref_b.xy().sub(ref_a.xy());
		float ang_buf_b = buf_b.angle();
		float ang_ref_buf_b = buf_ref_b.angle();
		float dif_ang = ang_ref_buf_b - ang_buf_b;

		for(int i = 0 ; i < list.size() ; i++) {
			vec3 p = list.get(i);
			vec3 ref_p = ref_list.get(i);
			vec2 buf_p = ref_p.xy().sub(a.xy());
			float ang_buf_p = buf_p.angle();
			float new_ang = ang_buf_p + dif_ang + ang_buf_b + TAU - buf_start_b.angle();;
			float dist = dist(ref_p,a);
			vec2 new_pos = new vec2(projection(new_ang, dist));
			new_pos = add(new_pos, a.xy());
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
			list.add(children[i]);
			ref_list.add(children[i].copy());
		}
	}

	public ArrayList<vec3> get_children() {
		return list;
	}

	public void clear() {
		list.clear();
		ref_list.clear();
	}

	public vec2 ortho(vec2 p) {
		vec2 proj = b.xy().ortho(a.xy(), p);
		return new vec2(proj.x(), proj.y());
	}
}