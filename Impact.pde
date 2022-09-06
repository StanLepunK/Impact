import rope.vector.vec2;
import rope.vector.vec3;
import rope.core.Rope;
import rope.costume.R_Line2D;


Rope r = new Rope();

ArrayList<R_Line2D>[] main_branch;
ArrayList<R_Line2D>[] circle_branch;
int base = 12;
int num_branch = base;
int num_circle = base;
int num_iter = base; // work with r.SPIRAL mode when the num of iter is upper to the num of branches
// int circle_mode = r.SPIRAL; // r.SPIRAL / r.NOTCH / r.NORMAL
// int circle_mode = r.NOTCH; // r.SPIRAL / r.NOTCH / r.NORMAL
int circle_mode = r.NORMAL; // r.SPIRAL / r.NOTCH / r.NORMAL
int power = 250;
float res = 50;

void setup() {
  size(600,600,P2D);
  background(r.BLACK);
  build();
}

void draw() {
  background(r.BLACK);
  show_branch(main_branch, -1);
  show_branch(circle_branch, -1);
}

void keyPressed() {
  if(key == 'n') {
    build();

  }
}

void build() {
  build_main_branch(width/2,height/2, num_branch, power, res);
  build_circle_branches(width/2,height/2, num_circle, num_branch, num_iter, power, circle_mode);
}


void build_main_branch(int x, int y, int num, float power, float resistance) {
  main_branch = new ArrayList[num];
  float step = TAU / num;
  float dir = 0;

  for(int i = 0 ; i < num ; i++) {
    main_branch[i] = new ArrayList<R_Line2D>();
    main_branch_impl(i, x, y, dir += step, power, resistance, num);
  }
}

void build_circle_branches(int x, int y, int num_circle, int num_branch, int num_iter, float power, int mode) {
  circle_branch = new ArrayList[num_circle];
  float dist = 0;
  float dist_step = power / num_branch; // bizarre
  dist_step *= 1.2;


  for(int i = 0 ; i < num_circle ; i++) {
    circle_branch[i] = new ArrayList<R_Line2D>();
    dist += dist_step;
    circle_branch_impl(circle_branch[i], new vec2(x,y), num_iter, num_branch, dist, mode);
  }
}

void circle_branch_impl(ArrayList<R_Line2D> web_string, vec2 offset, int num_iter, int num_branch, float dist, int mode) {
  float start_angle = 0;
  float step_angle = TAU / num_branch;
  vec2 ang_set = new vec2(start_angle, step_angle);
  float fact_growth = 0.4;
  vec2 buf_meet = new vec2(-1);
  // vec2 buf_meet = null;
  int count = 0;
  boolean jump_is = false;
  float buf_dist = dist;


  println("new while level ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::");
  while(count < num_iter) {
    println("count", count);
    R_Line2D line = draw_string_web(ang_set, offset, buf_dist, fact_growth, mode);

    vec2 [] tupple = meet_point(line, true);
    boolean good_tupple_is = false;
    if(tupple[0] != null && tupple[1] != null) {
      good_tupple_is = true;
    } else {
      // buf_meet = null;
    }
    println("-------------- BEFORE >>>>>", buf_meet);
    jump_is = adjust_string_web(web_string, line, buf_meet, tupple, good_tupple_is, jump_is);
    println("-------------- AFTER >>>>>>", buf_meet);
    // end part
    count++;
    if(mode == r.SPIRAL) {
      buf_dist = r.dist(line.b(),offset);
    }
    if(mode != r.NOTCH && count%num_branch == 0 && count <= web_string.size()) {
      int which_one = count - num_branch;
      close_string_web(web_string, which_one);
    }
  }

  // if(count == num_branch && count <= web_string.size()) {
  //   int which_one = count - num_branch;
  //   println("CLOSE LOOP which_one",which_one);
  //   close_string_web(web_string, which_one);
  // }
}




R_Line2D draw_string_web(vec2 ang_set, vec2 offset, float dist, float fact_growth, int mode) {
  float final_angle = ang_set.x();
  float ax = sin(final_angle) * dist + offset.x();
  float ay = cos(final_angle) * dist + offset.y();
  ang_set.x(ang_set.x() + ang_set.y());
  final_angle = ang_set.x();
  if(mode == r.NOTCH || mode == r.SPIRAL) {
    dist += (fact_growth*8);
  }
  float bx = sin(final_angle) * dist + offset.x();
  float by = cos(final_angle) * dist + offset.y();
  R_Line2D line = new R_Line2D(this, ax, ay, bx, by);
  line.change(fact_growth, fact_growth);
  line.set(line.a(),line.b());
  return line;
}

boolean adjust_string_web(ArrayList<R_Line2D> web_string, R_Line2D line, vec2 buf_meet, vec2 [] tupple, boolean good_tupple_is, boolean jump_is) {
  println("START adjust_string_web()", buf_meet);
  boolean init = true;
  if(!good_tupple_is) {
    println("BAD", tupple[0],tupple[1],"buf_meet",buf_meet,"------------------------------------ AU SECOURS");
    init = false;
    jump_is = true;
  } else {
    if(buf_meet.equals(-1)) {  
      line.set(tupple[0],tupple[1]);
      web_string.add(line);
      if(jump_is) {
        println("JUMP");
        buf_meet.set(tupple[1].x(),tupple[1].y());
      } else {
        println("ADJUST");
        buf_meet.set(tupple[0].x(), tupple[0].y());
      }
      jump_is = false;
    } else {
      println("SET");
      line.set(buf_meet,tupple[1]);
      web_string.add(line);
      buf_meet.set(tupple[1]);
    }
  }
  println("END adjust_string_web()", buf_meet);
  return jump_is;
}





void close_string_web(ArrayList<R_Line2D> web_string, int whitch_one) {
  vec2 last = web_string.get(whitch_one).b();
  int max = web_string.size() -1;
  R_Line2D line = new R_Line2D(this,web_string.get(max).a(), last);
  web_string.remove(max);
  web_string.add(line);
}

vec2 [] meet_point(R_Line2D line, boolean two_points_is) {
  vec2 [] meet = new vec2[2];
  for(int i = 0; i < main_branch.length ; i++) {
    for(R_Line2D buff_line : main_branch[i]) {
      if(meet[0] == null) {
        meet[0] = buff_line.intersection(line);
        if(two_points_is && meet[0] != null) {
          break;
        }
      }
      if(meet[0] != null && meet[1] == null) {
        meet[1] = buff_line.intersection(line);
      }
      if(meet[0] != null && meet[1] != null) {
        return meet;
      }
    }
  }
  return meet;
}



void main_branch_impl(int index, float px, float py, float dir, float power, float resistance, int num) {
  float ref_power = power;
  float range_jit = TAU / num * 0.1;
  float ax = px;
  float ay = py;
  float bx = 0;
  float by = 0;
  while(power > 0) {
    // distance
    float jit_distance = random(-resistance, resistance);
    power -= (resistance + jit_distance);
    float dist = ref_power - power;
    // direction
    float jit_direction = random(-range_jit, range_jit);
    float x = sin(dir + jit_direction) * dist;
    float y = cos(dir + jit_direction) * dist;
    bx = x + px;
    by = y + py;
    R_Line2D line = new R_Line2D(this, ax, ay, bx, by);
    main_branch[index].add(line);
    ax = bx;
    ay = by;
  }
}

void show_branch(ArrayList<R_Line2D>[] list, int what) {
  noFill();
  stroke(r.WHITE);
  strokeWeight(1);
  if(what == -1) {
    for(int i = 0 ; i < list.length ; i++) {
      // for(int k = 0 ; k < list[i].size() ; k++) {
      //   R_Line2D line = list[i].get(k);
      //   line.show();
      // }
      for(R_Line2D line : list[i]) {
        line.show();
      }
    }
  } else if(what > -1 && what < list.length) {
    for(int i = 0 ; i < list.length ; i++) {
      list[i].get(what).show();
      // for(int k = 0 ; k < list[i].size() ; k++) {
      //   list[i].get(k).show();
      // }
    }
  }
}



// void add_line(ArrayList<R_Line2D>[] list, int index, float ax, float ay, float bx, float by) {
  // R_Line2D line = new R_Line2D(this, ax, ay, bx, by);
  // list[index].add(line);
// }



