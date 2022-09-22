import rope.mesh.R_Line2D;
import rope.pixo.R_Pix;
import rope.vector.ivec6;

public class R_Line2DX extends R_Line2D {
	private ivec6 id = new ivec6(-1);
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
	// ID
	//////////////////////

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

	public int id_a() {
		return this.id.a();
	}

	public int id_b() {
		return this.id.b();
	}

	public int id_c() {
		return this.id.c();
	}

	public int id_d() {
		return this.id.d();
	}

	public int id_e() {
		return this.id.e();
	}

	public int id_f() {
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