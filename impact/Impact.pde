

R_Impact imp;
import rope.core.Rope;

Rope r = new Rope();

void setup() {
	size(800,800,P2D);
	imp = new R_Impact(this);
	impact_setup(imp);
	vectorize_build(imp);

}


void draw() {
	// float alpha_bg = map(abs(sin(frameCount * 0.002)),0,1, 0,20);
	// bg(r.BLACK, alpha_bg);
	background(r.BLACK);
	// println("frameRate", (int)frameRate, "alpha bg",alpha_bg);
	switch(which_struc()) {
		case 0 : vectorize_show(); impact_draw(); break;
		case 1 : vectorize_show(); break;
		case 2 : vectorize_show(); impact_draw(); show_impact_cloud(); break;
		case 3 : vectorize_show(); show_impact_cloud(); break;
		case 4 : impact_draw(); show_impact_cloud(); break;
		default : vectorize_show(); impact_draw(); show_impact_cloud(); break;
	}



}

void keyPressed() {
	impact_keypressed();
	vectorize_build(imp);
}

// SHOW
////////////////
void bg(int colour, float alpha) {
	noStroke();
	fill(colour, alpha);
	rect(0,0,width, height);
}
