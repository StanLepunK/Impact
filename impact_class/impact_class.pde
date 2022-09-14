

R_Impact imp;
import rope.core.Rope;


Rope r = new Rope();

void setup() {
	size(800,800,P2D);
	imp = new R_Impact(this);
	impact_setup(imp);
	add_cloud_points(imp);
}


void draw() {
	println("frameRate", (int)frameRate);
	// background(0);
	bg(r.BLACK, 10.0f);
	impact_draw();
	show_impact_cloud();

}

void keyPressed() {
	impact_keypressed();
	add_cloud_points(imp);
}

// SHOW
////////////////
void bg(int colour, float alpha) {
	noStroke();
	fill(colour, alpha);
	rect(0,0,width, height);
}
