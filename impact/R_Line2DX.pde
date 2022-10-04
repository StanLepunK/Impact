import rope.mesh.R_Line2D;
import rope.pixo.R_Pix;
import rope.vector.ivec6;

public class R_Line2DX extends R_Line2D {
	private ivec6 id = new ivec6(Integer.MIN_VALUE);
	public R_Line2DX(PApplet pa) {
		super(pa);
	}

	public R_Line2DX(PApplet pa, vec2 a, vec2 b) {
		super(pa,a,b);
	}

	public R_Line2DX(PApplet pa, float ax, float ay, float bx, float by) {
		super(pa, ax, ay,  bx, by);
	}

	/////////////////////
	// SET ID
	//////////////////////
	
	public R_Line2DX id(int a, int b, int c, int d, int e, int f) {
		this.id.set(a,b,c,d,e,f);
		return this;
	}

	public R_Line2DX id_a(int id) {
		this.id.a(id);
		return this;
	}

	public R_Line2DX id_b(int id) {
		this.id.b(id);
		return this;
	}

	public R_Line2DX id_c(int id) {
		this.id.c(id);
		return this;
	}

	public R_Line2DX id_d(int id) {
		this.id.d(id);
		return this;
	}

	public R_Line2DX id_e(int id) {
		this.id.e(id);
		return this;
	}

	public R_Line2DX id_f(int id) {
		this.id.f(id);
		return this;
	}

	///////////////////////
	// GET ID
	///////////////////////

	public ivec6 id() {
		return this.id;
	}

	public Integer id_a() {
		return this.id.a();
	}

	public Integer id_b() {
		return this.id.b();
	}

	public Integer id_c() {
		return this.id.c();
	}

	public Integer id_d() {
		return this.id.d();
	}

	public Integer id_e() {
		return this.id.e();
	}

	public Integer id_f() {
		return this.id.f();
	}


	public R_Line2DX copy() {
    R_Line2DX line = new R_Line2DX(this.pa,this.a,this.b);
    line.mute(this.mute_is());
    if(pixies != null && pixies.length > 0) {
      line.pixies = new R_Pix[pixies.length];
      for(int i = 0 ; i < pixies.length ; i++) {
        line.pixies[i] = pixies[i];
      }
    }
    return line;
  }
}