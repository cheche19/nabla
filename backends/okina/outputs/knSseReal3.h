#ifndef _KN_SSE_REAL3_H_
#define _KN_SSE_REAL3_H_


// ****************************************************************************
// * real3
// ****************************************************************************
struct __attribute__ ((aligned(16))) real3 {
 public:
  // Les formules 4*(3*WARP_BASE(a)+0)+WARP_OFFSET(a) fonctionnent grâce au fait
  // que real3 est bien une struct avec les x,y et z en positions [0],[1] et [2]
  real x;
  real y;
  real z;
 public:
  // Constructors
  inline real3(): x(_mm_setzero_pd()), y(_mm_setzero_pd()), z(_mm_setzero_pd()){}
  inline real3(double d): x(_mm_set1_pd(d)), y(_mm_set1_pd(d)), z(_mm_set1_pd(d)){}
  inline real3(double _x,double _y,double _z): x(_mm_set1_pd(_x)), y(_mm_set1_pd(_y)), z(_mm_set1_pd(_z)){}
  inline real3(real f):x(f), y(f), z(f){}
  inline real3(real _x, real _y, real _z):x(_x), y(_y), z(_z){}
  inline real3(double *_x, double *_y, double *_z): x(_mm_load_pd(_x)), y(_mm_load_pd(_y)), z(_mm_load_pd(_z)){}

  // Logicals
  friend inline real3 operator&(const real3 &a, const real3 &b) { return real3(_mm_and_pd(a.x,b.x), _mm_and_pd(a.y,b.y), _mm_and_pd(a.z,b.z)); }
  friend inline real3 operator|(const real3 &a, const real3 &b) { return real3( _mm_or_pd(a.x,b.x),  _mm_or_pd(a.y,b.y),  _mm_or_pd(a.z,b.z)); }
  friend inline real3 operator^(const real3 &a, const real3 &b) { return real3(_mm_xor_pd(a.x,b.x), _mm_xor_pd(a.y,b.y), _mm_xor_pd(a.z,b.z)); }

  // Arithmetic operators
  friend inline real3 operator+(const real3 &a, const real3& b) { return real3(_mm_add_pd(a.x,b.x), _mm_add_pd(a.y,b.y), _mm_add_pd(a.z,b.z));}
  friend inline real3 operator-(const real3 &a, const real3& b) { return real3(_mm_sub_pd(a.x,b.x), _mm_sub_pd(a.y,b.y), _mm_sub_pd(a.z,b.z));}
  friend inline real3 operator*(const real3 &a, const real3& b) { return real3(_mm_mul_pd(a.x,b.x), _mm_mul_pd(a.y,b.y), _mm_mul_pd(a.z,b.z));}
  friend inline real3 operator/(const real3 &a, const real3& b) { return real3(_mm_div_pd(a.x,b.x), _mm_div_pd(a.y,b.y), _mm_div_pd(a.z,b.z));}

  // op= operators
  inline real3& operator+=(const real3& b) { return *this=real3(_mm_add_pd(x,b.x),_mm_add_pd(y,b.y),_mm_add_pd(z,b.z));}
  inline real3& operator-=(const real3& b) { return *this=real3(_mm_sub_pd(x,b.x),_mm_sub_pd(y,b.y),_mm_sub_pd(z,b.z));}
  inline real3& operator*=(const real3& b) { return *this=real3(_mm_mul_pd(x,b.x),_mm_mul_pd(y,b.y),_mm_mul_pd(z,b.z));}
  inline real3& operator/=(const real3& b) { return *this=real3(_mm_div_pd(x,b.x),_mm_div_pd(y,b.y),_mm_div_pd(z,b.z));}

  //inline real3 operator-(){return real3(-x, -y, -z);}
  inline real3 operator-()const {return real3(-x, -y, -z);}

  // op= operators with real
  inline real3& operator+=(real f){return *this=real3(x+f,y+f,z+f);}
  inline real3& operator-=(real f){return *this=real3(x-f,y-f,z-f);}
  inline real3& operator*=(real f){return *this=real3(x*f,y*f,z*f);}
  inline real3& operator/=(real f){return *this=real3(x/f,y/f,z/f);}

  inline real3& operator+=(double f){return *this=real3(x+f,y+f,z+f);}
  inline real3& operator-=(double f){return *this=real3(x-f,y-f,z-f);}
  inline real3& operator*=(double f){return *this=real3(x*f,y*f,z*f);}
  inline real3& operator/=(double f){return *this=real3(x/f,y/f,z/f);}
  
  friend inline real dot3(real3 u, real3 v){ return real(u.x*v.x+u.y*v.y+u.z*v.z);}
  friend inline real norm(real3 u){ return real(rsqrt(dot3(u,u)));}
  friend inline real3 cross(real3 u, real3 v){
    return
      real3(_mm_sub_pd( _mm_mul_pd(u.y,v.z) , _mm_mul_pd(u.z,v.y) ),
            _mm_sub_pd( _mm_mul_pd(u.z,v.x) , _mm_mul_pd(u.x,v.z) ),
            _mm_sub_pd( _mm_mul_pd(u.x,v.y) , _mm_mul_pd(u.y,v.x) ));
  }
  
  /* inline real3& operator[](Integer i)const{
    return real3(real(x[i[0]],x[i[1]]),
                 real(y[i[0]],y[i[1]]),
                 real(z[i[0]],z[i[1]]));
                 }*/

};


#endif //  _KN_SSE_REAL3_H_
