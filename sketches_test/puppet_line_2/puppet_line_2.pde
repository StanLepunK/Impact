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
	ArrayList<vec3> data_list = new ArrayList<vec3>();
	R_Puppet2D buffer;
	// ArrayList<Float> angle = new ArrayList<Float>();
	// ArrayList<Float> dist = new ArrayList<Float>();
	R_Puppet2D (PApplet pa) {
		super(pa);
		
	}
	float offset_ang = 0;
	vec2 test = new vec2();
	void update() {

		// a move
		if(!a.equals(ref_a)) {
			// print_err("AAAA");
			vec2 buf_a = a.xy().sub(b.xy());
			vec2 buf_ref_a = ref_a.xy().sub(ref_b.xy());
			float ang_a = buf_a.angle();
			float ang_ref_a = buf_ref_a.angle();
			float dif_ang = ang_ref_a - ang_a;

			for(vec3 p : list) {
				vec2 buf_p = p.xy().sub(b.xy());
				// vec2 buf_p = p.xy();
				float ang_p = buf_p.angle();
				// float new_ang = ang_p + dif_ang;
				// float new_ang = ang_p + dif_ang + (ang_a *2);
				if(mousePressed) {
					offset_ang = map(sin(frameCount * 0.01), -1, 1, 0, TAU);
				}
				float new_ang = ang_p + dif_ang + ang_a + offset_ang;
				// float new_ang = ang_p + dif_ang - ang_a; // same as + ang_a
				// float new_ang = dif_ang + ang_a;
				//float new_ang = dif_ang + ang_a - ang_p;
				float dist = dist(p,b);
				// println("distance", dist, p, b);
				println("angle a", ang_a);
				println("offset angle", offset_ang);
				println("dif angle", dif_ang);
				println("angle point", ang_p);
				println("new angle", new_ang);
				// println("new angle", new_ang);
				vec2 new_pos = new vec2(projection(new_ang, dist));
				// println("new pos", new_pos);
				// println("p", p.xy());
				// println("b", b.xy());
				new_pos = add(new_pos, b.xy());
				// println("new pos", new_pos);
				test.set(new_pos);
				// p.x(new_pos.x());
				// p.y(new_pos.y());

			}
		}


		// b move
		if(!b.equals(ref_b)) {
			print_err("BBBB");
		}

	}




	public void ref_a(vec2 ref_a) {
    this.ref_a(ref_a.x(),ref_a.y());
  }
  
  public void ref_a(float x, float y) {
    this.ref_a.set(x,y,0);
  }

	public void ref_b(vec2 ref_b) {
    this.ref_b(ref_b.x(),ref_b.y());
  }
  
  public void ref_b(float x, float y) {
    this.ref_b.set(x,y,0);
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
			vec2 proj = buffer.ortho(children[i].xy());
			float dist = proj.dist(children[i]);
			float marge = 1.0f;
			float norm = buffer.normal(proj, marge);
			// float norm = this.normal(proj, marge, false);
			println("norm", norm);
			float ang = point(norm).angle(children[i].xy());
			vec3 data = new vec3(dist, norm, ang);
			data_list.add(data);
		}
	}



	ArrayList<vec3> get_children() {
		return list;
	}

	void clear() {
		list.clear();
		data_list.clear();
		// normal.clear();
		// angle.clear();
		// dist.clear();
	}

	public vec2 ortho(vec2 p) {
		vec2 proj = b.xy().ortho(a.xy(), p);
		return new vec2(proj.x(), proj.y());
	}


		// void update() {
	// 	for(vec3 data : data_list) {
	// 		float dist = data.x();
	// 		float normal = data.y();
	// 		float angle = data.z();

	// 		float ax = cos(angle) * dist;
	// 		float ay = sin(angle) * dist;
	// 		vec2 res = point(normal);
	// 		// println("normal", normal);
	// 		// vec2 res = new vec2(ax, ay).add(point(normal));
	// 		circle(res.x(),res.y(), 10);
	// 	}
	// }

	// void update() {
	// 	for(vec3 v : list) {
	// 		// vec2 proj = this.ortho(v.xy());
	// 		// float dist = proj.dist(v);
	// 		println("dist", dist);
	// 		float norm = this.normal(proj, 1);
	// 		float angle = a.xy().angle(proj);
	// 		float ax = cos(angle) * dist;
	// 		float ay = sin(angle) * dist;
	// 		vec2 reflect = new vec2(ax,ay).add(a.xy());
	// 		v.set(reflect);
	// 		// circle(reflect.x(),reflect.y(), 10);
	// 		circle(v.x(),v.y(), 10);


	// 		// vec2 reflect = 
	// 		// circle(proj.x(),proj.y(), 10);
	// 	}
	// }





}