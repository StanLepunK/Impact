

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
	float alpha_bg = map(abs(sin(frameCount * 0.002)),0,1, 0,20);
	bg(r.BLACK, alpha_bg);
	// println("frameRate", (int)frameRate, "alpha bg",alpha_bg);
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
