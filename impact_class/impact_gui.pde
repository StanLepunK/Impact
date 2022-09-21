boolean show_error_is = true;
boolean use_pixels_is = false;
boolean show_struc_is = true;

void impact_keypressed() {
	if(key == 'n') {
		int choice = floor(random(4));
		// choice = 1;
		switch(choice) {
			case 0: set_impact_pentagon(); break;
			case 1: set_impact_classic(); break;
			case 2: set_impact(); break;
			case 3: set_spiral(); break;
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

	if(key == 's') {
		show_struc_is = !show_struc_is;
	}

}