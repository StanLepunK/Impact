boolean show_error_is = false;
boolean use_pixels_is = false;


void impact_keypressed() {
	if(key == 'n') {
		int choice = floor(random(4));
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
	}

	if(key == 'e') {
		show_error_is = !show_error_is;
	}

	if(key == 'p') {
		use_pixels_is =!use_pixels_is;
	}

	if(key == 'w') { // indesign or photoshop
		inc_struc();
	}
}


int which_struc = 0;
void inc_struc() {
	which_struc++;
	if(which_struc > 3) {
		which_struc = 0;
	}
}

int which_struc() {
	return which_struc;
}