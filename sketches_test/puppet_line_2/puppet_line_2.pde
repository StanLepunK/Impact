import rope.mesh.R_Line2D;
import rope.vector.vec2;
import rope.vector.vec3;
import rope.core.Rope;

Rope r = new Rope();
R_Puppet2D puppet;


void setup() {
	size(500,500);
	puppet = new R_Puppet2D(this);
	// new_distribution();
	puppet.set(width/2, height - (height/3), width/2,height/3);
	vec3 child = new vec3().rand(new vec3(), new vec3(width, height,0));
	puppet.add(child);
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
	for(R_Pair<vec3,vec3> pair : puppet.get_children()) {
	// for(vec3 v : puppet.get_children()) {
		// r.line(v,puppet);
		fill(r.WHITE);
		circle(pair.a().x(),pair.a().y(), 50);
		// circle(v.x(),v.y(), 50);
	}


	if(puppet.a().compare(mouse, radius *2) && mousePressed) {
		puppet.a(mouse);
	}

	if(puppet.b().compare(mouse, radius *2) && mousePressed) {
		puppet.b(mouse);
	}

	puppet.update();
	puppet.update_children();

	// display
	fill(r.BLACK);
	fill(r.BLOOD);
	R_Pair<vec3,vec3> pair = puppet.get_child(0);
	vec3 data = pair.b();
	// vec3 data = puppet.get_child(0).b();
	vec2 v = puppet.point(data.x());

	circle(v.x(),v.y(),10);

	float vpx = cos(data.z())* data.y();
	float vpy = sin(data.z())* data.y();
	vec2 vp = new vec2(vpx,vpy);
	vp.add(v);
	fill(r.BLACK);
	circle(vp.x(),vp.y(),20);
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


