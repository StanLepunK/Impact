

R_Impact imp;

void setup() {
	size(500,500);
	imp = new R_Impact(this);
	int num_branch = 12;
	int num_circle = 12;
	int num_iter = 12;
	imp.mode_line(num_branch,num_circle,num_iter);

	num_circle = 1;
	num_iter = 80;
	// imp.mode_spiral(num_branch,num_circle,num_iter);
	imp.build(width/2, height/2);

}


void draw() {
	background(0);
	noFill();
	stroke(255);
	strokeWeight(1);
	imp.show();
}

void keyPressed() {
	imp.build(width/2, height/2);
}