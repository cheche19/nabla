#ifndef _KN_AVX2_GATHER_H_
#define _KN_AVX2_GATHER_H_

std::ostream& operator<<(std::ostream &os, const __m256d v);

// *****************************************************************************
// * Gather: (X is the data @ offset x)       a            b       c   d
// * data:   |....|....|....|....|....|....|..A.|....|....|B...|...C|..D.|....|      
// * gather: |ABCD|
// *****************************************************************************
inline void gatherk(const int a, const int b,
                    const int c, const int d,
                    const real *data,
                    real *gather){
  const __m128i index= _mm_set_epi32(d,c,b,a);
  *gather = _mm256_i32gather_pd((double*)data, index, _MM_SCALE_8);
}

inline __m256d returned_gatherk(const int a, const int b,
                                const int c, const int d,
                                const double *data){
  const __m128i index= _mm_set_epi32(d,c,b,a);
  return _mm256_i32gather_pd(data, index, _MM_SCALE_8);
}


inline __m256d gatherk_and_zero_neg_ones(const int a, const int b,
                                         const int c, const int d,
                                         real *data){
  const double *p=(double*)data;
  const __m256d zero256=_mm256_setzero_pd();
  //const __m128d bData=_mm_movedup_pd(_mm_load_sd(&p[(b<0)?0:b])); 
  //const __m256d ba=_mm256_castpd128_pd256(_mm_loadl_pd(bData,&p[(a<0)?0:a]));
  //const __m128d dData=_mm_movedup_pd(_mm_load_sd(&p[(d<0)?0:d]));
  //const __m128d dc=_mm_loadl_pd(dData,&p[(c<0)?0:c]);
  //const __m256d dcba_old=_mm256_insertf128_pd(ba,dc,0x01);

  const __m256d dcba=returned_gatherk((a<0)?0:a,(b<0)?0:b,(c<0)?0:c,(d<0)?0:d,p);
  //info()<<"["<<a<<","<<b<<","<<c<<","<<d<<"]: "<<dcba_old<<" vs "<< dcba;
  const __m256d dcbat=opTernary(_mm256_cmp_pd(_mm256_set_pd(d,c,b,a),
                                              zero256,
                                              _CMP_GE_OQ),
                                dcba,
                                zero256);
  return dcbat;
}

inline void gatherFromNode_k(const int a, const int b,
                             const int c, const int d,
                             real *data, real *gthr){
  *gthr=gatherk_and_zero_neg_ones(a,b,c,d,data);
}

// ******************************************************************************
// * Gather avec des real3
// ******************************************************************************
inline void gather3ki(const int a, const int b,
                      const int c, const int d,
                      real3 *data, real3 *gthr,
                      int i){
  double *p=(double *)data;
  __m256d aData=_mm256_broadcast_sd(&(p[4*(3*WARP_BASE(a)+i)+WARP_OFFSET(a)]));
  __m256d bData=_mm256_broadcast_sd(&(p[4*(3*WARP_BASE(b)+i)+WARP_OFFSET(b)]));
  __m256d cData=_mm256_broadcast_sd(&(p[4*(3*WARP_BASE(c)+i)+WARP_OFFSET(c)]));
  __m256d dData=_mm256_broadcast_sd(&(p[4*(3*WARP_BASE(d)+i)+WARP_OFFSET(d)]));
  __m256d ba=_mm256_blend_pd(aData,bData,0xA);
  __m256d dc=_mm256_blend_pd(cData,dData,0xA);
  __m256d dcba=_mm256_blend_pd(ba,dc,0xC);
  if (i==0) (*gthr).x=dcba;
  if (i==1) (*gthr).y=dcba;
  if (i==2) (*gthr).z=dcba;
}

inline void gather3k(const int a, const int b,
                     const int c, const int d,
                     real3 *data, real3 *gthr){
  gather3ki(a,b,c,d,data,gthr,0);
  gather3ki(a,b,c,d,data,gthr,1);
  gather3ki(a,b,c,d,data,gthr,2);
}


// ******************************************************************************
// *
// ******************************************************************************
inline void gatherFromNode_3kiArray8(const int a, const int a_corner,
                                     const int b, const int b_corner,
                                     const int c, const int c_corner,
                                     const int d, const int d_corner,
                                     real3 *data, real3 *gthr, int i){
  const __m256d zero256=_mm256_set1_pd(0.0);
  double *p=(double *)data;
  __m256d aData=a<0?zero256:_mm256_broadcast_sd(&(p[4*(3*8*WARP_BASE(a)+3*a_corner+i)+WARP_OFFSET(a)]));
  __m256d bData=b<0?zero256:_mm256_broadcast_sd(&(p[4*(3*8*WARP_BASE(b)+3*b_corner+i)+WARP_OFFSET(b)]));
  __m256d cData=c<0?zero256:_mm256_broadcast_sd(&(p[4*(3*8*WARP_BASE(c)+3*c_corner+i)+WARP_OFFSET(c)]));
  __m256d dData=d<0?zero256:_mm256_broadcast_sd(&(p[4*(3*8*WARP_BASE(d)+3*d_corner+i)+WARP_OFFSET(d)]));
  __m256d ba=_mm256_blend_pd(aData,bData,0xA);
  __m256d dc=_mm256_blend_pd(cData,dData,0xA);
  __m256d dcba=_mm256_blend_pd(ba,dc,0xC);
  if (i==0) (*gthr).x=dcba;
  if (i==1) (*gthr).y=dcba;
  if (i==2) (*gthr).z=dcba;
}

inline void gatherFromNode_3kArray8(const int a, const int a_corner,
                                    const int b, const int b_corner,
                                    const int c, const int c_corner,
                                    const int d, const int d_corner,
                                    real3 *data, real3 *gthr){
  gatherFromNode_3kiArray8(a,a_corner,b,b_corner,c,c_corner,d,d_corner,data,gthr,0);
  gatherFromNode_3kiArray8(a,a_corner,b,b_corner,c,c_corner,d,d_corner,data,gthr,1);
  gatherFromNode_3kiArray8(a,a_corner,b,b_corner,c,c_corner,d,d_corner,data,gthr,2);
}

#endif //  _KN_AVX2_GATHER_H_