

R_Impact imp;
import rope.core.Rope;

Rope r = new Rope();

void setup() {
	size(500,500);
	imp = new R_Impact(this);
	// print_setting();
	imp.build(width/2, height/2);

}


void draw() {
	// println(frameCount);
	background(0);
	noFill();
	stroke(255);
	strokeWeight(1);
	// imp.show();
	imp.show_main();
	stroke(r.CYAN);
	imp.show_circle();
	stroke(r.GREEN);
	imp.show_heart();
	stroke(r.RED);
	imp.show_fail();
}

void keyPressed() {
	if(key == 'n') {
		int choice = floor(random(3));
		choice = 0;
		switch(choice) {
			case 0: set_impact_classic(); break;
			case 1: set_impact(); break;
			case 2: set_spiral(); break;
			default: set_impact_classic(); break;
		}	
		imp.build(width/2, height/2);
		print_setting();
	}

	if(key == 'h') {
		set_mute_circle();
		println("NEW MUTE SETTING");
	}

	if(key == 'm') {
		if(imp.use_mute_is()) {
			imp.use_mute(false);
		} else {
			imp.use_mute(true);
		}
	}
}

// SET MUTE
/////////////////

void set_mute_main() {
	int [] list_size = imp.get_size_main();
	for(int i = 0 ; i < imp.get_num_main() ; i++) {
		for(int k = 0 ; k < list_size[i] ; k++) {
			float choice = random(1);
			imp.set_mute_main(i, k, false);
			if(choice < 0.5) {
				imp.set_mute_main(i, k, true);
			}
		}
	}
}

void set_mute_circle() {
	int [] list_size = imp.get_size_circle();
	for(int i = 0 ; i < imp.get_num_circle() ; i++) {
		for(int k = 0 ; k < list_size[i] ; k++) {
			float choice = random(1);
			imp.set_mute_circle(i, k, false);
			if(choice < 0.5) {
				imp.set_mute_circle(i, k, true);
			}
		}
	}
}



// SET BUILD
//////////////////

void set_impact_classic() {
	// main
	int num_main = 12;
	int iter_main = 18;
	float growth_main = random(width/20,width/2);
	float angle_main = random(PI/120,PI/24);
	// circle
	int num_circle = 12;
	int iter_circle = num_main;
	float heart = random(1);
	// heart = 0;
	float growth_circle = random(width/20,width/2);
	imp.normal();
	imp.set_num_main(num_main).set_iter_main(iter_main).set_growth_main(growth_main).set_angle_main(angle_main).set_heart_main(heart);
	imp.set_num_circle(num_circle).set_iter_circle(iter_circle).set_growth_circle(growth_circle);
}

void set_impact() {
	// main
	int num_main = int(random(5,27));
	int iter_main = int(random(5,27));
	float growth_main = random(width/20,width/2);
	float angle_main = random(PI/120,PI/24);
	// circle
	int num_circle = int(random(5,27));
	int iter_circle = int(random(5,num_main));
	float growth_circle = random(width/20,width/2);
	imp.normal();
	imp.set_num_main(num_main).set_iter_main(iter_main).set_growth_main(growth_main).set_angle_main(angle_main);
	imp.set_num_circle(num_circle).set_iter_circle(iter_circle).set_growth_circle(growth_circle);
}


void set_spiral() {
	// main 
	int num_main = int(random(5,27));
	int iter_main = int(random(5,27));
	float growth_main = random(width/20,width/2);
	float angle_main = random(PI/120,PI/24);
	// circle
	int num_circle = 1;
	// int iter_circle = num_main * 10;
	int iter_circle = int(random(100,1200));
	float growth_circle = random(width/20,width/2);
	float factor_spiral_growth = random(0.1,6.0);
	// factor_spiral_growth = 12.0;
	imp.growth_factor_spiral(factor_spiral_growth);

	imp.spiral();
	imp.set_num_main(num_main).set_iter_main(iter_main).set_growth_main(growth_main).set_angle_main(angle_main);
	imp.set_num_circle(num_circle).set_iter_circle(iter_circle).set_growth_circle(growth_circle);
}




// PRINT
///////////////////////
void print_setting() {
	println("====================================");
	if(imp.get_mode() == r.SPIRAL) {
		println("SPIRAL SETTING");
	} else {
		println("NORMAL SETTING");
	}
	println("----------------------------------");
	println("main num main", imp.get_num_main());
	println("main iteration", imp.get_iter_main());
	println("main growth", imp.get_growth_main());
	println("main angle", imp.get_angle_main());
	println("----------------------------------");
	println("circle num", imp.get_num_circle());
	println("circle iteration", imp.get_iter_circle());
	println("circle growth", imp.get_growth_circle());
	if(imp.get_mode() == r.SPIRAL) {
		println("----------------------------------");
		println("spiral growth", imp.get_growth_spiral());
	}
	// println("----------------------------------");
	// println("main iteration by branch");
	// println(imp.get_size_main());
	println("----------------------------------");
	println("circle iteration by ring");
	println(imp.get_size_circle());
}