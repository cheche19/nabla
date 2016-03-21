///////////////////////////////////////////////////////////////////////////////
// NABLA - a Numerical Analysis Based LAnguage                               //
//                                                                           //
// Copyright (C) 2014~2016 CEA/DAM/DIF                                       //
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
#include "nabla.h"


// ****************************************************************************
// * CALLS
// ****************************************************************************
const static callHeader xHeader={
  xCallHeaderForwards,
  xCallHeaderDefines,
  xCallHeaderTypedef
};
const static callSimd simd={
  NULL,
  xCallGather,
  xCallScatter,
  NULL
};
const static callParallel parallel={
  NULL,
  NULL,
  xParallelLoop,
  xParallelIncludes
};
static backendCalls calls={
  &xHeader,
  &simd,
  &parallel
};


// ****************************************************************************
// * HOOKS
// ****************************************************************************
const static hookForAll forall={
  NULL,
  xHookForAllDump,
  xHookForAllItem,
  xHookForAllPostfix
};

const static hookToken token={
  NULL,
  xHookSwitchToken,
  xHookTurnTokenToVariable,
  xHookTurnTokenToOption,
  xHookSystem,
  xHookIteration,
  xHookExit,
  xHookTime,
  xHookFatal,
  xHookTurnBracketsToParentheses,
  xHookIsTest,
  NULL
};

const static hookGrammar gram={
  NULL,
  NULL,
  xHookReduction,
  NULL,
  NULL,
  xHookDfsVariable
};

const static hookCall call={
  xHookAddCallNames,
  xHookAddArguments,
  xHookEntryPointPrefix,
  xHookDfsForCalls,
  NULL,
  NULL
};

const static hookXyz xyz={
  NULL,
  xHookPrevCell,
  xHookNextCell,
  xHookSysPostfix
};

const static hookHeader header={
  xHookHeaderDump,
  xHookHeaderOpen,
  xHookHeaderDefineEnumerates,
  xHookHeaderPrefix,
  xHookHeaderIncludes,
  xHookHeaderPostfix
};

const static hookSource source={
  xHookSourceOpen,
  xHookSourceInclude,
  xHookSourceNamespace
};

const static hookMesh mesh={
  xHookMeshPrefix,
  xHookMeshCore,
  xHookMeshPostfix
};

const static hookVars vars={
  xHookVariablesInit,
  xHookVariablesPrefix,
  xHookVariablesMalloc,
  xHookVariablesFree
};  

const static hookMain mains={
  xHookMainPrefix,
  xHookMainPreInit,
  xHookMainVarInitKernel,
  xHookMainVarInitCall,
  xHookMainHLT,
  xHookMainPostInit,
  xHookMainPostfix
};  

const static hooks kokkosHooks={
  &forall,
  &token,
  &gram,
  &call,
  &xyz,
  NULL,
  &header,
  &source,
  &mesh,
  &vars,
  &mains
};


// ****************************************************************************
// * kokkos
// ****************************************************************************
const hooks* kokkos(nablaMain *nabla){
  nabla->call=&calls;
  return &kokkosHooks;
}
