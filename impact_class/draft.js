SPIRAL SETTING
----------------------------------
main num main 12
main iteration 12
main growth 142.68588
main angle 0.09735931
----------------------------------
circle num 1
circle iteration 1200
circle growth 26.683247
----------------------------------
spiral growth 1.9024434
----------------------------------
dist 0.8894416 dist_step 2.223604


====================================
SPIRAL SETTING
----------------------------------
main num main 12
main iteration 12
main growth 244.66516
main angle 0.07071696
----------------------------------
circle num 1
circle iteration 1200
circle growth 39.88567
----------------------------------
spiral growth 2.836582
----------------------------------
dist 1.3295224 dist_step 3.3238058



====================================
SPIRAL SETTING
----------------------------------
main num main 12
main iteration 12
main growth 149.62724
main angle 0.11646653
----------------------------------
circle num 1
circle iteration 1200
circle growth 32.105762
----------------------------------
spiral growth 4.0
----------------------------------
dist 1.0701921 dist_step 2.6754801


====================================
SPIRAL SETTING
----------------------------------
main num main 12
main iteration 12
main growth 152.25002
main angle 0.107688576
----------------------------------
circle num 1
circle iteration 1200
circle growth 31.81717
----------------------------------
spiral growth 4.0
----------------------------------
dist 1.0605724 dist_step 2.6514308



====================================
SPIRAL SETTING
----------------------------------
main num main 12
main iteration 12
main growth 86.76631
main angle 0.08810373
----------------------------------
circle num 1
circle iteration 1200
circle growth 31.531313
----------------------------------
spiral growth 6.0
----------------------------------
dist 1.0510439 dist_step 2.6276095




private void circle_spiral_impl(ArrayList<R_Line2D> web_string, vec2 offset, float dist) {
		float start_angle = 0;

		float step_angle = TAU / get_num_main();
		vec2 ang_set = new vec2(start_angle, step_angle);
		vec2 buf_meet = new vec2(-1);
		int count = 0;
		boolean jump_is = false;
		float buf_dist = dist;

	  while(count < get_iter_circle()) {
			R_Line2D line = draw_string_web(ang_set, offset, buf_dist);
			// here we catch the meeting point with the main branches
			vec2 [] tupple = meet_point(line, true);
			boolean good_tupple_is = false;
			if(tupple[0] != null && tupple[1] != null) {
				good_tupple_is = true;
				// the moment where the turn is done and it's time to go to next level
				if((count+1)%get_num_main() == 0) {
					vec2 swap = tupple[0];
					tupple[0] = tupple[1];
					tupple[1] = swap;
				}
			}
			jump_is = adjust_string_web(web_string, line, buf_meet, tupple, good_tupple_is, jump_is);

			count++;
			buf_dist = dist(line.b(),offset);
	  }
	}

	private void circle_line_impl(ArrayList<R_Line2D> web_string, vec2 offset, float dist) {
		float start_angle = 0;

		float step_angle = TAU / get_num_main();
		vec2 ang_set = new vec2(start_angle, step_angle);
		vec2 buf_meet = new vec2(-1);
		int count = 0;
		boolean jump_is = false;
		float buf_dist = dist;

	  while(count < get_iter_circle()) {
			R_Line2D line = draw_string_web(ang_set, offset, buf_dist);
			// here we catch the meeting point with the main branches
			vec2 [] tupple = meet_point(line, true);
			boolean good_tupple_is = false;
			if(tupple[0] != null && tupple[1] != null) {
				good_tupple_is = true;
			}
			jump_is = adjust_string_web(web_string, line, buf_meet, tupple, good_tupple_is, jump_is);
			count++;
			if(count%get_num_main() == 0 && count <= web_string.size()) {
				int which_one = count - get_num_main();
				close_string_web(web_string, which_one);
			}
	  }
	}