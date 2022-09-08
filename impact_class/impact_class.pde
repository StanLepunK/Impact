

R_Impact imp;

void setup() {
	size(500,500);
	imp = new R_Impact(this);
	print_setting();
	imp.build(width/2, height/2);

}


void draw() {
	// println(frameCount);
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
	// set_mute();
}



void set_mute() {
	int [] list_size = imp.get_size_main();
	for(int i = 0 ; i < imp.get_num_main() ; i++) {
		for(int k = 0 ; k < list_size[i] ; k++) {
			float choice = random(1);
			if(choice < 0.5) {
				imp.set_mute_main(i, k, true);
			}
		}
	}
}

void set_spiral() {
	// main and circle
	float growth = random(width/20,width/2);
	// main 
	int num_main = 12;
	int iter_main = 12;
	float angle_main = random(PI/120,PI/24);
	// circle
	int num_circle = 1;
	int iter_circle = 300;
	imp.growth_factor_spiral(random(0.5,4));
	imp.spiral();
	imp.set_num_main(num_main).set_iter_main(iter_main).set_growth_main(growth).set_angle_main(angle_main);
	imp.set_num_circle(num_circle).set_iter_circle(iter_circle).set_growth_circle(growth);
	print_setting();
}




void set_impact() {
	// main and circle
	float growth = growth = random(width/20,width/2);
	// main
	int num_main = 12;
	int iter_main = 12;
	float angle_main = random(PI/120,PI/24);
	// circle
	int num_circle = 12;
	int iter_circle = 12;
	imp.normal();
	imp.set_num_main(num_main).set_iter_main(iter_main).set_growth_main(growth).set_angle_main(angle_main);
	imp.set_num_circle(num_circle).set_iter_circle(iter_circle).set_growth_circle(growth);
	print_setting();
}


void print_setting() {
	println("SETTING");
	println("main num main", imp.get_num_main());
	println("main iteration", imp.get_iter_main());
	println("main growth", imp.get_growth_main());
	println("main angle", imp.get_angle_main());
	println("circle num", imp.get_num_circle());
	println("circle iteration", imp.get_iter_circle());
	println("circle growth", imp.get_growth_circle());

}