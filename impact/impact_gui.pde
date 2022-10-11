boolean show_error_is = false;
boolean use_pixels_is = false;

int count_impact = 0;
int count_impact_err = 0;

void impact_keypressed() {
	if(key == 'n') {
		int choice = floor(random(4));
		count_impact++;
		boolean use_heart_is = false;
		// choice = 1;
		switch(choice) {
			case 0: set_impact_pentagon(); break;
			case 1: set_impact_classic(); break;
			case 2: set_impact(); break;
			// case 3: set_spiral(); break;
			default: set_impact_classic(); break;
		}
		impact_build();
		// print_setting();
	}


	if(key == 'm') {
		if(imp.use_mute_is()) {
			imp.use_mute(false);
		} else {
			imp.use_mute(true);
		}
		impact_build_polygon();
	}

	if(key == 'e') {
		show_error_is = !show_error_is;
	}

	if(key == 'z') {
		count_impact_err++;
	}

	if(key == 'p') {
		use_pixels_is =!use_pixels_is;
	}

	if(key == CODED) {
		if(keyCode == UP) {
			inc_display();
		}

		if(keyCode == DOWN) {
			dec_display();
		}
	}
	println("ERRORS",  count_impact_err, "/", count_impact);
}


int which_display = 0;
void inc_display() {
	int max = 6;
	which_display++;
	if(which_display > max) {
		which_display = 0;
	}
	println("display", which_display);
}

void dec_display() {
	int max = 6;
	which_display--;
	if(which_display < 0) {
		which_display = max;
	}
	println("display", which_display);
}

int which_display() {
	return which_display;
}