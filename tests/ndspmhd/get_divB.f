///////////////////////////////////////////////////////////////////////////////
// NABLA - a Numerical Analysis Based LAnguage                               //
//                                                                           //
// Copyright (C) 2014~2017 CEA/DAM/DIF                                       //
// IDDN.FR.001.520002.000.S.P.2014.000.10500                                 //
//                                                                           //
// Contributor(s): CAMIER Jean-Sylvain - Jean-Sylvain.Camier@cea.fr          //
//                                                                           //
// This software is a computer program whose purpose is to translate         //
// numerical-analysis specific sources and to generate optimized code        //
// for different targets and architectures.                                  //
//                                                                           //
// This software is governed by the CeCILL license under French law and      //
// abiding by the rules of distribution of free software. You can  use,      //
// modify and/or redistribute the software under the terms of the CeCILL     //
// license as circulated by CEA, CNRS and INRIA at the following URL:        //
// "http://www.cecill.info".                                                 //
//                                                                           //
// The CeCILL is a free software license, explicitly compatible with         //
// the GNU GPL.                                                              //
//                                                                           //
// As a counterpart to the access to the source code and rights to copy,     //
// modify and redistribute granted by the license, users are provided only   //
// with a limited warranty and the software's author, the holder of the      //
// economic rights, and the successive licensors have only limited liability.//
//                                                                           //
// In this respect, the user's attention is drawn to the risks associated    //
// with loading, using, modifying and/or developing or reproducing the       //
// software by the user in light of its specific status of free software,    //
// that may mean that it is complicated to manipulate, and that also         //
// therefore means that it is reserved for developers and experienced        //
// professionals having in-depth computer knowledge. Users are therefore     //
// encouraged to load and test the software's suitability as regards their   //
// requirements in conditions enabling the security of their systems and/or  //
// data to be ensured and, more generally, to use and operate it in the      //
// same conditions as regards security.                                      //
//                                                                           //
// The fact that you are presently reading this means that you have had      //
// knowledge of the CeCILL license and that you accept its terms.            //
//                                                                           //
// See the LICENSE file for details.                                         //
///////////////////////////////////////////////////////////////////////////////
// This NABLA port is an implementation of the NDSPMHD software
// Computes an SPH estimate of div B
// This version computes div B on all particles
// and therefore only does each pairwise interaction once
/*
∀ particles void initialiseQuantities(void){
  divBonrho=0.0;
}

void cellComputeDivB(Cell i, Cell j){
  foreach i particle{
    Real hi = hh[i];
    Real hi1 = 1.0/hi;
    Real hi2 = hi*hi;
    Real hfacwabi = hi1**ndim;
    Real rho21i = 1./rho[i]**2;
    // for each particle in the current cell, loop over its neighbours
    foreach j particle{
      if (j==i) continue;
      Real3 dx = x[i] - x[j];
      Real hj = hh[j];
      Real hj1 = 1./hj;
      Real hj2 = hj*hj;
      // calculate averages of smoothing length if using this averaging
      Real hav = 0.5*(hi + hj);
      Real hav1 = 1./hav;
      Real h2 = hav*hav;
      Real hfacwab = hav1**ndim;
      Real hfacwabj = hj1**ndim;
      Real rho21j = 1./rho(j)**2;
      Real rij2 = DOT_PRODUCT(dx,dx);
      Real rij = SQRT(rij2);
      Real q2 = rij2/h2;
      Real q2i = rij2/hi2;
      Real q2j = rij2/hj2     ;
      dr.x = dx.x/rij; // unit vector
      if (ndimV > ndim) dr.z=0.0;//(ndim+1:ndimV) = 0.
      // do interaction if r/h < compact support size
      // don't calculate interactions between ghost particles
      if ((q2i < radkern2)||(q2j<radkern2)){
        // interpolate from kernel table          
        // (use either average h or average kernel gradient)
        if (ikernav==1){
          interpolate_kernel(q2,wab,grkern);
          wab = wab*hfacwab;
          grkern = grkern*hfacwab*hj1;
        }else{
          // (using hi)
          interpolate_kernel(q2i,wabi,grkerni);
          wabi = wabi*hfacwabi;
          grkerni = grkerni*hfacwabi*hi1;
          // (using hj)
          interpolate_kernel(q2j,wabj,grkernj);
          wabj = wabj*hfacwabj;
          grkernj = grkernj*hfacwabj*hj1;
          // (calculate average)            
          wab = 0.5*(wabi + wabj);
          grkern = 0.5*(grkerni + grkernj);
        }
        if (ikernav!=3){
          grkerni = grkern;
          grkernj = grkern;
        }
        // calculate div B
        projdB = DOT_PRODUCT(Bfield[i]-Bfield[j],dr);
        divBonrho[i] = divBonrho[i] - pmass[j]*projdB*grkerni;
        divBonrho[j] = divBonrho[j] - pmass[i]*projdB*grkernj;        
      }
    }
  }
}
*/

∀ cells void get_divB(Real3* divBonrho, const Integer ntot){
  foreach cell{
    cellComputeDivB(*this,*cc);
  }
}


∀ particles void finishDivBonrho(void){
  if (ikernav == 3)
    divBonrho = gradh*divBonrho/rho**2;
  else
    divBonrho = divBonrho/rho**2;
}
