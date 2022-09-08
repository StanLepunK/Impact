

R_Impact imp;

void setup() {
	size(500,500);
	imp = new R_Impact(this);



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
	float choice = random(1);
	set_impact();
	if(choice < 0.5) {
		set_spiral();
	}
	
	imp.build(width/2, height/2);
	set_mute();
}

void set_spiral() {
	int num_branch = 12;
	int iter_branch = 12;
	int num_circle = 1;
	int iter_circle = 300;
	imp.growth_factor_spiral(random(0.5,4));
	imp.mode_spiral(num_branch, iter_branch, num_circle, iter_circle);
	
}

void set_mute() {
	int [] list_size = imp.get_size_main();
	for(int i = 0 ; i < imp.get_num_branch() ; i++) {
		for(int k = 0 ; k < list_size[i] ; k++) {
			float choice = random(1);
			if(choice < 0.5) {
				imp.set_mute_main(i, k, true);
			}
		}
	}
}

void set_impact() {
	int num_branch = 12;
	int iter_branch = 12;
	int num_circle = 12;
	int iter_circle = 12;

	imp.mode_line(num_branch, iter_branch, num_circle, iter_circle);
}