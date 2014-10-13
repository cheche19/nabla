#include "luleshEntity.h"


/*********************************************************
 * Forward enumerates
 *********************************************************/
#define CUDA_INI_CELL_THREAD(tid) \
  const register int tid = blockDim.x*blockIdx.x + threadIdx.x;\
  if ( tid>=NABLA_NB_CELLS) return;

#define CUDA_INI_CELL_THREAD_RETURN_REAL(tid) \
  const register int tid = blockDim.x*blockIdx.x + threadIdx.x;\
  if ( tid>=NABLA_NB_CELLS) return -1.0;

#define CUDA_INI_NODE_THREAD(tid)\
  const register int tid = blockDim.x*blockIdx.x + threadIdx.x;\
  if ( tid>=NABLA_NB_NODES) return;

#define FOR_EACH_CELL_NODE(n) for(int n=0;n<8;n+=1)

#define FOR_EACH_CELL_WARP(c) 

#define FOR_EACH_NODE_WARP(n) 

#warning CUDA_INI_FUNCTION_THREAD is tied to CUDA_INI_CELL_THREAD
#define CUDA_INI_FUNCTION_THREAD(tid) CUDA_INI_CELL_THREAD(tid)\
//  const register int # tid = blockDim.x*blockIdx.x + threadIdx.x;\
//  if (tid!=0) return;


/******************************************************************************
 * Kernel d'initialisation du maillage �-la-SOD
 ******************************************************************************/
__global__ void nabla_ini_node_coords(int *node_cell,
                                      Real *node_coordx, Real *node_coordy, Real *node_coordz){
	CUDA_INI_NODE_THREAD(tnid);
	node_cell[tnid+0*NABLA_NB_NODES]=0;
	node_cell[tnid+1*NABLA_NB_NODES]=0;
	node_cell[tnid+2*NABLA_NB_NODES]=0;
	node_cell[tnid+3*NABLA_NB_NODES]=0;
	node_cell[tnid+4*NABLA_NB_NODES]=0;
	node_cell[tnid+5*NABLA_NB_NODES]=0;
	node_cell[tnid+6*NABLA_NB_NODES]=0;
	node_cell[tnid+7*NABLA_NB_NODES]=0;
	int dx,dy,dz,iNode=tnid;
	dx=iNode/(NABLA_NB_NODES_Y_AXIS*NABLA_NB_NODES_Z_AXIS);
	dz=(iNode/NABLA_NB_NODES_Y_AXIS)%(NABLA_NB_NODES_Z_AXIS);
	dy=iNode%NABLA_NB_NODES_Y_AXIS;
	node_coordx[tnid]=((double)dx)*NABLA_NB_NODES_X_TICK;
	node_coordy[tnid]=((double)dy)*NABLA_NB_NODES_Y_TICK;
	node_coordz[tnid]=((double)dz)*NABLA_NB_NODES_Z_TICK;

}

__global__ void nabla_ini_cell_connectivity(int *cell_node){
  CUDA_INI_CELL_THREAD(tcid);
  int dx,dy,dz,bid,iCell=tcid;
  dx=iCell/(NABLA_NB_CELLS_Y_AXIS*NABLA_NB_CELLS_Z_AXIS);
  dz=(iCell/NABLA_NB_CELLS_Y_AXIS)%(NABLA_NB_CELLS_Z_AXIS);
  dy=iCell%NABLA_NB_CELLS_Y_AXIS;
  bid=dy+dz*NABLA_NB_NODES_Y_AXIS+dx*NABLA_NB_NODES_Y_AXIS*NABLA_NB_NODES_Z_AXIS;
  cell_node[tcid+0*NABLA_NB_CELLS]=bid;
  cell_node[tcid+1*NABLA_NB_CELLS]=bid+1;
  cell_node[tcid+2*NABLA_NB_CELLS]=bid+NABLA_NB_NODES_Y_AXIS+1;
  cell_node[tcid+3*NABLA_NB_CELLS]=bid+NABLA_NB_NODES_Y_AXIS+0;
  cell_node[tcid+4*NABLA_NB_CELLS]=bid+NABLA_NB_NODES_Y_AXIS*NABLA_NB_NODES_Z_AXIS;
  cell_node[tcid+5*NABLA_NB_CELLS]=bid+NABLA_NB_NODES_Y_AXIS*NABLA_NB_NODES_Z_AXIS+1;
  cell_node[tcid+6*NABLA_NB_CELLS]=bid+NABLA_NB_NODES_Y_AXIS*NABLA_NB_NODES_Z_AXIS+NABLA_NB_NODES_Y_AXIS+1;
  cell_node[tcid+7*NABLA_NB_CELLS]=bid+NABLA_NB_NODES_Y_AXIS*NABLA_NB_NODES_Z_AXIS+NABLA_NB_NODES_Y_AXIS+0;
}


// ********************************************************
// * ini fct
// ********************************************************
__global__ void ini(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro){

	/*cudaHookPrefixEnumerate*//*itm= */	CUDA_INI_FUNCTION_THREAD(tid);
	// function cudaHookDumpEnumerate
	// functioncudaHookPostfixEnumerate
/*StdJob*//*GlobalVar*/*global_deltat=0.0;
	/*StdJob*//*GlobalVar*/*global_dtt_hydro=/*tt2o cuda*/option_dtt_hydro;
	/*StdJob*//*GlobalVar*/*global_dtt_courant=/*tt2o cuda*/option_dtt_courant;
	if ( /*tt2o cuda*/option_eosvmax==0.) fatal("ini","option_eosvmax==0.");
	if ( /*tt2o cuda*/option_eosvmin==0.) fatal("ini","option_eosvmin==0.");
	}



// ********************************************************
// * iniCellBC job
// ********************************************************
__global__ void iniCellBC(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		integer *cell_elemBC){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		const Real zero /*'='->!isLeft*/= 0.0  ;
		const Real maxBoundaryX /*'='->!isLeft*/=opMul ( X_EDGE_TICK , X_EDGE_ELEMS ) ;
		const Real maxBoundaryY /*'='->!isLeft*/=opMul ( Y_EDGE_TICK , Y_EDGE_ELEMS ) ;
		const Real maxBoundaryZ /*'='->!isLeft*/=opMul ( Z_EDGE_TICK , Z_EDGE_ELEMS ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_elemBC/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=0 ;
		/*chsf n*/for(int n=0;n<8;++n){
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_elemBC/*nvar no diffraction possible here*//*CellVar*/[tcid]|=opTernary ( ( /*CellJob*//*tt2a*/node_coordx/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/==  0.0  ) , 0x001 , 0 ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_elemBC/*nvar no diffraction possible here*//*CellVar*/[tcid]|=opTernary ( ( /*CellJob*//*tt2a*/node_coordy/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/== zero ) , 0x010 , 0 ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_elemBC/*nvar no diffraction possible here*//*CellVar*/[tcid]|=opTernary ( ( /*CellJob*//*tt2a*/node_coordz/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/== zero ) , 0x100 , 0 ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_elemBC/*nvar no diffraction possible here*//*CellVar*/[tcid]|=opTernary ( ( /*CellJob*//*tt2a*/node_coordx/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/== maxBoundaryX ) , 0x008 , 0 ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_elemBC/*nvar no diffraction possible here*//*CellVar*/[tcid]|=opTernary ( ( /*CellJob*//*tt2a*/node_coordy/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/== maxBoundaryY ) , 0x080 , 0 ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_elemBC/*nvar no diffraction possible here*//*CellVar*/[tcid]|=opTernary ( ( /*CellJob*//*tt2a*/node_coordz/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/== maxBoundaryZ ) , 0x800 , 0 ) ;
		}/*FOREACH_END*/}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * calcElemVolume job
// ********************************************************
__global__ void calcElemVolume(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_calc_volume){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		Real x_local [8 ];
		Real y_local [8 ];
		Real z_local [8 ];
		/*chsf n*/for(int n=0;n<8;++n){
		/* DiffractingREADY *//*isLeft*/x_local [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_coordx/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		/* DiffractingREADY *//*isLeft*/y_local [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_coordy/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		/* DiffractingREADY *//*isLeft*/z_local [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_coordz/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		}/*FOREACH_END*//* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_calc_volume/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=/*JOB_CALL*//*got_call*//*has not been found*/_calcElemVolume ( /*function_call_arguments*//*postfix_constant@true*/x_local [0 /*postfix_constant_value*/], /*postfix_constant@true*/x_local [1 /*postfix_constant_value*/], /*postfix_constant@true*/x_local [2 /*postfix_constant_value*/], /*postfix_constant@true*/x_local [3 /*postfix_constant_value*/], /*postfix_constant@true*/x_local [4 /*postfix_constant_value*/], /*postfix_constant@true*/x_local [5 /*postfix_constant_value*/], /*postfix_constant@true*/x_local [6 /*postfix_constant_value*/], /*postfix_constant@true*/x_local [7 /*postfix_constant_value*/], /*postfix_constant@true*/y_local [0 /*postfix_constant_value*/], /*postfix_constant@true*/y_local [1 /*postfix_constant_value*/], /*postfix_constant@true*/y_local [2 /*postfix_constant_value*/], /*postfix_constant@true*/y_local [3 /*postfix_constant_value*/], /*postfix_constant@true*/y_local [4 /*postfix_constant_value*/], /*postfix_constant@true*/y_local [5 /*postfix_constant_value*/], /*postfix_constant@true*/y_local [6 /*postfix_constant_value*/], /*postfix_constant@true*/y_local [7 /*postfix_constant_value*/], /*postfix_constant@true*/z_local [0 /*postfix_constant_value*/], /*postfix_constant@true*/z_local [1 /*postfix_constant_value*/], /*postfix_constant@true*/z_local [2 /*postfix_constant_value*/], /*postfix_constant@true*/z_local [3 /*postfix_constant_value*/], /*postfix_constant@true*/z_local [4 /*postfix_constant_value*/], /*postfix_constant@true*/z_local [5 /*postfix_constant_value*/], /*postfix_constant@true*/z_local [6 /*postfix_constant_value*/], /*postfix_constant@true*/z_local [7 /*postfix_constant_value*/]/*ARGS*//*got_args*/) ;
		/*!function_call_arguments*/}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * iniVolume job
// ********************************************************
__global__ void iniVolume(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_calc_volume,
		real *cell_volo,
		real *cell_elemMass,
		real *node_nodalMass){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_volo/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=/*isLeft*//*CellJob*//*tt2a*/cell_elemMass/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=/*CellJob*//*tt2a*/cell_calc_volume/*nvar no diffraction possible here*//*CellVar*/[tcid];
		/*chsf n*/for(int n=0;n<8;++n)/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/node_nodalMass/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/+=opDiv ( /*CellJob*//*tt2a*/cell_volo/*nvar no diffraction possible here*//*CellVar*/[tcid],  8.0  ) ;
		/*FOREACH_END*/}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * iniCellStateAndDepositEnergy job
// ********************************************************
__global__ void iniCellStateAndDepositEnergy(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_e,
		real *cell_v){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_v/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/= 1.0  ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_e/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*uniqueId c*/(tcid)== 0 ) , /*tt2o cuda*/option_initial_energy,  0.0  ) ;
		}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job

// ********************************************************
// * calcElemShapeFunctionDerivatives fct
// ********************************************************
__device__ inline void calcElemShapeFunctionDerivatives(const Real * __restrict__ x , const Real * __restrict__ y , const Real * __restrict__ z , Real * __restrict__ _Bx , Real * __restrict__ _By , Real * __restrict__ _Bz , Real * rtn ){

	/*cudaHookPrefixEnumerate*//*itm= */	/*std function*/
	// function cudaHookDumpEnumerate
	// functioncudaHookPostfixEnumerate
const Real fjxxi=opMul(0.125,(opSub(opSub(opAdd((opSub(x[6],x[0])),(opSub(x[5],x[3]))),(opSub(x[7],x[1]))),(opSub(x[4],x[2])))));
	const Real fjyxi=opMul(0.125,(opSub(opSub(opAdd((opSub(x[6],x[0])),(opSub(x[5],x[3]))),(opSub(x[7],x[1]))),(opSub(x[4],x[2])))));
	const Real fjzxi=opMul(0.125,(opSub(opSub(opAdd((opSub(x[6],x[0])),(opSub(x[5],x[3]))),(opSub(x[7],x[1]))),(opSub(x[4],x[2])))));
	const Real fjxet=opMul(0.125,(opSub(opAdd(opSub((opSub(y[6],y[0])),(opSub(y[5],y[3]))),(opSub(y[7],y[1]))),(opSub(y[4],y[2])))));
	const Real fjyet=opMul(0.125,(opSub(opAdd(opSub((opSub(y[6],y[0])),(opSub(y[5],y[3]))),(opSub(y[7],y[1]))),(opSub(y[4],y[2])))));
	const Real fjzet=opMul(0.125,(opSub(opAdd(opSub((opSub(y[6],y[0])),(opSub(y[5],y[3]))),(opSub(y[7],y[1]))),(opSub(y[4],y[2])))));
	const Real fjxze=opMul(0.125,(opAdd(opAdd(opAdd((opSub(z[6],z[0])),(opSub(z[5],z[3]))),(opSub(z[7],z[1]))),(opSub(z[4],z[2])))));
	const Real fjyze=opMul(0.125,(opAdd(opAdd(opAdd((opSub(z[6],z[0])),(opSub(z[5],z[3]))),(opSub(z[7],z[1]))),(opSub(z[4],z[2])))));
	const Real fjzze=opMul(0.125,(opAdd(opAdd(opAdd((opSub(z[6],z[0])),(opSub(z[5],z[3]))),(opSub(z[7],z[1]))),(opSub(z[4],z[2])))));
	const Real cjxxi=opSub((opMul(fjyet,fjzze)),(opMul(fjzet,fjyze)));
	const Real cjyxi=opAdd(-(opMul(fjxet,fjzze)),(opMul(fjzet,fjxze)));
	const Real cjzxi=opSub((opMul(fjxet,fjyze)),(opMul(fjyet,fjxze)));
	const Real cjxet=opAdd(-(opMul(fjyxi,fjzze)),(opMul(fjzxi,fjyze)));
	const Real cjyet=opSub((opMul(fjxxi,fjzze)),(opMul(fjzxi,fjxze)));
	const Real cjzet=opAdd(-(opMul(fjxxi,fjyze)),(opMul(fjyxi,fjxze)));
	const Real cjxze=opSub((opMul(fjyxi,fjzet)),(opMul(fjzxi,fjyet)));
	const Real cjyze=opAdd(-(opMul(fjxxi,fjzet)),(opMul(fjzxi,fjxet)));
	const Real cjzze=opSub((opMul(fjxxi,fjyet)),(opMul(fjyxi,fjxet)));
	_Bx[0]=opSub(opSub(-cjxxi,cjxet),cjxze);
	_Bx[1]=opSub(opSub(cjxxi,cjxet),cjxze);
	_Bx[2]=opSub(opAdd(cjxxi,cjxet),cjxze);
	_Bx[3]=opSub(opAdd(-cjxxi,cjxet),cjxze);
	_Bx[4]=-_Bx[2];
	_Bx[5]=-_Bx[3];
	_Bx[6]=-_Bx[0];
	_Bx[7]=-_Bx[1];
	_By[0]=opSub(opSub(-cjyxi,cjyet),cjyze);
	_By[1]=opSub(opSub(cjyxi,cjyet),cjyze);
	_By[2]=opSub(opAdd(cjyxi,cjyet),cjyze);
	_By[3]=opSub(opAdd(-cjyxi,cjyet),cjyze);
	_By[4]=-_By[2];
	_By[5]=-_By[3];
	_By[6]=-_By[0];
	_By[7]=-_By[1];
	_Bz[0]=opSub(opSub(-cjzxi,cjzet),cjzze);
	_Bz[1]=opSub(opSub(cjzxi,cjzet),cjzze);
	_Bz[2]=opSub(opAdd(cjzxi,cjzet),cjzze);
	_Bz[3]=opSub(opAdd(-cjzxi,cjzet),cjzze);
	_Bz[4]=-_Bz[2];
	_Bz[5]=-_Bz[3];
	_Bz[6]=-_Bz[0];
	_Bz[7]=-_Bz[1];
	*rtn=opMul(8.0,(opAdd(opAdd(opMul(fjxet,cjxet),opMul(fjyet,cjyet)),opMul(fjzet,cjzet))));
	}


// ********************************************************
// * CalcElemVelocityGradient fct
// ********************************************************
__device__ inline void CalcElemVelocityGradient(const Real * const xvel , const Real * const yvel , const Real * const zvel , const Real b [ ] [ 8 ] , const Real detJ , Real * const d ){

	/*cudaHookPrefixEnumerate*//*itm= */	/*std function*/
	// function cudaHookDumpEnumerate
	// functioncudaHookPostfixEnumerate
const Real inv_detJ=opDiv(Real (1.0),detJ);
	Real dyddx,dxddy,dzddx,dxddz,dzddy,dyddz;
	const Real *const pfx=b[0];
	const Real *const pfy=b[1];
	const Real *const pfz=b[2];
	d[0]=opMul(inv_detJ,(opAdd(opAdd(opAdd(opMul(pfx[0],(opSub(xvel[0],xvel[6]))),opMul(pfx[1],(opSub(xvel[1],xvel[7])))),opMul(pfx[2],(opSub(xvel[2],xvel[4])))),opMul(pfx[3],(opSub(xvel[3],xvel[5]))))));
	d[1]=opMul(inv_detJ,(opAdd(opAdd(opAdd(opMul(pfy[0],(opSub(yvel[0],yvel[6]))),opMul(pfy[1],(opSub(yvel[1],yvel[7])))),opMul(pfy[2],(opSub(yvel[2],yvel[4])))),opMul(pfy[3],(opSub(yvel[3],yvel[5]))))));
	d[2]=opMul(inv_detJ,(opAdd(opAdd(opAdd(opMul(pfz[0],(opSub(zvel[0],zvel[6]))),opMul(pfz[1],(opSub(zvel[1],zvel[7])))),opMul(pfz[2],(opSub(zvel[2],zvel[4])))),opMul(pfz[3],(opSub(zvel[3],zvel[5]))))));
	dyddx=opMul(inv_detJ,(opAdd(opAdd(opAdd(opMul(pfx[0],(opSub(yvel[0],yvel[6]))),opMul(pfx[1],(opSub(yvel[1],yvel[7])))),opMul(pfx[2],(opSub(yvel[2],yvel[4])))),opMul(pfx[3],(opSub(yvel[3],yvel[5]))))));
	dxddy=opMul(inv_detJ,(opAdd(opAdd(opAdd(opMul(pfy[0],(opSub(xvel[0],xvel[6]))),opMul(pfy[1],(opSub(xvel[1],xvel[7])))),opMul(pfy[2],(opSub(xvel[2],xvel[4])))),opMul(pfy[3],(opSub(xvel[3],xvel[5]))))));
	dzddx=opMul(inv_detJ,(opAdd(opAdd(opAdd(opMul(pfx[0],(opSub(zvel[0],zvel[6]))),opMul(pfx[1],(opSub(zvel[1],zvel[7])))),opMul(pfx[2],(opSub(zvel[2],zvel[4])))),opMul(pfx[3],(opSub(zvel[3],zvel[5]))))));
	dxddz=opMul(inv_detJ,(opAdd(opAdd(opAdd(opMul(pfz[0],(opSub(xvel[0],xvel[6]))),opMul(pfz[1],(opSub(xvel[1],xvel[7])))),opMul(pfz[2],(opSub(xvel[2],xvel[4])))),opMul(pfz[3],(opSub(xvel[3],xvel[5]))))));
	dzddy=opMul(inv_detJ,(opAdd(opAdd(opAdd(opMul(pfy[0],(opSub(zvel[0],zvel[6]))),opMul(pfy[1],(opSub(zvel[1],zvel[7])))),opMul(pfy[2],(opSub(zvel[2],zvel[4])))),opMul(pfy[3],(opSub(zvel[3],zvel[5]))))));
	dyddz=opMul(inv_detJ,(opAdd(opAdd(opAdd(opMul(pfz[0],(opSub(yvel[0],yvel[6]))),opMul(pfz[1],(opSub(yvel[1],yvel[7])))),opMul(pfz[2],(opSub(yvel[2],yvel[4])))),opMul(pfz[3],(opSub(yvel[3],yvel[5]))))));
	d[5]=opMul(.5,(opAdd(dxddy,dyddx)));
	d[4]=opMul(.5,(opAdd(dxddz,dzddx)));
	d[3]=opMul(.5,(opAdd(dzddy,dyddz)));
	}


// ********************************************************
// * sumElemFaceNormal fct
// ********************************************************
__device__ inline void sumElemFaceNormal(Real * _B0x , Real * _B0y , Real * _B0z , Real * _B1x , Real * _B1y , Real * _B1z , Real * _B2x , Real * _B2y , Real * _B2z , Real * _B3x , Real * _B3y , Real * _B3z , const int ia , const int ib , const int ic , const int id , const Real * __restrict__ _Xx , const Real * __restrict__ _Xy , const Real * __restrict__ _Xz ){

	/*cudaHookPrefixEnumerate*//*itm= */	/*std function*/
	// function cudaHookDumpEnumerate
	// functioncudaHookPostfixEnumerate
const Real bisect0x=opMul(0.5,(opSub(opSub(opAdd(_Xx[id],_Xx[ic]),_Xx[ib]),_Xx[ia])));
	const Real bisect0y=opMul(0.5,(opSub(opSub(opAdd(_Xy[id],_Xy[ic]),_Xy[ib]),_Xy[ia])));
	const Real bisect0z=opMul(0.5,(opSub(opSub(opAdd(_Xz[id],_Xz[ic]),_Xz[ib]),_Xz[ia])));
	const Real bisect1x=opMul(0.5,(opSub(opSub(opAdd(_Xx[ic],_Xx[ib]),_Xx[id]),_Xx[ia])));
	const Real bisect1y=opMul(0.5,(opSub(opSub(opAdd(_Xy[ic],_Xy[ib]),_Xy[id]),_Xy[ia])));
	const Real bisect1z=opMul(0.5,(opSub(opSub(opAdd(_Xz[ic],_Xz[ib]),_Xz[id]),_Xz[ia])));
	const Real _areax=opMul(0.25,(opSub(opMul(bisect0y,bisect1z),opMul(bisect0z,bisect1y))));
	const Real _areay=opMul(0.25,(opSub(opMul(bisect0z,bisect1x),opMul(bisect0x,bisect1z))));
	const Real _areaz=opMul(0.25,(opSub(opMul(bisect0x,bisect1y),opMul(bisect0y,bisect1x))));
	*_B0x+=_areax;
	*_B1x+=_areax;
	*_B2x+=_areax;
	*_B3x+=_areax;
	*_B0y+=_areay;
	*_B1y+=_areay;
	*_B2y+=_areay;
	*_B3y+=_areay;
	*_B0z+=_areaz;
	*_B1z+=_areaz;
	*_B2z+=_areaz;
	*_B3z+=_areaz;
	}


// ********************************************************
// * calcElemFBHourglassForce fct
// ********************************************************
__device__ inline void calcElemFBHourglassForce(const Real * xd , const Real * yd , const Real * zd , const Real * hourgam0 , const Real * hourgam1 , const Real * hourgam2 , const Real * hourgam3 , const Real * hourgam4 , const Real * hourgam5 , const Real * hourgam6 , const Real * hourgam7 , const Real coefficient , Real * __restrict__ hgfx , Real * __restrict__ hgfy , Real * __restrict__ hgfz ){

	/*cudaHookPrefixEnumerate*//*itm= */	/*std function*/
	// function cudaHookDumpEnumerate
	// functioncudaHookPostfixEnumerate
const register Real h00x=opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opMul(hourgam0[0],xd[0]),opMul(hourgam1[0],xd[1])),opMul(hourgam2[0],xd[2])),opMul(hourgam3[0],xd[3])),opMul(hourgam4[0],xd[4])),opMul(hourgam5[0],xd[5])),opMul(hourgam6[0],xd[6])),opMul(hourgam7[0],xd[7]));
	const register Real h01x=opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opMul(hourgam0[1],xd[0]),opMul(hourgam1[1],xd[1])),opMul(hourgam2[1],xd[2])),opMul(hourgam3[1],xd[3])),opMul(hourgam4[1],xd[4])),opMul(hourgam5[1],xd[5])),opMul(hourgam6[1],xd[6])),opMul(hourgam7[1],xd[7]));
	const register Real h02x=opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opMul(hourgam0[2],xd[0]),opMul(hourgam1[2],xd[1])),opMul(hourgam2[2],xd[2])),opMul(hourgam3[2],xd[3])),opMul(hourgam4[2],xd[4])),opMul(hourgam5[2],xd[5])),opMul(hourgam6[2],xd[6])),opMul(hourgam7[2],xd[7]));
	const register Real h03x=opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opMul(hourgam0[3],xd[0]),opMul(hourgam1[3],xd[1])),opMul(hourgam2[3],xd[2])),opMul(hourgam3[3],xd[3])),opMul(hourgam4[3],xd[4])),opMul(hourgam5[3],xd[5])),opMul(hourgam6[3],xd[6])),opMul(hourgam7[3],xd[7]));
	const register Real h00y=opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opMul(hourgam0[0],yd[0]),opMul(hourgam1[0],yd[1])),opMul(hourgam2[0],yd[2])),opMul(hourgam3[0],yd[3])),opMul(hourgam4[0],yd[4])),opMul(hourgam5[0],yd[5])),opMul(hourgam6[0],yd[6])),opMul(hourgam7[0],yd[7]));
	const register Real h01y=opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opMul(hourgam0[1],yd[0]),opMul(hourgam1[1],yd[1])),opMul(hourgam2[1],yd[2])),opMul(hourgam3[1],yd[3])),opMul(hourgam4[1],yd[4])),opMul(hourgam5[1],yd[5])),opMul(hourgam6[1],yd[6])),opMul(hourgam7[1],yd[7]));
	const register Real h02y=opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opMul(hourgam0[2],yd[0]),opMul(hourgam1[2],yd[1])),opMul(hourgam2[2],yd[2])),opMul(hourgam3[2],yd[3])),opMul(hourgam4[2],yd[4])),opMul(hourgam5[2],yd[5])),opMul(hourgam6[2],yd[6])),opMul(hourgam7[2],yd[7]));
	const register Real h03y=opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opMul(hourgam0[3],yd[0]),opMul(hourgam1[3],yd[1])),opMul(hourgam2[3],yd[2])),opMul(hourgam3[3],yd[3])),opMul(hourgam4[3],yd[4])),opMul(hourgam5[3],yd[5])),opMul(hourgam6[3],yd[6])),opMul(hourgam7[3],yd[7]));
	const register Real h00z=opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opMul(hourgam0[0],zd[0]),opMul(hourgam1[0],zd[1])),opMul(hourgam2[0],zd[2])),opMul(hourgam3[0],zd[3])),opMul(hourgam4[0],zd[4])),opMul(hourgam5[0],zd[5])),opMul(hourgam6[0],zd[6])),opMul(hourgam7[0],zd[7]));
	const register Real h01z=opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opMul(hourgam0[1],zd[0]),opMul(hourgam1[1],zd[1])),opMul(hourgam2[1],zd[2])),opMul(hourgam3[1],zd[3])),opMul(hourgam4[1],zd[4])),opMul(hourgam5[1],zd[5])),opMul(hourgam6[1],zd[6])),opMul(hourgam7[1],zd[7]));
	const register Real h02z=opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opMul(hourgam0[2],zd[0]),opMul(hourgam1[2],zd[1])),opMul(hourgam2[2],zd[2])),opMul(hourgam3[2],zd[3])),opMul(hourgam4[2],zd[4])),opMul(hourgam5[2],zd[5])),opMul(hourgam6[2],zd[6])),opMul(hourgam7[2],zd[7]));
	const register Real h03z=opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opMul(hourgam0[3],zd[0]),opMul(hourgam1[3],zd[1])),opMul(hourgam2[3],zd[2])),opMul(hourgam3[3],zd[3])),opMul(hourgam4[3],zd[4])),opMul(hourgam5[3],zd[5])),opMul(hourgam6[3],zd[6])),opMul(hourgam7[3],zd[7]));
	hgfx[0]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam0[0],h00x),opMul(hourgam0[1],h01x)),opMul(hourgam0[2],h02x)),opMul(hourgam0[3],h03x))));
	hgfx[1]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam1[0],h00x),opMul(hourgam1[1],h01x)),opMul(hourgam1[2],h02x)),opMul(hourgam1[3],h03x))));
	hgfx[2]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam2[0],h00x),opMul(hourgam2[1],h01x)),opMul(hourgam2[2],h02x)),opMul(hourgam2[3],h03x))));
	hgfx[3]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam3[0],h00x),opMul(hourgam3[1],h01x)),opMul(hourgam3[2],h02x)),opMul(hourgam3[3],h03x))));
	hgfx[4]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam4[0],h00x),opMul(hourgam4[1],h01x)),opMul(hourgam4[2],h02x)),opMul(hourgam4[3],h03x))));
	hgfx[5]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam5[0],h00x),opMul(hourgam5[1],h01x)),opMul(hourgam5[2],h02x)),opMul(hourgam5[3],h03x))));
	hgfx[6]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam6[0],h00x),opMul(hourgam6[1],h01x)),opMul(hourgam6[2],h02x)),opMul(hourgam6[3],h03x))));
	hgfx[7]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam7[0],h00x),opMul(hourgam7[1],h01x)),opMul(hourgam7[2],h02x)),opMul(hourgam7[3],h03x))));
	hgfy[0]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam0[0],h00y),opMul(hourgam0[1],h01y)),opMul(hourgam0[2],h02y)),opMul(hourgam0[3],h03y))));
	hgfy[1]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam1[0],h00y),opMul(hourgam1[1],h01y)),opMul(hourgam1[2],h02y)),opMul(hourgam1[3],h03y))));
	hgfy[2]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam2[0],h00y),opMul(hourgam2[1],h01y)),opMul(hourgam2[2],h02y)),opMul(hourgam2[3],h03y))));
	hgfy[3]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam3[0],h00y),opMul(hourgam3[1],h01y)),opMul(hourgam3[2],h02y)),opMul(hourgam3[3],h03y))));
	hgfy[4]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam4[0],h00y),opMul(hourgam4[1],h01y)),opMul(hourgam4[2],h02y)),opMul(hourgam4[3],h03y))));
	hgfy[5]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam5[0],h00y),opMul(hourgam5[1],h01y)),opMul(hourgam5[2],h02y)),opMul(hourgam5[3],h03y))));
	hgfy[6]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam6[0],h00y),opMul(hourgam6[1],h01y)),opMul(hourgam6[2],h02y)),opMul(hourgam6[3],h03y))));
	hgfy[7]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam7[0],h00y),opMul(hourgam7[1],h01y)),opMul(hourgam7[2],h02y)),opMul(hourgam7[3],h03y))));
	hgfz[0]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam0[0],h00z),opMul(hourgam0[1],h01z)),opMul(hourgam0[2],h02z)),opMul(hourgam0[3],h03z))));
	hgfz[1]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam1[0],h00z),opMul(hourgam1[1],h01z)),opMul(hourgam1[2],h02z)),opMul(hourgam1[3],h03z))));
	hgfz[2]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam2[0],h00z),opMul(hourgam2[1],h01z)),opMul(hourgam2[2],h02z)),opMul(hourgam2[3],h03z))));
	hgfz[3]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam3[0],h00z),opMul(hourgam3[1],h01z)),opMul(hourgam3[2],h02z)),opMul(hourgam3[3],h03z))));
	hgfz[4]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam4[0],h00z),opMul(hourgam4[1],h01z)),opMul(hourgam4[2],h02z)),opMul(hourgam4[3],h03z))));
	hgfz[5]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam5[0],h00z),opMul(hourgam5[1],h01z)),opMul(hourgam5[2],h02z)),opMul(hourgam5[3],h03z))));
	hgfz[6]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam6[0],h00z),opMul(hourgam6[1],h01z)),opMul(hourgam6[2],h02z)),opMul(hourgam6[3],h03z))));
	hgfz[7]=opMul(coefficient,(opAdd(opAdd(opAdd(opMul(hourgam7[0],h00z),opMul(hourgam7[1],h01z)),opMul(hourgam7[2],h02z)),opMul(hourgam7[3],h03z))));
	}


// ********************************************************
// * _computeHourglassModes fct
// ********************************************************
__device__ inline void _computeHourglassModes(const int i1 , const Real _determ , const Real * _dvdx , const Real * _dvdy , const Real * _dvdz , const Real gamma [ 4 ] [ 8 ] , const Real * x8n , const Real * y8n , const Real * z8n , Real * __restrict__ hourgam0 , Real * __restrict__ hourgam1 , Real * __restrict__ hourgam2 , Real * __restrict__ hourgam3 , Real * __restrict__ hourgam4 , Real * __restrict__ hourgam5 , Real * __restrict__ hourgam6 , Real * __restrict__ hourgam7 ){

	/*cudaHookPrefixEnumerate*//*itm= */	/*std function*/
	// function cudaHookDumpEnumerate
	// functioncudaHookPostfixEnumerate
const Real volinv=opDiv(1.0,_determ);
	const Real hourmodx=opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opMul(x8n[0],gamma[i1][0]),opMul(x8n[1],gamma[i1][1])),opMul(x8n[2],gamma[i1][2])),opMul(x8n[3],gamma[i1][3])),opMul(x8n[4],gamma[i1][4])),opMul(x8n[5],gamma[i1][5])),opMul(x8n[6],gamma[i1][6])),opMul(x8n[7],gamma[i1][7]));
	const Real hourmody=opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opMul(y8n[0],gamma[i1][0]),opMul(y8n[1],gamma[i1][1])),opMul(y8n[2],gamma[i1][2])),opMul(y8n[3],gamma[i1][3])),opMul(y8n[4],gamma[i1][4])),opMul(y8n[5],gamma[i1][5])),opMul(y8n[6],gamma[i1][6])),opMul(y8n[7],gamma[i1][7]));
	const Real hourmodz=opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opAdd(opMul(z8n[0],gamma[i1][0]),opMul(z8n[1],gamma[i1][1])),opMul(z8n[2],gamma[i1][2])),opMul(z8n[3],gamma[i1][3])),opMul(z8n[4],gamma[i1][4])),opMul(z8n[5],gamma[i1][5])),opMul(z8n[6],gamma[i1][6])),opMul(z8n[7],gamma[i1][7]));
	hourgam0[i1]=opSub(gamma[i1][0],opMul(volinv,(opAdd(opAdd((opMul(_dvdx[0],hourmodx)),(opMul(_dvdy[0],hourmody))),(opMul(_dvdz[0],hourmodz))))));
	hourgam1[i1]=opSub(gamma[i1][1],opMul(volinv,(opAdd(opAdd((opMul(_dvdx[1],hourmodx)),(opMul(_dvdy[1],hourmody))),(opMul(_dvdz[1],hourmodz))))));
	hourgam2[i1]=opSub(gamma[i1][2],opMul(volinv,(opAdd(opAdd((opMul(_dvdx[2],hourmodx)),(opMul(_dvdy[2],hourmody))),(opMul(_dvdz[2],hourmodz))))));
	hourgam3[i1]=opSub(gamma[i1][3],opMul(volinv,(opAdd(opAdd((opMul(_dvdx[3],hourmodx)),(opMul(_dvdy[3],hourmody))),(opMul(_dvdz[3],hourmodz))))));
	hourgam4[i1]=opSub(gamma[i1][4],opMul(volinv,(opAdd(opAdd((opMul(_dvdx[4],hourmodx)),(opMul(_dvdy[4],hourmody))),(opMul(_dvdz[4],hourmodz))))));
	hourgam5[i1]=opSub(gamma[i1][5],opMul(volinv,(opAdd(opAdd((opMul(_dvdx[5],hourmodx)),(opMul(_dvdy[5],hourmody))),(opMul(_dvdz[5],hourmodz))))));
	hourgam6[i1]=opSub(gamma[i1][6],opMul(volinv,(opAdd(opAdd((opMul(_dvdx[6],hourmodx)),(opMul(_dvdy[6],hourmody))),(opMul(_dvdz[6],hourmodz))))));
	hourgam7[i1]=opSub(gamma[i1][7],opMul(volinv,(opAdd(opAdd((opMul(_dvdx[7],hourmodx)),(opMul(_dvdy[7],hourmody))),(opMul(_dvdz[7],hourmodz))))));
	}


// ********************************************************
// * _calcElemVolume fct
// ********************************************************
__device__ inline Real _calcElemVolume(const Real x0 , const Real x1 , const Real x2 , const Real x3 , const Real x4 , const Real x5 , const Real x6 , const Real x7 , const Real y0 , const Real y1 , const Real y2 , const Real y3 , const Real y4 , const Real y5 , const Real y6 , const Real y7 , const Real z0 , const Real z1 , const Real z2 , const Real z3 , const Real z4 , const Real z5 , const Real z6 , const Real z7 ){

	/*cudaHookPrefixEnumerate*//*itm= */	/*std function*/
	// function cudaHookDumpEnumerate
	// functioncudaHookPostfixEnumerate
const Real twelveth=opDiv(1.0,12.0);
	const Real dx61=opSub(x6,x1);
	const Real dy61=opSub(y6,y1);
	const Real dz61=opSub(z6,z1);
	const Real dx70=opSub(x7,x0);
	const Real dy70=opSub(y7,y0);
	const Real dz70=opSub(z7,z0);
	const Real dx63=opSub(x6,x3);
	const Real dy63=opSub(y6,y3);
	const Real dz63=opSub(z6,z3);
	const Real dx20=opSub(x2,x0);
	const Real dy20=opSub(y2,y0);
	const Real dz20=opSub(z2,z0);
	const Real dx50=opSub(x5,x0);
	const Real dy50=opSub(y5,y0);
	const Real dz50=opSub(z5,z0);
	const Real dx64=opSub(x6,x4);
	const Real dy64=opSub(y6,y4);
	const Real dz64=opSub(z6,z4);
	const Real dx31=opSub(x3,x1);
	const Real dy31=opSub(y3,y1);
	const Real dz31=opSub(z3,z1);
	const Real dx72=opSub(x7,x2);
	const Real dy72=opSub(y7,y2);
	const Real dz72=opSub(z7,z2);
	const Real dx43=opSub(x4,x3);
	const Real dy43=opSub(y4,y3);
	const Real dz43=opSub(z4,z3);
	const Real dx57=opSub(x5,x7);
	const Real dy57=opSub(y5,y7);
	const Real dz57=opSub(z5,z7);
	const Real dx14=opSub(x1,x4);
	const Real dy14=opSub(y1,y4);
	const Real dz14=opSub(z1,z4);
	const Real dx25=opSub(x2,x5);
	const Real dy25=opSub(y2,y5);
	const Real dz25=opSub(z2,z5);
	const Real tp1=(opAdd(opAdd(opMul(((opAdd(dx31,dx72))),(opSub(opMul((dy63),(dz20)),opMul((dy20),(dz63))))),opMul(((opAdd(dy31,dy72))),(opSub(opMul((dx20),(dz63)),opMul((dx63),(dz20)))))),opMul(((opAdd(dz31,dz72))),(opSub(opMul((dx63),(dy20)),opMul((dx20),(dy63)))))));
	const Real tp2=(opAdd(opAdd(opMul(((opAdd(dx43,dx57))),(opSub(opMul((dy64),(dz70)),opMul((dy70),(dz64))))),opMul(((opAdd(dy43,dy57))),(opSub(opMul((dx70),(dz64)),opMul((dx64),(dz70)))))),opMul(((opAdd(dz43,dz57))),(opSub(opMul((dx64),(dy70)),opMul((dx70),(dy64)))))));
	const Real tp3=(opAdd(opAdd(opMul(((opAdd(dx14,dx25))),(opSub(opMul((dy61),(dz50)),opMul((dy50),(dz61))))),opMul(((opAdd(dy14,dy25))),(opSub(opMul((dx50),(dz61)),opMul((dx61),(dz50)))))),opMul(((opAdd(dz14,dz25))),(opSub(opMul((dx61),(dy50)),opMul((dx50),(dy61)))))));
	return opMul(twelveth,(opAdd(opAdd(tp1,tp2),tp3)));
	}


// ********************************************************
// * AreaFace fct
// ********************************************************
__device__ inline Real AreaFace(const Real x0 , const Real x1 , const Real x2 , const Real x3 , const Real y0 , const Real y1 , const Real y2 , const Real y3 , const Real z0 , const Real z1 , const Real z2 , const Real z3 ){

	/*cudaHookPrefixEnumerate*//*itm= */	/*std function*/
	// function cudaHookDumpEnumerate
	// functioncudaHookPostfixEnumerate
const Real fx=opSub((opSub(x2,x0)),(opSub(x3,x1)));
	const Real fy=opSub((opSub(y2,y0)),(opSub(y3,y1)));
	const Real fz=opSub((opSub(z2,z0)),(opSub(z3,z1)));
	const Real gx=opAdd((opSub(x2,x0)),(opSub(x3,x1)));
	const Real gy=opAdd((opSub(y2,y0)),(opSub(y3,y1)));
	const Real gz=opAdd((opSub(z2,z0)),(opSub(z3,z1)));
	return opSub(opMul((opAdd(opAdd(opMul(fx,fx),opMul(fy,fy)),opMul(fz,fz))),(opAdd(opAdd(opMul(gx,gx),opMul(gy,gy)),opMul(gz,gz)))),opMul((opAdd(opAdd(opMul(fx,gx),opMul(fy,gy)),opMul(fz,gz))),(opAdd(opAdd(opMul(fx,gx),opMul(fy,gy)),opMul(fz,gz)))));
	}


// ********************************************************
// * calcElemCharacteristicLength fct
// ********************************************************
__device__ inline Real calcElemCharacteristicLength(const Real x [ 8 ] , const Real y [ 8 ] , const Real z [ 8 ] , const Real _volume ){

	/*cudaHookPrefixEnumerate*//*itm= */	/*std function*/
	// function cudaHookDumpEnumerate
	// functioncudaHookPostfixEnumerate
Real a,charLength=0.0;
	a=/*function_got_call*//*AreaFace*//*isNablaFunction*/AreaFace(x[0],x[1],x[2],x[3],y[0],y[1],y[2],y[3],z[0],z[1],z[2],z[3]);
	charLength=/*function_got_call*//*max*//*has not been found*/max(a,charLength);
	a=/*function_got_call*//*AreaFace*//*isNablaFunction*/AreaFace(x[4],x[5],x[6],x[7],y[4],y[5],y[6],y[7],z[4],z[5],z[6],z[7]);
	charLength=/*function_got_call*//*max*//*has not been found*/max(a,charLength);
	a=/*function_got_call*//*AreaFace*//*isNablaFunction*/AreaFace(x[0],x[1],x[5],x[4],y[0],y[1],y[5],y[4],z[0],z[1],z[5],z[4]);
	charLength=/*function_got_call*//*max*//*has not been found*/max(a,charLength);
	a=/*function_got_call*//*AreaFace*//*isNablaFunction*/AreaFace(x[1],x[2],x[6],x[5],y[1],y[2],y[6],y[5],z[1],z[2],z[6],z[5]);
	charLength=/*function_got_call*//*max*//*has not been found*/max(a,charLength);
	a=/*function_got_call*//*AreaFace*//*isNablaFunction*/AreaFace(x[2],x[3],x[7],x[6],y[2],y[3],y[7],y[6],z[2],z[3],z[7],z[6]);
	charLength=/*function_got_call*//*max*//*has not been found*/max(a,charLength);
	a=/*function_got_call*//*AreaFace*//*isNablaFunction*/AreaFace(x[3],x[0],x[4],x[7],y[3],y[0],y[4],y[7],z[3],z[0],z[4],z[7]);
	charLength=/*function_got_call*//*max*//*has not been found*/max(a,charLength);
	return opDiv(opMul(4.0,_volume),rsqrt(charLength));
	}



// ********************************************************
// * calcForceForNodesIni job
// ********************************************************
__global__ void calcForceForNodesIni(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		real *node_nForcex,
		real *node_nForcey,
		real *node_nForcez){// du job
	/*cudaHookPrefixEnumerate*//*itm=n*/
	CUDA_INI_NODE_THREAD(tnid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		/* DiffractingREADY *//*isLeft*//*NodeJob*//*tt2a*/node_nForcex/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]/*'='->!isLeft*/=/*isLeft*//*NodeJob*//*tt2a*/node_nForcey/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]/*'='->!isLeft*/=/*isLeft*//*NodeJob*//*tt2a*/node_nForcez/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]/*'='->!isLeft*/= 0.0  ;
		}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * integrateStressForElems job
// ********************************************************
__global__ void integrateStressForElems(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_p,
		real *cell_q,
		real *cell_determ,
		real *cell_sigx,
		real *cell_sigy,
		real *cell_sigz,
		real *cell_epx,
		real *cell_epy,
		real *cell_epz,
		real *node_nForcex,
		real *node_nForcey,
		real *node_nForcez){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		Real Bx [8 ], By [8 ], Bz [8 ];
		Real x [8 ], y [8 ], z [8 ];
		/*chsf n*/for(int n=0;n<8;++n){
		/* DiffractingREADY *//*isLeft*/x [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_coordx/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		/* DiffractingREADY *//*isLeft*/y [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_coordy/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		/* DiffractingREADY *//*isLeft*/z [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_coordz/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		/* DiffractingREADY *//*isLeft*/Bx [n] /*'='->!isLeft*/=/*isLeft*/By [n] /*'='->!isLeft*/=/*isLeft*/Bz [n] /*'='->!isLeft*/= 0.0  ;
		}/*FOREACH_END*/{
		const Real djx /*'='->!isLeft*/=opMul ( - 0.25 , ( opSub ( ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/x [0 /*postfix_constant_value*/], /*postfix_constant@true*/x [1 /*postfix_constant_value*/]) , /*postfix_constant@true*/x [5 /*postfix_constant_value*/]) , /*postfix_constant@true*/x [4 /*postfix_constant_value*/]) ) , ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/x [3 /*postfix_constant_value*/], /*postfix_constant@true*/x [2 /*postfix_constant_value*/]) , /*postfix_constant@true*/x [6 /*postfix_constant_value*/]) , /*postfix_constant@true*/x [7 /*postfix_constant_value*/]) ) ) ) ) ;
		const Real djy /*'='->!isLeft*/=opMul ( - 0.25 , ( opSub ( ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/y [0 /*postfix_constant_value*/], /*postfix_constant@true*/y [1 /*postfix_constant_value*/]) , /*postfix_constant@true*/y [5 /*postfix_constant_value*/]) , /*postfix_constant@true*/y [4 /*postfix_constant_value*/]) ) , ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/y [3 /*postfix_constant_value*/], /*postfix_constant@true*/y [2 /*postfix_constant_value*/]) , /*postfix_constant@true*/y [6 /*postfix_constant_value*/]) , /*postfix_constant@true*/y [7 /*postfix_constant_value*/]) ) ) ) ) ;
		const Real djz /*'='->!isLeft*/=opMul ( - 0.25 , ( opSub ( ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/z [0 /*postfix_constant_value*/], /*postfix_constant@true*/z [1 /*postfix_constant_value*/]) , /*postfix_constant@true*/z [5 /*postfix_constant_value*/]) , /*postfix_constant@true*/z [4 /*postfix_constant_value*/]) ) , ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/z [3 /*postfix_constant_value*/], /*postfix_constant@true*/z [2 /*postfix_constant_value*/]) , /*postfix_constant@true*/z [6 /*postfix_constant_value*/]) , /*postfix_constant@true*/z [7 /*postfix_constant_value*/]) ) ) ) ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_epx/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=djx ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_epy/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=djy ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_epz/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=djz ;
		}/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_sigx/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=/*isLeft*//*CellJob*//*tt2a*/cell_sigy/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=/*isLeft*//*CellJob*//*tt2a*/cell_sigz/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opSub ( - /*CellJob*//*tt2a*/cell_p/*nvar no diffraction possible here*//*CellVar*/[tcid], /*CellJob*//*tt2a*/cell_q/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/* DiffractingREADY *//*JOB_CALL*//*got_call*//*isNablaFunction*/calcElemShapeFunctionDerivatives ( /*function_call_arguments*/x , y , z , Bx , By , Bz , /*adrs*/&( /*CellJob*//*tt2a*/cell_determ/*nvar no diffraction possible here*//*CellVar*/[tcid]) /*ARGS*//*got_args*/) ;
		/*!function_call_arguments*//* DiffractingREADY *//*JOB_CALL*//*got_call*//*isNablaFunction*/sumElemFaceNormal ( /*function_call_arguments*//*adrs*/&( /*postfix_constant@true*/Bx [0 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [0 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [0 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bx [1 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [1 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [1 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bx [2 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [2 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [2 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bx [3 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [3 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [3 /*postfix_constant_value*/]) , 0 , 1 , 2 , 3 , /*adrs*/&( /*postfix_constant@true*/x [0 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/y [0 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/z [0 /*postfix_constant_value*/]) /*ARGS*//*got_args*/) ;
		/*!function_call_arguments*//* DiffractingREADY *//*JOB_CALL*//*got_call*//*isNablaFunction*/sumElemFaceNormal ( /*function_call_arguments*//*adrs*/&( /*postfix_constant@true*/Bx [0 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [0 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [0 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bx [4 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [4 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [4 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bx [5 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [5 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [5 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bx [1 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [1 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [1 /*postfix_constant_value*/]) , 0 , 4 , 5 , 1 , /*adrs*/&( /*postfix_constant@true*/x [0 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/y [0 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/z [0 /*postfix_constant_value*/]) /*ARGS*//*got_args*/) ;
		/*!function_call_arguments*//* DiffractingREADY *//*JOB_CALL*//*got_call*//*isNablaFunction*/sumElemFaceNormal ( /*function_call_arguments*//*adrs*/&( /*postfix_constant@true*/Bx [1 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [1 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [1 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bx [5 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [5 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [5 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bx [6 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [6 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [6 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bx [2 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [2 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [2 /*postfix_constant_value*/]) , 1 , 5 , 6 , 2 , /*adrs*/&( /*postfix_constant@true*/x [0 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/y [0 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/z [0 /*postfix_constant_value*/]) /*ARGS*//*got_args*/) ;
		/*!function_call_arguments*//* DiffractingREADY *//*JOB_CALL*//*got_call*//*isNablaFunction*/sumElemFaceNormal ( /*function_call_arguments*//*adrs*/&( /*postfix_constant@true*/Bx [2 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [2 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [2 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bx [6 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [6 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [6 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bx [7 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [7 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [7 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bx [3 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [3 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [3 /*postfix_constant_value*/]) , 2 , 6 , 7 , 3 , /*adrs*/&( /*postfix_constant@true*/x [0 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/y [0 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/z [0 /*postfix_constant_value*/]) /*ARGS*//*got_args*/) ;
		/*!function_call_arguments*//* DiffractingREADY *//*JOB_CALL*//*got_call*//*isNablaFunction*/sumElemFaceNormal ( /*function_call_arguments*//*adrs*/&( /*postfix_constant@true*/Bx [3 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [3 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [3 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bx [7 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [7 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [7 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bx [4 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [4 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [4 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bx [0 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [0 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [0 /*postfix_constant_value*/]) , 3 , 7 , 4 , 0 , /*adrs*/&( /*postfix_constant@true*/x [0 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/y [0 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/z [0 /*postfix_constant_value*/]) /*ARGS*//*got_args*/) ;
		/*!function_call_arguments*//* DiffractingREADY *//*JOB_CALL*//*got_call*//*isNablaFunction*/sumElemFaceNormal ( /*function_call_arguments*//*adrs*/&( /*postfix_constant@true*/Bx [4 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [4 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [4 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bx [7 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [7 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [7 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bx [6 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [6 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [6 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bx [5 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/By [5 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/Bz [5 /*postfix_constant_value*/]) , 4 , 7 , 6 , 5 , /*adrs*/&( /*postfix_constant@true*/x [0 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/y [0 /*postfix_constant_value*/]) , /*adrs*/&( /*postfix_constant@true*/z [0 /*postfix_constant_value*/]) /*ARGS*//*got_args*/) ;
		/*!function_call_arguments*//*chsf n*/for(int n=0;n<8;++n){
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/node_nForcex/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/+=opMul ( - /*CellJob*//*tt2a*/cell_sigx/*nvar no diffraction possible here*//*CellVar*/[tcid], Bx [n] ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/node_nForcey/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/+=opMul ( - /*CellJob*//*tt2a*/cell_sigy/*nvar no diffraction possible here*//*CellVar*/[tcid], By [n] ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/node_nForcez/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/+=opMul ( - /*CellJob*//*tt2a*/cell_sigz/*nvar no diffraction possible here*//*CellVar*/[tcid], Bz [n] ) ;
		}/*FOREACH_END*/}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * sumElemStressesToNodeForces job
// ********************************************************
__global__ void sumElemStressesToNodeForces(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_volo,
		real *cell_v,
		real *cell_determ,
		real *cell_sound_speed,
		real *cell_elemMass,
		real *node_nVelocityx,
		real *node_nVelocityy,
		real *node_nVelocityz,
		real *node_nForcex,
		real *node_nForcey,
		real *node_nForcez){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		const Real twelfth /*'='->!isLeft*/=opDiv (  1.0  ,  12.0  ) ;
		const Real gamma [4 ][8 ]/*'='->!isLeft*/={
		{
		 1.  ,  1.  , - 1. , - 1. , - 1. , - 1. ,  1.  ,  1.  }, {
		 1.  , - 1. , - 1. ,  1.  , - 1. ,  1.  ,  1.  , - 1. }, {
		 1.  , - 1. ,  1.  , - 1. ,  1.  , - 1. ,  1.  , - 1. }, {
		- 1. ,  1.  , - 1. ,  1.  ,  1.  , - 1. ,  1.  , - 1. }};
		const Real hourg /*'='->!isLeft*/=/*tt2o cuda*/option_hgcoef;
		Real x [8 ], y [8 ], z [8 ];
		Real xd [8 ], yd [8 ], zd [8 ];
		Real dvdx [8 ], dvdy [8 ], dvdz [8 ];
		Real hourgam0 [4 ], hourgam1 [4 ], hourgam2 [4 ], hourgam3 [4 ];
		Real hourgam4 [4 ], hourgam5 [4 ], hourgam6 [4 ], hourgam7 [4 ];
		Real hgfx [8 ], hgfy [8 ], hgfz [8 ];
		/*chsf n*/for(int n=0;n<8;++n){
		/* DiffractingREADY *//*isLeft*/x [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_coordx/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		/* DiffractingREADY *//*isLeft*/y [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_coordy/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		/* DiffractingREADY *//*isLeft*/z [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_coordz/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		}/*FOREACH_END*//*chsf n*/for(int n=0;n<8;++n){
		/* DiffractingREADY *//*isLeft*/xd [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_nVelocityx/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		/* DiffractingREADY *//*isLeft*/yd [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_nVelocityy/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		/* DiffractingREADY *//*isLeft*/zd [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_nVelocityz/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		}/*FOREACH_END*/{
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdx [0 /*postfix_constant_value*/]) /*'='->!isLeft*/=opAdd ( opSub ( opSub ( opAdd ( opSub ( opMul ( ( opAdd ( /*postfix_constant@true*/y [2 /*postfix_constant_value*/], /*postfix_constant@true*/y [3 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [1 /*postfix_constant_value*/], /*postfix_constant@true*/z [2 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [1 /*postfix_constant_value*/], /*postfix_constant@true*/y [2 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [2 /*postfix_constant_value*/], /*postfix_constant@true*/z [3 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [1 /*postfix_constant_value*/], /*postfix_constant@true*/y [5 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [4 /*postfix_constant_value*/], /*postfix_constant@true*/z [5 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [4 /*postfix_constant_value*/], /*postfix_constant@true*/y [5 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [1 /*postfix_constant_value*/], /*postfix_constant@true*/z [5 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [3 /*postfix_constant_value*/], /*postfix_constant@true*/y [7 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [4 /*postfix_constant_value*/], /*postfix_constant@true*/z [7 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [4 /*postfix_constant_value*/], /*postfix_constant@true*/y [7 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [3 /*postfix_constant_value*/], /*postfix_constant@true*/z [7 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdy [0 /*postfix_constant_value*/]) /*'='->!isLeft*/=opSub ( opAdd ( opAdd ( opSub ( opAdd ( opMul ( - ( opAdd ( /*postfix_constant@true*/x [2 /*postfix_constant_value*/], /*postfix_constant@true*/x [3 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [1 /*postfix_constant_value*/], /*postfix_constant@true*/z [2 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [1 /*postfix_constant_value*/], /*postfix_constant@true*/x [2 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [2 /*postfix_constant_value*/], /*postfix_constant@true*/z [3 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [1 /*postfix_constant_value*/], /*postfix_constant@true*/x [5 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [4 /*postfix_constant_value*/], /*postfix_constant@true*/z [5 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [4 /*postfix_constant_value*/], /*postfix_constant@true*/x [5 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [1 /*postfix_constant_value*/], /*postfix_constant@true*/z [5 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [3 /*postfix_constant_value*/], /*postfix_constant@true*/x [7 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [4 /*postfix_constant_value*/], /*postfix_constant@true*/z [7 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [4 /*postfix_constant_value*/], /*postfix_constant@true*/x [7 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [3 /*postfix_constant_value*/], /*postfix_constant@true*/z [7 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdz [0 /*postfix_constant_value*/]) /*'='->!isLeft*/=opSub ( opAdd ( opAdd ( opSub ( opAdd ( opMul ( - ( opAdd ( /*postfix_constant@true*/y [2 /*postfix_constant_value*/], /*postfix_constant@true*/y [3 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [1 /*postfix_constant_value*/], /*postfix_constant@true*/x [2 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [1 /*postfix_constant_value*/], /*postfix_constant@true*/y [2 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [2 /*postfix_constant_value*/], /*postfix_constant@true*/x [3 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [1 /*postfix_constant_value*/], /*postfix_constant@true*/y [5 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [4 /*postfix_constant_value*/], /*postfix_constant@true*/x [5 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [4 /*postfix_constant_value*/], /*postfix_constant@true*/y [5 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [1 /*postfix_constant_value*/], /*postfix_constant@true*/x [5 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [3 /*postfix_constant_value*/], /*postfix_constant@true*/y [7 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [4 /*postfix_constant_value*/], /*postfix_constant@true*/x [7 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [4 /*postfix_constant_value*/], /*postfix_constant@true*/y [7 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [3 /*postfix_constant_value*/], /*postfix_constant@true*/x [7 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdx [0 /*postfix_constant_value*/]) *=twelfth ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdy [0 /*postfix_constant_value*/]) *=twelfth ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdz [0 /*postfix_constant_value*/]) *=twelfth ;
		};
		{
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdx [3 /*postfix_constant_value*/]) /*'='->!isLeft*/=opAdd ( opSub ( opSub ( opAdd ( opSub ( opMul ( ( opAdd ( /*postfix_constant@true*/y [1 /*postfix_constant_value*/], /*postfix_constant@true*/y [2 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [0 /*postfix_constant_value*/], /*postfix_constant@true*/z [1 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [0 /*postfix_constant_value*/], /*postfix_constant@true*/y [1 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [1 /*postfix_constant_value*/], /*postfix_constant@true*/z [2 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [0 /*postfix_constant_value*/], /*postfix_constant@true*/y [4 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [7 /*postfix_constant_value*/], /*postfix_constant@true*/z [4 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [7 /*postfix_constant_value*/], /*postfix_constant@true*/y [4 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [0 /*postfix_constant_value*/], /*postfix_constant@true*/z [4 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [2 /*postfix_constant_value*/], /*postfix_constant@true*/y [6 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [7 /*postfix_constant_value*/], /*postfix_constant@true*/z [6 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [7 /*postfix_constant_value*/], /*postfix_constant@true*/y [6 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [2 /*postfix_constant_value*/], /*postfix_constant@true*/z [6 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdy [3 /*postfix_constant_value*/]) /*'='->!isLeft*/=opSub ( opAdd ( opAdd ( opSub ( opAdd ( opMul ( - ( opAdd ( /*postfix_constant@true*/x [1 /*postfix_constant_value*/], /*postfix_constant@true*/x [2 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [0 /*postfix_constant_value*/], /*postfix_constant@true*/z [1 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [0 /*postfix_constant_value*/], /*postfix_constant@true*/x [1 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [1 /*postfix_constant_value*/], /*postfix_constant@true*/z [2 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [0 /*postfix_constant_value*/], /*postfix_constant@true*/x [4 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [7 /*postfix_constant_value*/], /*postfix_constant@true*/z [4 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [7 /*postfix_constant_value*/], /*postfix_constant@true*/x [4 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [0 /*postfix_constant_value*/], /*postfix_constant@true*/z [4 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [2 /*postfix_constant_value*/], /*postfix_constant@true*/x [6 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [7 /*postfix_constant_value*/], /*postfix_constant@true*/z [6 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [7 /*postfix_constant_value*/], /*postfix_constant@true*/x [6 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [2 /*postfix_constant_value*/], /*postfix_constant@true*/z [6 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdz [3 /*postfix_constant_value*/]) /*'='->!isLeft*/=opSub ( opAdd ( opAdd ( opSub ( opAdd ( opMul ( - ( opAdd ( /*postfix_constant@true*/y [1 /*postfix_constant_value*/], /*postfix_constant@true*/y [2 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [0 /*postfix_constant_value*/], /*postfix_constant@true*/x [1 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [0 /*postfix_constant_value*/], /*postfix_constant@true*/y [1 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [1 /*postfix_constant_value*/], /*postfix_constant@true*/x [2 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [0 /*postfix_constant_value*/], /*postfix_constant@true*/y [4 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [7 /*postfix_constant_value*/], /*postfix_constant@true*/x [4 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [7 /*postfix_constant_value*/], /*postfix_constant@true*/y [4 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [0 /*postfix_constant_value*/], /*postfix_constant@true*/x [4 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [2 /*postfix_constant_value*/], /*postfix_constant@true*/y [6 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [7 /*postfix_constant_value*/], /*postfix_constant@true*/x [6 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [7 /*postfix_constant_value*/], /*postfix_constant@true*/y [6 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [2 /*postfix_constant_value*/], /*postfix_constant@true*/x [6 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdx [3 /*postfix_constant_value*/]) *=twelfth ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdy [3 /*postfix_constant_value*/]) *=twelfth ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdz [3 /*postfix_constant_value*/]) *=twelfth ;
		};
		{
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdx [2 /*postfix_constant_value*/]) /*'='->!isLeft*/=opAdd ( opSub ( opSub ( opAdd ( opSub ( opMul ( ( opAdd ( /*postfix_constant@true*/y [0 /*postfix_constant_value*/], /*postfix_constant@true*/y [1 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [3 /*postfix_constant_value*/], /*postfix_constant@true*/z [0 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [3 /*postfix_constant_value*/], /*postfix_constant@true*/y [0 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [0 /*postfix_constant_value*/], /*postfix_constant@true*/z [1 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [3 /*postfix_constant_value*/], /*postfix_constant@true*/y [7 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [6 /*postfix_constant_value*/], /*postfix_constant@true*/z [7 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [6 /*postfix_constant_value*/], /*postfix_constant@true*/y [7 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [3 /*postfix_constant_value*/], /*postfix_constant@true*/z [7 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [1 /*postfix_constant_value*/], /*postfix_constant@true*/y [5 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [6 /*postfix_constant_value*/], /*postfix_constant@true*/z [5 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [6 /*postfix_constant_value*/], /*postfix_constant@true*/y [5 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [1 /*postfix_constant_value*/], /*postfix_constant@true*/z [5 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdy [2 /*postfix_constant_value*/]) /*'='->!isLeft*/=opSub ( opAdd ( opAdd ( opSub ( opAdd ( opMul ( - ( opAdd ( /*postfix_constant@true*/x [0 /*postfix_constant_value*/], /*postfix_constant@true*/x [1 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [3 /*postfix_constant_value*/], /*postfix_constant@true*/z [0 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [3 /*postfix_constant_value*/], /*postfix_constant@true*/x [0 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [0 /*postfix_constant_value*/], /*postfix_constant@true*/z [1 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [3 /*postfix_constant_value*/], /*postfix_constant@true*/x [7 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [6 /*postfix_constant_value*/], /*postfix_constant@true*/z [7 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [6 /*postfix_constant_value*/], /*postfix_constant@true*/x [7 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [3 /*postfix_constant_value*/], /*postfix_constant@true*/z [7 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [1 /*postfix_constant_value*/], /*postfix_constant@true*/x [5 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [6 /*postfix_constant_value*/], /*postfix_constant@true*/z [5 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [6 /*postfix_constant_value*/], /*postfix_constant@true*/x [5 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [1 /*postfix_constant_value*/], /*postfix_constant@true*/z [5 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdz [2 /*postfix_constant_value*/]) /*'='->!isLeft*/=opSub ( opAdd ( opAdd ( opSub ( opAdd ( opMul ( - ( opAdd ( /*postfix_constant@true*/y [0 /*postfix_constant_value*/], /*postfix_constant@true*/y [1 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [3 /*postfix_constant_value*/], /*postfix_constant@true*/x [0 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [3 /*postfix_constant_value*/], /*postfix_constant@true*/y [0 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [0 /*postfix_constant_value*/], /*postfix_constant@true*/x [1 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [3 /*postfix_constant_value*/], /*postfix_constant@true*/y [7 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [6 /*postfix_constant_value*/], /*postfix_constant@true*/x [7 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [6 /*postfix_constant_value*/], /*postfix_constant@true*/y [7 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [3 /*postfix_constant_value*/], /*postfix_constant@true*/x [7 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [1 /*postfix_constant_value*/], /*postfix_constant@true*/y [5 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [6 /*postfix_constant_value*/], /*postfix_constant@true*/x [5 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [6 /*postfix_constant_value*/], /*postfix_constant@true*/y [5 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [1 /*postfix_constant_value*/], /*postfix_constant@true*/x [5 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdx [2 /*postfix_constant_value*/]) *=twelfth ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdy [2 /*postfix_constant_value*/]) *=twelfth ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdz [2 /*postfix_constant_value*/]) *=twelfth ;
		};
		{
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdx [1 /*postfix_constant_value*/]) /*'='->!isLeft*/=opAdd ( opSub ( opSub ( opAdd ( opSub ( opMul ( ( opAdd ( /*postfix_constant@true*/y [3 /*postfix_constant_value*/], /*postfix_constant@true*/y [0 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [2 /*postfix_constant_value*/], /*postfix_constant@true*/z [3 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [2 /*postfix_constant_value*/], /*postfix_constant@true*/y [3 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [3 /*postfix_constant_value*/], /*postfix_constant@true*/z [0 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [2 /*postfix_constant_value*/], /*postfix_constant@true*/y [6 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [5 /*postfix_constant_value*/], /*postfix_constant@true*/z [6 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [5 /*postfix_constant_value*/], /*postfix_constant@true*/y [6 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [2 /*postfix_constant_value*/], /*postfix_constant@true*/z [6 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [0 /*postfix_constant_value*/], /*postfix_constant@true*/y [4 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [5 /*postfix_constant_value*/], /*postfix_constant@true*/z [4 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [5 /*postfix_constant_value*/], /*postfix_constant@true*/y [4 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [0 /*postfix_constant_value*/], /*postfix_constant@true*/z [4 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdy [1 /*postfix_constant_value*/]) /*'='->!isLeft*/=opSub ( opAdd ( opAdd ( opSub ( opAdd ( opMul ( - ( opAdd ( /*postfix_constant@true*/x [3 /*postfix_constant_value*/], /*postfix_constant@true*/x [0 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [2 /*postfix_constant_value*/], /*postfix_constant@true*/z [3 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [2 /*postfix_constant_value*/], /*postfix_constant@true*/x [3 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [3 /*postfix_constant_value*/], /*postfix_constant@true*/z [0 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [2 /*postfix_constant_value*/], /*postfix_constant@true*/x [6 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [5 /*postfix_constant_value*/], /*postfix_constant@true*/z [6 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [5 /*postfix_constant_value*/], /*postfix_constant@true*/x [6 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [2 /*postfix_constant_value*/], /*postfix_constant@true*/z [6 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [0 /*postfix_constant_value*/], /*postfix_constant@true*/x [4 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [5 /*postfix_constant_value*/], /*postfix_constant@true*/z [4 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [5 /*postfix_constant_value*/], /*postfix_constant@true*/x [4 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [0 /*postfix_constant_value*/], /*postfix_constant@true*/z [4 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdz [1 /*postfix_constant_value*/]) /*'='->!isLeft*/=opSub ( opAdd ( opAdd ( opSub ( opAdd ( opMul ( - ( opAdd ( /*postfix_constant@true*/y [3 /*postfix_constant_value*/], /*postfix_constant@true*/y [0 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [2 /*postfix_constant_value*/], /*postfix_constant@true*/x [3 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [2 /*postfix_constant_value*/], /*postfix_constant@true*/y [3 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [3 /*postfix_constant_value*/], /*postfix_constant@true*/x [0 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [2 /*postfix_constant_value*/], /*postfix_constant@true*/y [6 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [5 /*postfix_constant_value*/], /*postfix_constant@true*/x [6 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [5 /*postfix_constant_value*/], /*postfix_constant@true*/y [6 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [2 /*postfix_constant_value*/], /*postfix_constant@true*/x [6 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [0 /*postfix_constant_value*/], /*postfix_constant@true*/y [4 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [5 /*postfix_constant_value*/], /*postfix_constant@true*/x [4 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [5 /*postfix_constant_value*/], /*postfix_constant@true*/y [4 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [0 /*postfix_constant_value*/], /*postfix_constant@true*/x [4 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdx [1 /*postfix_constant_value*/]) *=twelfth ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdy [1 /*postfix_constant_value*/]) *=twelfth ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdz [1 /*postfix_constant_value*/]) *=twelfth ;
		};
		{
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdx [4 /*postfix_constant_value*/]) /*'='->!isLeft*/=opAdd ( opSub ( opSub ( opAdd ( opSub ( opMul ( ( opAdd ( /*postfix_constant@true*/y [6 /*postfix_constant_value*/], /*postfix_constant@true*/y [5 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [7 /*postfix_constant_value*/], /*postfix_constant@true*/z [6 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [7 /*postfix_constant_value*/], /*postfix_constant@true*/y [6 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [6 /*postfix_constant_value*/], /*postfix_constant@true*/z [5 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [7 /*postfix_constant_value*/], /*postfix_constant@true*/y [3 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [0 /*postfix_constant_value*/], /*postfix_constant@true*/z [3 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [0 /*postfix_constant_value*/], /*postfix_constant@true*/y [3 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [7 /*postfix_constant_value*/], /*postfix_constant@true*/z [3 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [5 /*postfix_constant_value*/], /*postfix_constant@true*/y [1 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [0 /*postfix_constant_value*/], /*postfix_constant@true*/z [1 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [0 /*postfix_constant_value*/], /*postfix_constant@true*/y [1 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [5 /*postfix_constant_value*/], /*postfix_constant@true*/z [1 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdy [4 /*postfix_constant_value*/]) /*'='->!isLeft*/=opSub ( opAdd ( opAdd ( opSub ( opAdd ( opMul ( - ( opAdd ( /*postfix_constant@true*/x [6 /*postfix_constant_value*/], /*postfix_constant@true*/x [5 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [7 /*postfix_constant_value*/], /*postfix_constant@true*/z [6 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [7 /*postfix_constant_value*/], /*postfix_constant@true*/x [6 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [6 /*postfix_constant_value*/], /*postfix_constant@true*/z [5 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [7 /*postfix_constant_value*/], /*postfix_constant@true*/x [3 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [0 /*postfix_constant_value*/], /*postfix_constant@true*/z [3 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [0 /*postfix_constant_value*/], /*postfix_constant@true*/x [3 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [7 /*postfix_constant_value*/], /*postfix_constant@true*/z [3 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [5 /*postfix_constant_value*/], /*postfix_constant@true*/x [1 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [0 /*postfix_constant_value*/], /*postfix_constant@true*/z [1 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [0 /*postfix_constant_value*/], /*postfix_constant@true*/x [1 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [5 /*postfix_constant_value*/], /*postfix_constant@true*/z [1 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdz [4 /*postfix_constant_value*/]) /*'='->!isLeft*/=opSub ( opAdd ( opAdd ( opSub ( opAdd ( opMul ( - ( opAdd ( /*postfix_constant@true*/y [6 /*postfix_constant_value*/], /*postfix_constant@true*/y [5 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [7 /*postfix_constant_value*/], /*postfix_constant@true*/x [6 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [7 /*postfix_constant_value*/], /*postfix_constant@true*/y [6 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [6 /*postfix_constant_value*/], /*postfix_constant@true*/x [5 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [7 /*postfix_constant_value*/], /*postfix_constant@true*/y [3 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [0 /*postfix_constant_value*/], /*postfix_constant@true*/x [3 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [0 /*postfix_constant_value*/], /*postfix_constant@true*/y [3 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [7 /*postfix_constant_value*/], /*postfix_constant@true*/x [3 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [5 /*postfix_constant_value*/], /*postfix_constant@true*/y [1 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [0 /*postfix_constant_value*/], /*postfix_constant@true*/x [1 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [0 /*postfix_constant_value*/], /*postfix_constant@true*/y [1 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [5 /*postfix_constant_value*/], /*postfix_constant@true*/x [1 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdx [4 /*postfix_constant_value*/]) *=twelfth ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdy [4 /*postfix_constant_value*/]) *=twelfth ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdz [4 /*postfix_constant_value*/]) *=twelfth ;
		};
		{
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdx [5 /*postfix_constant_value*/]) /*'='->!isLeft*/=opAdd ( opSub ( opSub ( opAdd ( opSub ( opMul ( ( opAdd ( /*postfix_constant@true*/y [7 /*postfix_constant_value*/], /*postfix_constant@true*/y [6 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [4 /*postfix_constant_value*/], /*postfix_constant@true*/z [7 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [4 /*postfix_constant_value*/], /*postfix_constant@true*/y [7 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [7 /*postfix_constant_value*/], /*postfix_constant@true*/z [6 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [4 /*postfix_constant_value*/], /*postfix_constant@true*/y [0 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [1 /*postfix_constant_value*/], /*postfix_constant@true*/z [0 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [1 /*postfix_constant_value*/], /*postfix_constant@true*/y [0 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [4 /*postfix_constant_value*/], /*postfix_constant@true*/z [0 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [6 /*postfix_constant_value*/], /*postfix_constant@true*/y [2 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [1 /*postfix_constant_value*/], /*postfix_constant@true*/z [2 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [1 /*postfix_constant_value*/], /*postfix_constant@true*/y [2 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [6 /*postfix_constant_value*/], /*postfix_constant@true*/z [2 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdy [5 /*postfix_constant_value*/]) /*'='->!isLeft*/=opSub ( opAdd ( opAdd ( opSub ( opAdd ( opMul ( - ( opAdd ( /*postfix_constant@true*/x [7 /*postfix_constant_value*/], /*postfix_constant@true*/x [6 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [4 /*postfix_constant_value*/], /*postfix_constant@true*/z [7 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [4 /*postfix_constant_value*/], /*postfix_constant@true*/x [7 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [7 /*postfix_constant_value*/], /*postfix_constant@true*/z [6 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [4 /*postfix_constant_value*/], /*postfix_constant@true*/x [0 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [1 /*postfix_constant_value*/], /*postfix_constant@true*/z [0 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [1 /*postfix_constant_value*/], /*postfix_constant@true*/x [0 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [4 /*postfix_constant_value*/], /*postfix_constant@true*/z [0 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [6 /*postfix_constant_value*/], /*postfix_constant@true*/x [2 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [1 /*postfix_constant_value*/], /*postfix_constant@true*/z [2 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [1 /*postfix_constant_value*/], /*postfix_constant@true*/x [2 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [6 /*postfix_constant_value*/], /*postfix_constant@true*/z [2 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdz [5 /*postfix_constant_value*/]) /*'='->!isLeft*/=opSub ( opAdd ( opAdd ( opSub ( opAdd ( opMul ( - ( opAdd ( /*postfix_constant@true*/y [7 /*postfix_constant_value*/], /*postfix_constant@true*/y [6 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [4 /*postfix_constant_value*/], /*postfix_constant@true*/x [7 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [4 /*postfix_constant_value*/], /*postfix_constant@true*/y [7 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [7 /*postfix_constant_value*/], /*postfix_constant@true*/x [6 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [4 /*postfix_constant_value*/], /*postfix_constant@true*/y [0 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [1 /*postfix_constant_value*/], /*postfix_constant@true*/x [0 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [1 /*postfix_constant_value*/], /*postfix_constant@true*/y [0 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [4 /*postfix_constant_value*/], /*postfix_constant@true*/x [0 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [6 /*postfix_constant_value*/], /*postfix_constant@true*/y [2 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [1 /*postfix_constant_value*/], /*postfix_constant@true*/x [2 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [1 /*postfix_constant_value*/], /*postfix_constant@true*/y [2 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [6 /*postfix_constant_value*/], /*postfix_constant@true*/x [2 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdx [5 /*postfix_constant_value*/]) *=twelfth ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdy [5 /*postfix_constant_value*/]) *=twelfth ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdz [5 /*postfix_constant_value*/]) *=twelfth ;
		};
		{
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdx [6 /*postfix_constant_value*/]) /*'='->!isLeft*/=opAdd ( opSub ( opSub ( opAdd ( opSub ( opMul ( ( opAdd ( /*postfix_constant@true*/y [4 /*postfix_constant_value*/], /*postfix_constant@true*/y [7 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [5 /*postfix_constant_value*/], /*postfix_constant@true*/z [4 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [5 /*postfix_constant_value*/], /*postfix_constant@true*/y [4 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [4 /*postfix_constant_value*/], /*postfix_constant@true*/z [7 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [5 /*postfix_constant_value*/], /*postfix_constant@true*/y [1 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [2 /*postfix_constant_value*/], /*postfix_constant@true*/z [1 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [2 /*postfix_constant_value*/], /*postfix_constant@true*/y [1 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [5 /*postfix_constant_value*/], /*postfix_constant@true*/z [1 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [7 /*postfix_constant_value*/], /*postfix_constant@true*/y [3 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [2 /*postfix_constant_value*/], /*postfix_constant@true*/z [3 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [2 /*postfix_constant_value*/], /*postfix_constant@true*/y [3 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [7 /*postfix_constant_value*/], /*postfix_constant@true*/z [3 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdy [6 /*postfix_constant_value*/]) /*'='->!isLeft*/=opSub ( opAdd ( opAdd ( opSub ( opAdd ( opMul ( - ( opAdd ( /*postfix_constant@true*/x [4 /*postfix_constant_value*/], /*postfix_constant@true*/x [7 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [5 /*postfix_constant_value*/], /*postfix_constant@true*/z [4 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [5 /*postfix_constant_value*/], /*postfix_constant@true*/x [4 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [4 /*postfix_constant_value*/], /*postfix_constant@true*/z [7 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [5 /*postfix_constant_value*/], /*postfix_constant@true*/x [1 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [2 /*postfix_constant_value*/], /*postfix_constant@true*/z [1 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [2 /*postfix_constant_value*/], /*postfix_constant@true*/x [1 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [5 /*postfix_constant_value*/], /*postfix_constant@true*/z [1 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [7 /*postfix_constant_value*/], /*postfix_constant@true*/x [3 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [2 /*postfix_constant_value*/], /*postfix_constant@true*/z [3 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [2 /*postfix_constant_value*/], /*postfix_constant@true*/x [3 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [7 /*postfix_constant_value*/], /*postfix_constant@true*/z [3 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdz [6 /*postfix_constant_value*/]) /*'='->!isLeft*/=opSub ( opAdd ( opAdd ( opSub ( opAdd ( opMul ( - ( opAdd ( /*postfix_constant@true*/y [4 /*postfix_constant_value*/], /*postfix_constant@true*/y [7 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [5 /*postfix_constant_value*/], /*postfix_constant@true*/x [4 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [5 /*postfix_constant_value*/], /*postfix_constant@true*/y [4 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [4 /*postfix_constant_value*/], /*postfix_constant@true*/x [7 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [5 /*postfix_constant_value*/], /*postfix_constant@true*/y [1 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [2 /*postfix_constant_value*/], /*postfix_constant@true*/x [1 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [2 /*postfix_constant_value*/], /*postfix_constant@true*/y [1 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [5 /*postfix_constant_value*/], /*postfix_constant@true*/x [1 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [7 /*postfix_constant_value*/], /*postfix_constant@true*/y [3 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [2 /*postfix_constant_value*/], /*postfix_constant@true*/x [3 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [2 /*postfix_constant_value*/], /*postfix_constant@true*/y [3 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [7 /*postfix_constant_value*/], /*postfix_constant@true*/x [3 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdx [6 /*postfix_constant_value*/]) *=twelfth ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdy [6 /*postfix_constant_value*/]) *=twelfth ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdz [6 /*postfix_constant_value*/]) *=twelfth ;
		};
		{
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdx [7 /*postfix_constant_value*/]) /*'='->!isLeft*/=opAdd ( opSub ( opSub ( opAdd ( opSub ( opMul ( ( opAdd ( /*postfix_constant@true*/y [5 /*postfix_constant_value*/], /*postfix_constant@true*/y [4 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [6 /*postfix_constant_value*/], /*postfix_constant@true*/z [5 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [6 /*postfix_constant_value*/], /*postfix_constant@true*/y [5 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [5 /*postfix_constant_value*/], /*postfix_constant@true*/z [4 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [6 /*postfix_constant_value*/], /*postfix_constant@true*/y [2 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [3 /*postfix_constant_value*/], /*postfix_constant@true*/z [2 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [3 /*postfix_constant_value*/], /*postfix_constant@true*/y [2 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [6 /*postfix_constant_value*/], /*postfix_constant@true*/z [2 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [4 /*postfix_constant_value*/], /*postfix_constant@true*/y [0 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [3 /*postfix_constant_value*/], /*postfix_constant@true*/z [0 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [3 /*postfix_constant_value*/], /*postfix_constant@true*/y [0 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [4 /*postfix_constant_value*/], /*postfix_constant@true*/z [0 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdy [7 /*postfix_constant_value*/]) /*'='->!isLeft*/=opSub ( opAdd ( opAdd ( opSub ( opAdd ( opMul ( - ( opAdd ( /*postfix_constant@true*/x [5 /*postfix_constant_value*/], /*postfix_constant@true*/x [4 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [6 /*postfix_constant_value*/], /*postfix_constant@true*/z [5 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [6 /*postfix_constant_value*/], /*postfix_constant@true*/x [5 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [5 /*postfix_constant_value*/], /*postfix_constant@true*/z [4 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [6 /*postfix_constant_value*/], /*postfix_constant@true*/x [2 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [3 /*postfix_constant_value*/], /*postfix_constant@true*/z [2 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [3 /*postfix_constant_value*/], /*postfix_constant@true*/x [2 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [6 /*postfix_constant_value*/], /*postfix_constant@true*/z [2 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [4 /*postfix_constant_value*/], /*postfix_constant@true*/x [0 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [3 /*postfix_constant_value*/], /*postfix_constant@true*/z [0 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/x [3 /*postfix_constant_value*/], /*postfix_constant@true*/x [0 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/z [4 /*postfix_constant_value*/], /*postfix_constant@true*/z [0 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdz [7 /*postfix_constant_value*/]) /*'='->!isLeft*/=opSub ( opAdd ( opAdd ( opSub ( opAdd ( opMul ( - ( opAdd ( /*postfix_constant@true*/y [5 /*postfix_constant_value*/], /*postfix_constant@true*/y [4 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [6 /*postfix_constant_value*/], /*postfix_constant@true*/x [5 /*postfix_constant_value*/]) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [6 /*postfix_constant_value*/], /*postfix_constant@true*/y [5 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [5 /*postfix_constant_value*/], /*postfix_constant@true*/x [4 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [6 /*postfix_constant_value*/], /*postfix_constant@true*/y [2 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [3 /*postfix_constant_value*/], /*postfix_constant@true*/x [2 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [3 /*postfix_constant_value*/], /*postfix_constant@true*/y [2 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [6 /*postfix_constant_value*/], /*postfix_constant@true*/x [2 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [4 /*postfix_constant_value*/], /*postfix_constant@true*/y [0 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [3 /*postfix_constant_value*/], /*postfix_constant@true*/x [0 /*postfix_constant_value*/]) ) ) ) , opMul ( ( opAdd ( /*postfix_constant@true*/y [3 /*postfix_constant_value*/], /*postfix_constant@true*/y [0 /*postfix_constant_value*/]) ) , ( opAdd ( /*postfix_constant@true*/x [4 /*postfix_constant_value*/], /*postfix_constant@true*/x [0 /*postfix_constant_value*/]) ) ) ) ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdx [7 /*postfix_constant_value*/]) *=twelfth ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdy [7 /*postfix_constant_value*/]) *=twelfth ;
		/* DiffractingREADY *//*isLeft*/* /*adrs*/&( /*postfix_constant@true*/dvdz [7 /*postfix_constant_value*/]) *=twelfth ;
		};
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_determ/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opMul ( /*CellJob*//*tt2a*/cell_volo/*nvar no diffraction possible here*//*CellVar*/[tcid], /*CellJob*//*tt2a*/cell_v/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/* DiffractingREADY *//*JOB_CALL*//*got_call*//*isNablaFunction*/_computeHourglassModes ( /*function_call_arguments*/0 , /*CellJob*//*tt2a*/cell_determ/*nvar no diffraction possible here*//*CellVar*/[tcid], dvdx , dvdy , dvdz , gamma , x , y , z , hourgam0 , hourgam1 , hourgam2 , hourgam3 , hourgam4 , hourgam5 , hourgam6 , hourgam7 /*ARGS*//*got_args*/) ;
		/*!function_call_arguments*//* DiffractingREADY *//*JOB_CALL*//*got_call*//*isNablaFunction*/_computeHourglassModes ( /*function_call_arguments*/1 , /*CellJob*//*tt2a*/cell_determ/*nvar no diffraction possible here*//*CellVar*/[tcid], dvdx , dvdy , dvdz , gamma , x , y , z , hourgam0 , hourgam1 , hourgam2 , hourgam3 , hourgam4 , hourgam5 , hourgam6 , hourgam7 /*ARGS*//*got_args*/) ;
		/*!function_call_arguments*//* DiffractingREADY *//*JOB_CALL*//*got_call*//*isNablaFunction*/_computeHourglassModes ( /*function_call_arguments*/2 , /*CellJob*//*tt2a*/cell_determ/*nvar no diffraction possible here*//*CellVar*/[tcid], dvdx , dvdy , dvdz , gamma , x , y , z , hourgam0 , hourgam1 , hourgam2 , hourgam3 , hourgam4 , hourgam5 , hourgam6 , hourgam7 /*ARGS*//*got_args*/) ;
		/*!function_call_arguments*//* DiffractingREADY *//*JOB_CALL*//*got_call*//*isNablaFunction*/_computeHourglassModes ( /*function_call_arguments*/3 , /*CellJob*//*tt2a*/cell_determ/*nvar no diffraction possible here*//*CellVar*/[tcid], dvdx , dvdy , dvdz , gamma , x , y , z , hourgam0 , hourgam1 , hourgam2 , hourgam3 , hourgam4 , hourgam5 , hourgam6 , hourgam7 /*ARGS*//*got_args*/) ;
		/*!function_call_arguments*/{
		const Real volume13 /*'='->!isLeft*/=rcbrt ( /*CellJob*//*tt2a*/cell_determ/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		const Real coefficient /*'='->!isLeft*/=opDiv ( opMul ( opMul ( opMul ( - 0.01 , hourg ) , /*CellJob*//*tt2a*/cell_sound_speed/*nvar no diffraction possible here*//*CellVar*/[tcid]) , /*CellJob*//*tt2a*/cell_elemMass/*nvar no diffraction possible here*//*CellVar*/[tcid]) , volume13 ) ;
		/* DiffractingREADY *//*JOB_CALL*//*got_call*//*isNablaFunction*/calcElemFBHourglassForce ( /*function_call_arguments*/xd , yd , zd , hourgam0 , hourgam1 , hourgam2 , hourgam3 , hourgam4 , hourgam5 , hourgam6 , hourgam7 , coefficient , hgfx , hgfy , hgfz /*ARGS*//*got_args*/) ;
		/*!function_call_arguments*/}/*chsf n*/for(int n=0;n<8;++n){
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/node_nForcex/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/+=hgfx [n] ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/node_nForcey/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/+=hgfy [n] ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/node_nForcez/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/+=hgfz [n] ;
		}/*FOREACH_END*/}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * calcAccelerationForNodes job
// ********************************************************
__global__ void calcAccelerationForNodes(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		real *node_nForcex,
		real *node_nForcey,
		real *node_nForcez,
		real *node_nodalMass,
		real *node_nAccelerationx,
		real *node_nAccelerationy,
		real *node_nAccelerationz){// du job
	/*cudaHookPrefixEnumerate*//*itm=n*/
	CUDA_INI_NODE_THREAD(tnid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		/* DiffractingREADY *//*isLeft*//*NodeJob*//*tt2a*/node_nAccelerationx/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]/*'='->!isLeft*/=opDiv ( /*NodeJob*//*tt2a*/node_nForcex/*nvar no diffraction possible here*//*NodeVar !20*/[tnid], /*NodeJob*//*tt2a*/node_nodalMass/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]) ;
		/* DiffractingREADY *//*isLeft*//*NodeJob*//*tt2a*/node_nAccelerationy/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]/*'='->!isLeft*/=opDiv ( /*NodeJob*//*tt2a*/node_nForcey/*nvar no diffraction possible here*//*NodeVar !20*/[tnid], /*NodeJob*//*tt2a*/node_nodalMass/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]) ;
		/* DiffractingREADY *//*isLeft*//*NodeJob*//*tt2a*/node_nAccelerationz/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]/*'='->!isLeft*/=opDiv ( /*NodeJob*//*tt2a*/node_nForcez/*nvar no diffraction possible here*//*NodeVar !20*/[tnid], /*NodeJob*//*tt2a*/node_nodalMass/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]) ;
		}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * applyAccelerationBoundaryConditionsForNodes job
// ********************************************************
__global__ void applyAccelerationBoundaryConditionsForNodes(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		real *node_nAccelerationx,
		real *node_nAccelerationy,
		real *node_nAccelerationz){// du job
	/*cudaHookPrefixEnumerate*//*itm=n*/
	CUDA_INI_NODE_THREAD(tnid);
	#warning Should be OUTER
	FOR_EACH_NODE_WARP(n){// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		const Real maxBoundaryX /*'='->!isLeft*/=opMul ( X_EDGE_TICK , X_EDGE_ELEMS ) ;
		const Real maxBoundaryY /*'='->!isLeft*/=opMul ( Y_EDGE_TICK , Y_EDGE_ELEMS ) ;
		const Real maxBoundaryZ /*'='->!isLeft*/=opMul ( Z_EDGE_TICK , Z_EDGE_ELEMS ) ;
		/* DiffractingREADY *//*isLeft*//*NodeJob*//*tt2a*/node_nAccelerationx/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]/*'='->!isLeft*/=opTernary ( ( /*NodeJob*//*tt2a*/node_coordx/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]==  0.0  ) ,  0.0  , /*NodeJob*//*tt2a*/node_nAccelerationx/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]) ;
		/* DiffractingREADY *//*isLeft*//*NodeJob*//*tt2a*/node_nAccelerationy/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]/*'='->!isLeft*/=opTernary ( ( /*NodeJob*//*tt2a*/node_coordy/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]==  0.0  ) ,  0.0  , /*NodeJob*//*tt2a*/node_nAccelerationy/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]) ;
		/* DiffractingREADY *//*isLeft*//*NodeJob*//*tt2a*/node_nAccelerationz/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]/*'='->!isLeft*/=opTernary ( ( /*NodeJob*//*tt2a*/node_coordz/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]==  0.0  ) ,  0.0  , /*NodeJob*//*tt2a*/node_nAccelerationz/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]) ;
		/* DiffractingREADY *//*isLeft*//*NodeJob*//*tt2a*/node_nAccelerationx/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]/*'='->!isLeft*/=opTernary ( ( /*NodeJob*//*tt2a*/node_coordx/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]== maxBoundaryX ) ,  0.0  , /*NodeJob*//*tt2a*/node_nAccelerationx/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]) ;
		/* DiffractingREADY *//*isLeft*//*NodeJob*//*tt2a*/node_nAccelerationy/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]/*'='->!isLeft*/=opTernary ( ( /*NodeJob*//*tt2a*/node_coordy/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]== maxBoundaryY ) ,  0.0  , /*NodeJob*//*tt2a*/node_nAccelerationy/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]) ;
		/* DiffractingREADY *//*isLeft*//*NodeJob*//*tt2a*/node_nAccelerationz/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]/*'='->!isLeft*/=opTernary ( ( /*NodeJob*//*tt2a*/node_coordz/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]== maxBoundaryZ ) ,  0.0  , /*NodeJob*//*tt2a*/node_nAccelerationz/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]) ;
		}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * calcVelocityForNodes job
// ********************************************************
__global__ void calcVelocityForNodes(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		real *node_nAccelerationx,
		real *node_nAccelerationy,
		real *node_nAccelerationz,
		real *node_nVelocityx,
		real *node_nVelocityy,
		real *node_nVelocityz){// du job
	/*cudaHookPrefixEnumerate*//*itm=n*/
	CUDA_INI_NODE_THREAD(tnid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		const Real velocityx /*'='->!isLeft*/=opAdd ( /*NodeJob*//*tt2a*/node_nVelocityx/*nvar no diffraction possible here*//*NodeVar !20*/[tnid], opMul ( /*NodeJob*//*tt2a*/node_nAccelerationx/*nvar no diffraction possible here*//*NodeVar !20*/[tnid], /*NodeJob*//*GlobalVar*/*global_deltat/*turnBracketsToParentheses@true*//*n g*/) ) ;
		const Real velocityy /*'='->!isLeft*/=opAdd ( /*NodeJob*//*tt2a*/node_nVelocityy/*nvar no diffraction possible here*//*NodeVar !20*/[tnid], opMul ( /*NodeJob*//*tt2a*/node_nAccelerationy/*nvar no diffraction possible here*//*NodeVar !20*/[tnid], /*NodeJob*//*GlobalVar*/*global_deltat/*turnBracketsToParentheses@true*//*n g*/) ) ;
		const Real velocityz /*'='->!isLeft*/=opAdd ( /*NodeJob*//*tt2a*/node_nVelocityz/*nvar no diffraction possible here*//*NodeVar !20*/[tnid], opMul ( /*NodeJob*//*tt2a*/node_nAccelerationz/*nvar no diffraction possible here*//*NodeVar !20*/[tnid], /*NodeJob*//*GlobalVar*/*global_deltat/*turnBracketsToParentheses@true*//*n g*/) ) ;
		/* DiffractingREADY *//*isLeft*//*NodeJob*//*tt2a*/node_nVelocityx/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]/*'='->!isLeft*/=opTernary ( ( /*JOB_CALL*//*got_call*//*has not been found*/norm ( /*function_call_arguments*/velocityx /*ARGS*//*got_args*/) < /*tt2o cuda*/option_u_cut) ,  0.0  , velocityx ) ;
		/*!function_call_arguments*//* DiffractingREADY *//*isLeft*//*NodeJob*//*tt2a*/node_nVelocityy/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]/*'='->!isLeft*/=opTernary ( ( /*JOB_CALL*//*got_call*//*has not been found*/norm ( /*function_call_arguments*/velocityy /*ARGS*//*got_args*/) < /*tt2o cuda*/option_u_cut) ,  0.0  , velocityy ) ;
		/*!function_call_arguments*//* DiffractingREADY *//*isLeft*//*NodeJob*//*tt2a*/node_nVelocityz/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]/*'='->!isLeft*/=opTernary ( ( /*JOB_CALL*//*got_call*//*has not been found*/norm ( /*function_call_arguments*/velocityz /*ARGS*//*got_args*/) < /*tt2o cuda*/option_u_cut) ,  0.0  , velocityz ) ;
		/*!function_call_arguments*/}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * calcPositionForNodes job
// ********************************************************
__global__ void calcPositionForNodes(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		real *node_nVelocityx,
		real *node_nVelocityy,
		real *node_nVelocityz){// du job
	/*cudaHookPrefixEnumerate*//*itm=n*/
	CUDA_INI_NODE_THREAD(tnid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		/* DiffractingREADY *//*isLeft*//*NodeJob*//*tt2a*/node_coordx/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]+=opMul ( /*NodeJob*//*GlobalVar*/*global_deltat/*turnBracketsToParentheses@true*//*n g*/, /*NodeJob*//*tt2a*/node_nVelocityx/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]) ;
		/* DiffractingREADY *//*isLeft*//*NodeJob*//*tt2a*/node_coordy/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]+=opMul ( /*NodeJob*//*GlobalVar*/*global_deltat/*turnBracketsToParentheses@true*//*n g*/, /*NodeJob*//*tt2a*/node_nVelocityy/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]) ;
		/* DiffractingREADY *//*isLeft*//*NodeJob*//*tt2a*/node_coordz/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]+=opMul ( /*NodeJob*//*GlobalVar*/*global_deltat/*turnBracketsToParentheses@true*//*n g*/, /*NodeJob*//*tt2a*/node_nVelocityz/*nvar no diffraction possible here*//*NodeVar !20*/[tnid]) ;
		}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * calcElemVolume job
// ********************************************************
__global__ void calcElemVolume(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_v,
		real *cell_volo,
		real *node_nVelocityx,
		real *node_nVelocityy,
		real *node_nVelocityz,
		real *cell_vnew,
		real *cell_delv,
		real *cell_arealg,
		real *cell_calc_volume,
		real *cell_epx,
		real *cell_epy,
		real *cell_epz){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		Real x_local [8 ];
		Real y_local [8 ];
		Real z_local [8 ];
		/*chsf n*/for(int n=0;n<8;++n){
		/* DiffractingREADY *//*isLeft*/x_local [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_coordx/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		/* DiffractingREADY *//*isLeft*/y_local [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_coordy/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		/* DiffractingREADY *//*isLeft*/z_local [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_coordz/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		}/*FOREACH_END*//* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_calc_volume/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=/*JOB_CALL*//*got_call*//*isNablaFunction*/_calcElemVolume ( /*function_call_arguments*//*postfix_constant@true*/x_local [0 /*postfix_constant_value*/], /*postfix_constant@true*/x_local [1 /*postfix_constant_value*/], /*postfix_constant@true*/x_local [2 /*postfix_constant_value*/], /*postfix_constant@true*/x_local [3 /*postfix_constant_value*/], /*postfix_constant@true*/x_local [4 /*postfix_constant_value*/], /*postfix_constant@true*/x_local [5 /*postfix_constant_value*/], /*postfix_constant@true*/x_local [6 /*postfix_constant_value*/], /*postfix_constant@true*/x_local [7 /*postfix_constant_value*/], /*postfix_constant@true*/y_local [0 /*postfix_constant_value*/], /*postfix_constant@true*/y_local [1 /*postfix_constant_value*/], /*postfix_constant@true*/y_local [2 /*postfix_constant_value*/], /*postfix_constant@true*/y_local [3 /*postfix_constant_value*/], /*postfix_constant@true*/y_local [4 /*postfix_constant_value*/], /*postfix_constant@true*/y_local [5 /*postfix_constant_value*/], /*postfix_constant@true*/y_local [6 /*postfix_constant_value*/], /*postfix_constant@true*/y_local [7 /*postfix_constant_value*/], /*postfix_constant@true*/z_local [0 /*postfix_constant_value*/], /*postfix_constant@true*/z_local [1 /*postfix_constant_value*/], /*postfix_constant@true*/z_local [2 /*postfix_constant_value*/], /*postfix_constant@true*/z_local [3 /*postfix_constant_value*/], /*postfix_constant@true*/z_local [4 /*postfix_constant_value*/], /*postfix_constant@true*/z_local [5 /*postfix_constant_value*/], /*postfix_constant@true*/z_local [6 /*postfix_constant_value*/], /*postfix_constant@true*/z_local [7 /*postfix_constant_value*/]/*ARGS*//*got_args*/) ;
		/*!function_call_arguments*/{
		const Real volume /*'='->!isLeft*/=/*CellJob*//*tt2a*/cell_calc_volume/*nvar no diffraction possible here*//*CellVar*/[tcid];
		const Real relativeVolume /*'='->!isLeft*/=opDiv ( volume , /*CellJob*//*tt2a*/cell_volo/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_vnew/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=relativeVolume ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_delv/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opSub ( relativeVolume , /*CellJob*//*tt2a*/cell_v/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_arealg/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=/*JOB_CALL*//*got_call*//*isNablaFunction*/calcElemCharacteristicLength ( /*function_call_arguments*/x_local , y_local , z_local , volume /*ARGS*//*got_args*/) ;
		/*!function_call_arguments*/}{
		Real DetJ /*'='->!isLeft*/= 0.0  ;
		Real D [6 ];
		Real B [3 ][8 ];
		const Real dt2 /*'='->!isLeft*/=opMul ( 0.5 , /*CellJob*//*GlobalVar*/*global_deltat) ;
		Real xd_local [8 ];
		Real yd_local [8 ];
		Real zd_local [8 ];
		/*chsf n*/for(int n=0;n<8;++n){
		/* DiffractingREADY *//*isLeft*/xd_local [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_nVelocityx/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		/* DiffractingREADY *//*isLeft*/yd_local [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_nVelocityy/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		/* DiffractingREADY *//*isLeft*/zd_local [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_nVelocityz/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		}/*FOREACH_END*//*chsf n*/for(int n=0;n<8;++n){
		/* DiffractingREADY *//*isLeft*/x_local [n] -=opMul ( dt2 , xd_local [n] ) ;
		/* DiffractingREADY *//*isLeft*/y_local [n] -=opMul ( dt2 , yd_local [n] ) ;
		/* DiffractingREADY *//*isLeft*/z_local [n] -=opMul ( dt2 , zd_local [n] ) ;
		}/*FOREACH_END*//* DiffractingREADY *//*JOB_CALL*//*got_call*//*isNablaFunction*/calcElemShapeFunctionDerivatives ( /*function_call_arguments*/x_local , y_local , z_local , /*postfix_constant@true*/B [0 /*postfix_constant_value*/], /*postfix_constant@true*/B [1 /*postfix_constant_value*/], /*postfix_constant@true*/B [2 /*postfix_constant_value*/], /*adrs*/&( DetJ ) /*ARGS*//*got_args*/) ;
		/*!function_call_arguments*//* DiffractingREADY *//*JOB_CALL*//*got_call*//*isNablaFunction*/CalcElemVelocityGradient ( /*function_call_arguments*/xd_local , yd_local , zd_local , B , DetJ , D /*ARGS*//*got_args*/) ;
		/*!function_call_arguments*//* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_epx/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=/*postfix_constant@true*/D [0 /*postfix_constant_value*/];
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_epy/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=/*postfix_constant@true*/D [1 /*postfix_constant_value*/];
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_epz/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=/*postfix_constant@true*/D [2 /*postfix_constant_value*/];
		}}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * calcLagrangeElements job
// ********************************************************
__global__ void calcLagrangeElements(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_vnew,
		real *cell_epx,
		real *cell_epy,
		real *cell_epz,
		real *cell_vdov){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_vdov/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opAdd ( opAdd ( /*CellJob*//*tt2a*/cell_epx/*nvar no diffraction possible here*//*CellVar*/[tcid], /*CellJob*//*tt2a*/cell_epy/*nvar no diffraction possible here*//*CellVar*/[tcid]) , /*CellJob*//*tt2a*/cell_epz/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_epx/*nvar no diffraction possible here*//*CellVar*/[tcid]-=opMul ( (1./3.) , /*CellJob*//*tt2a*/cell_vdov/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_epy/*nvar no diffraction possible here*//*CellVar*/[tcid]-=opMul ( (1./3.) , /*CellJob*//*tt2a*/cell_vdov/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_epz/*nvar no diffraction possible here*//*CellVar*/[tcid]-=opMul ( (1./3.) , /*CellJob*//*tt2a*/cell_vdov/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * calcMonotonicQGradientsForElems job
// ********************************************************
__global__ void calcMonotonicQGradientsForElems(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_volo,
		real *cell_vnew,
		real *node_nVelocityx,
		real *node_nVelocityy,
		real *node_nVelocityz,
		real *cell_delx_xi,
		real *cell_delv_xi,
		real *cell_delx_eta,
		real *cell_delv_eta,
		real *cell_delx_zeta,
		real *cell_delv_zeta){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		const Real ptiny /*'='->!isLeft*/= 1.e-36  ;
		Real x [8 ];
		Real y [8 ];
		Real z [8 ];
		Real xd [8 ];
		Real yd [8 ];
		Real zd [8 ];
		/*chsf n*/for(int n=0;n<8;++n){
		/* DiffractingREADY *//*isLeft*/x [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_coordx/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		/* DiffractingREADY *//*isLeft*/y [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_coordy/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		/* DiffractingREADY *//*isLeft*/z [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_coordz/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		}/*FOREACH_END*//*chsf n*/for(int n=0;n<8;++n){
		/* DiffractingREADY *//*isLeft*/xd [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_nVelocityx/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		/* DiffractingREADY *//*isLeft*/yd [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_nVelocityy/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		/* DiffractingREADY *//*isLeft*/zd [n] /*'='->!isLeft*/=/*CellJob*//*tt2a*/node_nVelocityz/*nvar no diffraction possible here*//*n*/[cell_node[tcid+n*NABLA_NB_CELLS]]/*turnBracketsToParentheses@true*//*c n*/;
		}/*FOREACH_END*/{
		const Real vol /*'='->!isLeft*/=opMul ( /*CellJob*//*tt2a*/cell_volo/*nvar no diffraction possible here*//*CellVar*/[tcid], /*CellJob*//*tt2a*/cell_vnew/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		const Real nrm /*'='->!isLeft*/=opDiv (  1.0  , ( opAdd ( vol , ptiny ) ) ) ;
		const Real dxj /*'='->!isLeft*/=opMul ( - 0.25 , ( opSub ( ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/x [0 /*postfix_constant_value*/], /*postfix_constant@true*/x [1 /*postfix_constant_value*/]) , /*postfix_constant@true*/x [5 /*postfix_constant_value*/]) , /*postfix_constant@true*/x [4 /*postfix_constant_value*/]) ) , ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/x [3 /*postfix_constant_value*/], /*postfix_constant@true*/x [2 /*postfix_constant_value*/]) , /*postfix_constant@true*/x [6 /*postfix_constant_value*/]) , /*postfix_constant@true*/x [7 /*postfix_constant_value*/]) ) ) ) ) ;
		const Real dyj /*'='->!isLeft*/=opMul ( - 0.25 , ( opSub ( ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/y [0 /*postfix_constant_value*/], /*postfix_constant@true*/y [1 /*postfix_constant_value*/]) , /*postfix_constant@true*/y [5 /*postfix_constant_value*/]) , /*postfix_constant@true*/y [4 /*postfix_constant_value*/]) ) , ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/y [3 /*postfix_constant_value*/], /*postfix_constant@true*/y [2 /*postfix_constant_value*/]) , /*postfix_constant@true*/y [6 /*postfix_constant_value*/]) , /*postfix_constant@true*/y [7 /*postfix_constant_value*/]) ) ) ) ) ;
		const Real dzj /*'='->!isLeft*/=opMul ( - 0.25 , ( opSub ( ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/z [0 /*postfix_constant_value*/], /*postfix_constant@true*/z [1 /*postfix_constant_value*/]) , /*postfix_constant@true*/z [5 /*postfix_constant_value*/]) , /*postfix_constant@true*/z [4 /*postfix_constant_value*/]) ) , ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/z [3 /*postfix_constant_value*/], /*postfix_constant@true*/z [2 /*postfix_constant_value*/]) , /*postfix_constant@true*/z [6 /*postfix_constant_value*/]) , /*postfix_constant@true*/z [7 /*postfix_constant_value*/]) ) ) ) ) ;
		const Real dxi /*'='->!isLeft*/=opMul ( 0.25 , ( opSub ( ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/x [1 /*postfix_constant_value*/], /*postfix_constant@true*/x [2 /*postfix_constant_value*/]) , /*postfix_constant@true*/x [6 /*postfix_constant_value*/]) , /*postfix_constant@true*/x [5 /*postfix_constant_value*/]) ) , ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/x [0 /*postfix_constant_value*/], /*postfix_constant@true*/x [3 /*postfix_constant_value*/]) , /*postfix_constant@true*/x [7 /*postfix_constant_value*/]) , /*postfix_constant@true*/x [4 /*postfix_constant_value*/]) ) ) ) ) ;
		const Real dyi /*'='->!isLeft*/=opMul ( 0.25 , ( opSub ( ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/y [1 /*postfix_constant_value*/], /*postfix_constant@true*/y [2 /*postfix_constant_value*/]) , /*postfix_constant@true*/y [6 /*postfix_constant_value*/]) , /*postfix_constant@true*/y [5 /*postfix_constant_value*/]) ) , ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/y [0 /*postfix_constant_value*/], /*postfix_constant@true*/y [3 /*postfix_constant_value*/]) , /*postfix_constant@true*/y [7 /*postfix_constant_value*/]) , /*postfix_constant@true*/y [4 /*postfix_constant_value*/]) ) ) ) ) ;
		const Real dzi /*'='->!isLeft*/=opMul ( 0.25 , ( opSub ( ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/z [1 /*postfix_constant_value*/], /*postfix_constant@true*/z [2 /*postfix_constant_value*/]) , /*postfix_constant@true*/z [6 /*postfix_constant_value*/]) , /*postfix_constant@true*/z [5 /*postfix_constant_value*/]) ) , ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/z [0 /*postfix_constant_value*/], /*postfix_constant@true*/z [3 /*postfix_constant_value*/]) , /*postfix_constant@true*/z [7 /*postfix_constant_value*/]) , /*postfix_constant@true*/z [4 /*postfix_constant_value*/]) ) ) ) ) ;
		const Real dxk /*'='->!isLeft*/=opMul ( 0.25 , ( opSub ( ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/x [4 /*postfix_constant_value*/], /*postfix_constant@true*/x [5 /*postfix_constant_value*/]) , /*postfix_constant@true*/x [6 /*postfix_constant_value*/]) , /*postfix_constant@true*/x [7 /*postfix_constant_value*/]) ) , ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/x [0 /*postfix_constant_value*/], /*postfix_constant@true*/x [1 /*postfix_constant_value*/]) , /*postfix_constant@true*/x [2 /*postfix_constant_value*/]) , /*postfix_constant@true*/x [3 /*postfix_constant_value*/]) ) ) ) ) ;
		const Real dyk /*'='->!isLeft*/=opMul ( 0.25 , ( opSub ( ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/y [4 /*postfix_constant_value*/], /*postfix_constant@true*/y [5 /*postfix_constant_value*/]) , /*postfix_constant@true*/y [6 /*postfix_constant_value*/]) , /*postfix_constant@true*/y [7 /*postfix_constant_value*/]) ) , ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/y [0 /*postfix_constant_value*/], /*postfix_constant@true*/y [1 /*postfix_constant_value*/]) , /*postfix_constant@true*/y [2 /*postfix_constant_value*/]) , /*postfix_constant@true*/y [3 /*postfix_constant_value*/]) ) ) ) ) ;
		const Real dzk /*'='->!isLeft*/=opMul ( 0.25 , ( opSub ( ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/z [4 /*postfix_constant_value*/], /*postfix_constant@true*/z [5 /*postfix_constant_value*/]) , /*postfix_constant@true*/z [6 /*postfix_constant_value*/]) , /*postfix_constant@true*/z [7 /*postfix_constant_value*/]) ) , ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/z [0 /*postfix_constant_value*/], /*postfix_constant@true*/z [1 /*postfix_constant_value*/]) , /*postfix_constant@true*/z [2 /*postfix_constant_value*/]) , /*postfix_constant@true*/z [3 /*postfix_constant_value*/]) ) ) ) ) ;
		{
		const Real a_zetax /*'='->!isLeft*/=opSub ( opMul ( dyi , dzj ) , opMul ( dzi , dyj ) ) ;
		const Real a_zetay /*'='->!isLeft*/=opSub ( opMul ( dzi , dxj ) , opMul ( dxi , dzj ) ) ;
		const Real a_zetaz /*'='->!isLeft*/=opSub ( opMul ( dxi , dyj ) , opMul ( dyi , dxj ) ) ;
		const Real dv_zetax /*'='->!isLeft*/=opMul ( 0.25 , ( opSub ( ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/xd [4 /*postfix_constant_value*/], /*postfix_constant@true*/xd [5 /*postfix_constant_value*/]) , /*postfix_constant@true*/xd [6 /*postfix_constant_value*/]) , /*postfix_constant@true*/xd [7 /*postfix_constant_value*/]) ) , ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/xd [0 /*postfix_constant_value*/], /*postfix_constant@true*/xd [1 /*postfix_constant_value*/]) , /*postfix_constant@true*/xd [2 /*postfix_constant_value*/]) , /*postfix_constant@true*/xd [3 /*postfix_constant_value*/]) ) ) ) ) ;
		const Real dv_zetay /*'='->!isLeft*/=opMul ( 0.25 , ( opSub ( ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/yd [4 /*postfix_constant_value*/], /*postfix_constant@true*/yd [5 /*postfix_constant_value*/]) , /*postfix_constant@true*/yd [6 /*postfix_constant_value*/]) , /*postfix_constant@true*/yd [7 /*postfix_constant_value*/]) ) , ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/yd [0 /*postfix_constant_value*/], /*postfix_constant@true*/yd [1 /*postfix_constant_value*/]) , /*postfix_constant@true*/yd [2 /*postfix_constant_value*/]) , /*postfix_constant@true*/yd [3 /*postfix_constant_value*/]) ) ) ) ) ;
		const Real dv_zetaz /*'='->!isLeft*/=opMul ( 0.25 , ( opSub ( ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/zd [4 /*postfix_constant_value*/], /*postfix_constant@true*/zd [5 /*postfix_constant_value*/]) , /*postfix_constant@true*/zd [6 /*postfix_constant_value*/]) , /*postfix_constant@true*/zd [7 /*postfix_constant_value*/]) ) , ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/zd [0 /*postfix_constant_value*/], /*postfix_constant@true*/zd [1 /*postfix_constant_value*/]) , /*postfix_constant@true*/zd [2 /*postfix_constant_value*/]) , /*postfix_constant@true*/zd [3 /*postfix_constant_value*/]) ) ) ) ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_delx_zeta/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opDiv ( vol , rsqrt ( opAdd ( ( opAdd ( opAdd ( opMul ( a_zetax , a_zetax ) , opMul ( a_zetay , a_zetay ) ) , opMul ( a_zetaz , a_zetaz ) ) ) , ptiny ) ) ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_delv_zeta/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opAdd ( opAdd ( opMul ( ( opMul ( a_zetax , nrm ) ) , dv_zetax ) , opMul ( ( opMul ( a_zetay , nrm ) ) , dv_zetay ) ) , opMul ( ( opMul ( a_zetaz , nrm ) ) , dv_zetaz ) ) ;
		}{
		const Real a_xix /*'='->!isLeft*/=opSub ( opMul ( dyj , dzk ) , opMul ( dzj , dyk ) ) ;
		const Real a_xiy /*'='->!isLeft*/=opSub ( opMul ( dzj , dxk ) , opMul ( dxj , dzk ) ) ;
		const Real a_xiz /*'='->!isLeft*/=opSub ( opMul ( dxj , dyk ) , opMul ( dyj , dxk ) ) ;
		const Real dv_xix /*'='->!isLeft*/=opMul ( 0.25 , ( opSub ( ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/xd [1 /*postfix_constant_value*/], /*postfix_constant@true*/xd [2 /*postfix_constant_value*/]) , /*postfix_constant@true*/xd [6 /*postfix_constant_value*/]) , /*postfix_constant@true*/xd [5 /*postfix_constant_value*/]) ) , ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/xd [0 /*postfix_constant_value*/], /*postfix_constant@true*/xd [3 /*postfix_constant_value*/]) , /*postfix_constant@true*/xd [7 /*postfix_constant_value*/]) , /*postfix_constant@true*/xd [4 /*postfix_constant_value*/]) ) ) ) ) ;
		const Real dv_xiy /*'='->!isLeft*/=opMul ( 0.25 , ( opSub ( ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/yd [1 /*postfix_constant_value*/], /*postfix_constant@true*/yd [2 /*postfix_constant_value*/]) , /*postfix_constant@true*/yd [6 /*postfix_constant_value*/]) , /*postfix_constant@true*/yd [5 /*postfix_constant_value*/]) ) , ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/yd [0 /*postfix_constant_value*/], /*postfix_constant@true*/yd [3 /*postfix_constant_value*/]) , /*postfix_constant@true*/yd [7 /*postfix_constant_value*/]) , /*postfix_constant@true*/yd [4 /*postfix_constant_value*/]) ) ) ) ) ;
		const Real dv_xiz /*'='->!isLeft*/=opMul ( 0.25 , ( opSub ( ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/zd [1 /*postfix_constant_value*/], /*postfix_constant@true*/zd [2 /*postfix_constant_value*/]) , /*postfix_constant@true*/zd [6 /*postfix_constant_value*/]) , /*postfix_constant@true*/zd [5 /*postfix_constant_value*/]) ) , ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/zd [0 /*postfix_constant_value*/], /*postfix_constant@true*/zd [3 /*postfix_constant_value*/]) , /*postfix_constant@true*/zd [7 /*postfix_constant_value*/]) , /*postfix_constant@true*/zd [4 /*postfix_constant_value*/]) ) ) ) ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_delx_xi/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opDiv ( vol , rsqrt ( opAdd ( ( opAdd ( opAdd ( opMul ( a_xix , a_xix ) , opMul ( a_xiy , a_xiy ) ) , opMul ( a_xiz , a_xiz ) ) ) , ptiny ) ) ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_delv_xi/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opAdd ( opAdd ( opMul ( ( opMul ( a_xix , nrm ) ) , dv_xix ) , opMul ( ( opMul ( a_xiy , nrm ) ) , dv_xiy ) ) , opMul ( ( opMul ( a_xiz , nrm ) ) , dv_xiz ) ) ;
		}{
		const Real a_etax /*'='->!isLeft*/=opSub ( opMul ( dyk , dzi ) , opMul ( dzk , dyi ) ) ;
		const Real a_etay /*'='->!isLeft*/=opSub ( opMul ( dzk , dxi ) , opMul ( dxk , dzi ) ) ;
		const Real a_etaz /*'='->!isLeft*/=opSub ( opMul ( dxk , dyi ) , opMul ( dyk , dxi ) ) ;
		const Real dv_etax /*'='->!isLeft*/=opMul ( - 0.25 , ( opSub ( ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/xd [0 /*postfix_constant_value*/], /*postfix_constant@true*/xd [1 /*postfix_constant_value*/]) , /*postfix_constant@true*/xd [5 /*postfix_constant_value*/]) , /*postfix_constant@true*/xd [4 /*postfix_constant_value*/]) ) , ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/xd [3 /*postfix_constant_value*/], /*postfix_constant@true*/xd [2 /*postfix_constant_value*/]) , /*postfix_constant@true*/xd [6 /*postfix_constant_value*/]) , /*postfix_constant@true*/xd [7 /*postfix_constant_value*/]) ) ) ) ) ;
		const Real dv_etay /*'='->!isLeft*/=opMul ( - 0.25 , ( opSub ( ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/yd [0 /*postfix_constant_value*/], /*postfix_constant@true*/yd [1 /*postfix_constant_value*/]) , /*postfix_constant@true*/yd [5 /*postfix_constant_value*/]) , /*postfix_constant@true*/yd [4 /*postfix_constant_value*/]) ) , ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/yd [3 /*postfix_constant_value*/], /*postfix_constant@true*/yd [2 /*postfix_constant_value*/]) , /*postfix_constant@true*/yd [6 /*postfix_constant_value*/]) , /*postfix_constant@true*/yd [7 /*postfix_constant_value*/]) ) ) ) ) ;
		const Real dv_etaz /*'='->!isLeft*/=opMul ( - 0.25 , ( opSub ( ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/zd [0 /*postfix_constant_value*/], /*postfix_constant@true*/zd [1 /*postfix_constant_value*/]) , /*postfix_constant@true*/zd [5 /*postfix_constant_value*/]) , /*postfix_constant@true*/zd [4 /*postfix_constant_value*/]) ) , ( opAdd ( opAdd ( opAdd ( /*postfix_constant@true*/zd [3 /*postfix_constant_value*/], /*postfix_constant@true*/zd [2 /*postfix_constant_value*/]) , /*postfix_constant@true*/zd [6 /*postfix_constant_value*/]) , /*postfix_constant@true*/zd [7 /*postfix_constant_value*/]) ) ) ) ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_delx_eta/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opDiv ( vol , rsqrt ( opAdd ( opAdd ( opAdd ( opMul ( a_etax , a_etax ) , opMul ( a_etay , a_etay ) ) , opMul ( a_etaz , a_etaz ) ) , ptiny ) ) ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_delv_eta/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opAdd ( opAdd ( opMul ( ( opMul ( a_etax , nrm ) ) , dv_etax ) , opMul ( ( opMul ( a_etay , nrm ) ) , dv_etay ) ) , opMul ( ( opMul ( a_etaz , nrm ) ) , dv_etaz ) ) ;
		}}}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job/*xyz=xyz*/


// ********************************************************
// * calcMonotonicQForElemsByDirectionX job
// ********************************************************
__device__ inline void calcMonotonicQForElemsByDirectionX(xyz direction ,
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		integer *cell_elemBC,
		real *cell_delv_xi,
		real *cell_phixi){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		// Postfix ENUMERATE with xyz direction
#warning wrongs nextCell prevCell
		int prevCell=tcid-1;
		int nextCell=tcid+1;
/*COMPOUND_JOB_INI:*/{
		const Real monoq_limiter_mult /*'='->!isLeft*/=/*tt2o cuda*/option_monoq_limiter_mult;
		const Real monoq_max_slope /*'='->!isLeft*/=/*tt2o cuda*/option_monoq_max_slope;
		/*INTEGER*/int bcSwitch ;
		Real register delvm /*'='->!isLeft*/= 0.0  ;
		Real register delvp /*'='->!isLeft*/= 0.0  ;
		const Real ptiny /*'='->!isLeft*/= 1.e-36  ;
		const Real nrm /*'='->!isLeft*/=opDiv (  1.  , ( opAdd ( /*CellJob*//*tt2a*/cell_delv_xi/*nvar no diffraction possible here*//*CellVar*/[tcid], ptiny ) ) ) ;
		{
		/* DiffractingREADY *//*isLeft*/bcSwitch /*'='->!isLeft*/=/*CellJob*//*tt2a*/cell_elemBC/*nvar no diffraction possible here*//*CellVar*/[tcid]/*adrs*/&0x003 ;
		/* DiffractingREADY *//*isLeft*/delvm /*'='->!isLeft*/=opTernary ( ( bcSwitch == 0 ) , /*is_system*/cell_delv_xi/*chs PREVCELL*/[prevCell]/*EndOf: is_system*/, delvm ) ;
		/* DiffractingREADY *//*isLeft*/delvm /*'='->!isLeft*/=opTernary ( ( bcSwitch == 0x001 ) , /*CellJob*//*tt2a*/cell_delv_xi/*nvar no diffraction possible here*//*CellVar*/[tcid], delvm ) ;
		/* DiffractingREADY *//*isLeft*/delvm /*'='->!isLeft*/=opTernary ( ( bcSwitch == 0x002 ) ,  0.0  , delvm ) ;
		/* DiffractingREADY *//*isLeft*/delvm /*'='->!isLeft*/=opMul ( delvm , nrm ) ;
		}{
		/* DiffractingREADY *//*isLeft*/bcSwitch /*'='->!isLeft*/=/*CellJob*//*tt2a*/cell_elemBC/*nvar no diffraction possible here*//*CellVar*/[tcid]/*adrs*/&0x00C ;
		/* DiffractingREADY *//*isLeft*/delvp /*'='->!isLeft*/=opTernary ( ( bcSwitch == 0 ) , /*is_system*/cell_delv_xi/*chs NEXTCELL*/[nextCell]/*EndOf: is_system*/, delvp ) ;
		/* DiffractingREADY *//*isLeft*/delvp /*'='->!isLeft*/=opTernary ( ( bcSwitch == 0x004 ) , /*CellJob*//*tt2a*/cell_delv_xi/*nvar no diffraction possible here*//*CellVar*/[tcid], delvp ) ;
		/* DiffractingREADY *//*isLeft*/delvp /*'='->!isLeft*/=opTernary ( ( bcSwitch == 0x008 ) ,  0.0  , delvp ) ;
		/* DiffractingREADY *//*isLeft*/delvp /*'='->!isLeft*/=opMul ( delvp , nrm ) ;
		}{
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_phixi/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opMul ( 0.5 , ( opAdd ( delvm , delvp ) ) ) ;
		/* DiffractingREADY *//*isLeft*/delvm *=monoq_limiter_mult ;
		/* DiffractingREADY *//*isLeft*/delvp *=monoq_limiter_mult ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_phixi/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( delvm < /*CellJob*//*tt2a*/cell_phixi/*nvar no diffraction possible here*//*CellVar*/[tcid]) , delvm , /*CellJob*//*tt2a*/cell_phixi/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_phixi/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( delvp < /*CellJob*//*tt2a*/cell_phixi/*nvar no diffraction possible here*//*CellVar*/[tcid]) , delvp , /*CellJob*//*tt2a*/cell_phixi/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_phixi/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*CellJob*//*tt2a*/cell_phixi/*nvar no diffraction possible here*//*CellVar*/[tcid]<  0.  ) ,  0.0  , /*CellJob*//*tt2a*/cell_phixi/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_phixi/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*CellJob*//*tt2a*/cell_phixi/*nvar no diffraction possible here*//*CellVar*/[tcid]> monoq_max_slope ) , monoq_max_slope , /*CellJob*//*tt2a*/cell_phixi/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		}}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job/*xyz=xyz*/


// ********************************************************
// * calcMonotonicQForElemsByDirectionY job
// ********************************************************
__device__ inline void calcMonotonicQForElemsByDirectionY(xyz direction ,
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		integer *cell_elemBC,
		real *cell_delv_eta,
		real *cell_phieta){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		// Postfix ENUMERATE with xyz direction
#warning wrongs nextCell prevCell
		int prevCell=tcid-1;
		int nextCell=tcid+1;
/*COMPOUND_JOB_INI:*/{
		const Real monoq_limiter_mult /*'='->!isLeft*/=/*tt2o cuda*/option_monoq_limiter_mult;
		const Real monoq_max_slope /*'='->!isLeft*/=/*tt2o cuda*/option_monoq_max_slope;
		/*INTEGER*/int register bcSwitch ;
		Real register delvm /*'='->!isLeft*/= 0.  ;
		Real register delvp /*'='->!isLeft*/= 0.  ;
		const Real ptiny /*'='->!isLeft*/= 1.e-36  ;
		const Real nrm /*'='->!isLeft*/=opDiv (  1.  , ( opAdd ( /*CellJob*//*tt2a*/cell_delv_eta/*nvar no diffraction possible here*//*CellVar*/[tcid], ptiny ) ) ) ;
		{
		/* DiffractingREADY *//*isLeft*/bcSwitch /*'='->!isLeft*/=/*CellJob*//*tt2a*/cell_elemBC/*nvar no diffraction possible here*//*CellVar*/[tcid]/*adrs*/&0x030 ;
		/* DiffractingREADY *//*isLeft*/delvm /*'='->!isLeft*/=opTernary ( ( bcSwitch == 0 ) , /*is_system*/cell_delv_eta/*chs PREVCELL*/[prevCell]/*EndOf: is_system*/, delvm ) ;
		/* DiffractingREADY *//*isLeft*/delvm /*'='->!isLeft*/=opTernary ( ( bcSwitch == 0x010 ) , /*CellJob*//*tt2a*/cell_delv_eta/*nvar no diffraction possible here*//*CellVar*/[tcid], delvm ) ;
		/* DiffractingREADY *//*isLeft*/delvm /*'='->!isLeft*/=opTernary ( ( bcSwitch == 0x020 ) ,  0.0  , delvm ) ;
		/* DiffractingREADY *//*isLeft*/delvm /*'='->!isLeft*/=opMul ( delvm , nrm ) ;
		}{
		/* DiffractingREADY *//*isLeft*/bcSwitch /*'='->!isLeft*/=/*CellJob*//*tt2a*/cell_elemBC/*nvar no diffraction possible here*//*CellVar*/[tcid]/*adrs*/&0x0C0 ;
		/* DiffractingREADY *//*isLeft*/delvp /*'='->!isLeft*/=opTernary ( ( bcSwitch == 0 ) , /*is_system*/cell_delv_eta/*chs NEXTCELL*/[nextCell]/*EndOf: is_system*/, delvp ) ;
		/* DiffractingREADY *//*isLeft*/delvp /*'='->!isLeft*/=opTernary ( ( bcSwitch == 0x040 ) , /*CellJob*//*tt2a*/cell_delv_eta/*nvar no diffraction possible here*//*CellVar*/[tcid], delvp ) ;
		/* DiffractingREADY *//*isLeft*/delvp /*'='->!isLeft*/=opTernary ( ( bcSwitch == 0x080 ) ,  0.0  , delvp ) ;
		/* DiffractingREADY *//*isLeft*/delvp /*'='->!isLeft*/=opMul ( delvp , nrm ) ;
		}/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_phieta/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opMul ( 0.5 , ( opAdd ( delvm , delvp ) ) ) ;
		/* DiffractingREADY *//*isLeft*/delvm *=monoq_limiter_mult ;
		/* DiffractingREADY *//*isLeft*/delvp *=monoq_limiter_mult ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_phieta/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( delvm < /*CellJob*//*tt2a*/cell_phieta/*nvar no diffraction possible here*//*CellVar*/[tcid]) , delvm , /*CellJob*//*tt2a*/cell_phieta/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_phieta/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( delvp < /*CellJob*//*tt2a*/cell_phieta/*nvar no diffraction possible here*//*CellVar*/[tcid]) , delvp , /*CellJob*//*tt2a*/cell_phieta/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_phieta/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*CellJob*//*tt2a*/cell_phieta/*nvar no diffraction possible here*//*CellVar*/[tcid]<  0.0  ) ,  0.0  , /*CellJob*//*tt2a*/cell_phieta/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_phieta/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*CellJob*//*tt2a*/cell_phieta/*nvar no diffraction possible here*//*CellVar*/[tcid]> monoq_max_slope ) , monoq_max_slope , /*CellJob*//*tt2a*/cell_phieta/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job/*xyz=xyz*/


// ********************************************************
// * calcMonotonicQForElemsByDirectionZ job
// ********************************************************
__device__ inline void calcMonotonicQForElemsByDirectionZ(xyz direction ,
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		integer *cell_elemBC,
		real *cell_delv_zeta,
		real *cell_phizeta){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		// Postfix ENUMERATE with xyz direction
#warning wrongs nextCell prevCell
		int prevCell=tcid-1;
		int nextCell=tcid+1;
/*COMPOUND_JOB_INI:*/{
		const Real monoq_limiter_mult /*'='->!isLeft*/=/*tt2o cuda*/option_monoq_limiter_mult;
		const Real monoq_max_slope /*'='->!isLeft*/=/*tt2o cuda*/option_monoq_max_slope;
		/*INTEGER*/int bcSwitch ;
		Real delvm /*'='->!isLeft*/= 0.  ;
		Real delvp /*'='->!isLeft*/= 0.  ;
		const Real ptiny /*'='->!isLeft*/= 1.e-36  ;
		const Real nrm /*'='->!isLeft*/=opDiv (  1.  , ( opAdd ( /*CellJob*//*tt2a*/cell_delv_zeta/*nvar no diffraction possible here*//*CellVar*/[tcid], ptiny ) ) ) ;
		{
		/* DiffractingREADY *//*isLeft*/bcSwitch /*'='->!isLeft*/=/*CellJob*//*tt2a*/cell_elemBC/*nvar no diffraction possible here*//*CellVar*/[tcid]/*adrs*/&0x300 ;
		/* DiffractingREADY *//*isLeft*/delvm /*'='->!isLeft*/=opTernary ( ( bcSwitch == 0 ) , /*is_system*/cell_delv_zeta/*chs PREVCELL*/[prevCell]/*EndOf: is_system*/, delvm ) ;
		/* DiffractingREADY *//*isLeft*/delvm /*'='->!isLeft*/=opTernary ( ( bcSwitch == 0x100 ) , /*CellJob*//*tt2a*/cell_delv_zeta/*nvar no diffraction possible here*//*CellVar*/[tcid], delvm ) ;
		/* DiffractingREADY *//*isLeft*/delvm /*'='->!isLeft*/=opTernary ( ( bcSwitch == 0x200 ) ,  0.0  , delvm ) ;
		/* DiffractingREADY *//*isLeft*/delvm /*'='->!isLeft*/=opMul ( delvm , nrm ) ;
		}{
		/* DiffractingREADY *//*isLeft*/bcSwitch /*'='->!isLeft*/=/*CellJob*//*tt2a*/cell_elemBC/*nvar no diffraction possible here*//*CellVar*/[tcid]/*adrs*/&0xC00 ;
		/* DiffractingREADY *//*isLeft*/delvp /*'='->!isLeft*/=opTernary ( ( bcSwitch == 0 ) , /*is_system*/cell_delv_zeta/*chs NEXTCELL*/[nextCell]/*EndOf: is_system*/, delvp ) ;
		/* DiffractingREADY *//*isLeft*/delvp /*'='->!isLeft*/=opTernary ( ( bcSwitch == 0x400 ) , /*CellJob*//*tt2a*/cell_delv_zeta/*nvar no diffraction possible here*//*CellVar*/[tcid], delvp ) ;
		/* DiffractingREADY *//*isLeft*/delvp /*'='->!isLeft*/=opTernary ( ( bcSwitch == 0x800 ) ,  0.0  , delvp ) ;
		/* DiffractingREADY *//*isLeft*/delvp /*'='->!isLeft*/=opMul ( delvp , nrm ) ;
		}/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_phizeta/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opMul ( 0.5 , ( opAdd ( delvm , delvp ) ) ) ;
		/* DiffractingREADY *//*isLeft*/delvm *=monoq_limiter_mult ;
		/* DiffractingREADY *//*isLeft*/delvp *=monoq_limiter_mult ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_phizeta/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( delvm < /*CellJob*//*tt2a*/cell_phizeta/*nvar no diffraction possible here*//*CellVar*/[tcid]) , delvm , /*CellJob*//*tt2a*/cell_phizeta/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_phizeta/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( delvp < /*CellJob*//*tt2a*/cell_phizeta/*nvar no diffraction possible here*//*CellVar*/[tcid]) , delvp , /*CellJob*//*tt2a*/cell_phizeta/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_phizeta/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*CellJob*//*tt2a*/cell_phizeta/*nvar no diffraction possible here*//*CellVar*/[tcid]<  0.0  ) ,  0.0  , /*CellJob*//*tt2a*/cell_phizeta/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_phizeta/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*CellJob*//*tt2a*/cell_phizeta/*nvar no diffraction possible here*//*CellVar*/[tcid]> monoq_max_slope ) , monoq_max_slope , /*CellJob*//*tt2a*/cell_phizeta/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job

// ********************************************************
// * calcMonotonicQForElems fct
// ********************************************************
__global__ void calcMonotonicQForElems(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		/*used_called_variable*/integer *cell_elemBC,
		/*used_called_variable*/real *cell_delv_xi,
		/*used_called_variable*/real *cell_phixi,
		/*used_called_variable*/real *cell_delv_eta,
		/*used_called_variable*/real *cell_phieta,
		/*used_called_variable*/real *cell_delv_zeta,
		/*used_called_variable*/real *cell_phizeta){

	/*cudaHookPrefixEnumerate*//*itm= */	CUDA_INI_FUNCTION_THREAD(tid);
	// function cudaHookDumpEnumerate
	// functioncudaHookPostfixEnumerate
/*function_got_call*//*calcMonotonicQForElemsByDirectionX*//*isNablaJob*/calcMonotonicQForElemsByDirectionX(MD_DirX/*ShouldDumpParamsInCuda*/,
							node_coordx,
							node_coordy,
							node_coordz,global_deltat,global_time,global_iteration,global_min_array,global_dtt_courant,global_dtt_hydro,
							cell_node,
							cell_elemBC,
							cell_delv_xi,
							cell_phixi);
	/*function_got_call*//*calcMonotonicQForElemsByDirectionY*//*isNablaJob*/calcMonotonicQForElemsByDirectionY(MD_DirY/*ShouldDumpParamsInCuda*/,
							node_coordx,
							node_coordy,
							node_coordz,global_deltat,global_time,global_iteration,global_min_array,global_dtt_courant,global_dtt_hydro,
							cell_node,
							cell_elemBC,
							cell_delv_eta,
							cell_phieta);
	/*function_got_call*//*calcMonotonicQForElemsByDirectionZ*//*isNablaJob*/calcMonotonicQForElemsByDirectionZ(MD_DirZ/*ShouldDumpParamsInCuda*/,
							node_coordx,
							node_coordy,
							node_coordz,global_deltat,global_time,global_iteration,global_min_array,global_dtt_courant,global_dtt_hydro,
							cell_node,
							cell_elemBC,
							cell_delv_zeta,
							cell_phizeta);
	}



// ********************************************************
// * calcMonotonicQForElemsQQQL job
// ********************************************************
__global__ void calcMonotonicQForElemsQQQL(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_vdov,
		real *cell_elemMass,
		real *cell_volo,
		real *cell_vnew,
		real *cell_delx_xi,
		real *cell_delv_eta,
		real *cell_delx_eta,
		real *cell_delv_zeta,
		real *cell_delx_zeta,
		real *cell_delv_xi,
		real *cell_phixi,
		real *cell_phieta,
		real *cell_phizeta,
		real *cell_qq,
		real *cell_ql){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		const Real qlc_monoq /*'='->!isLeft*/=/*tt2o cuda*/option_qlc_monoq;
		const Real qqc_monoq /*'='->!isLeft*/=/*tt2o cuda*/option_qqc_monoq;
		const Real rho /*'='->!isLeft*/=opDiv ( /*CellJob*//*tt2a*/cell_elemMass/*nvar no diffraction possible here*//*CellVar*/[tcid], ( opMul ( /*CellJob*//*tt2a*/cell_volo/*nvar no diffraction possible here*//*CellVar*/[tcid], /*CellJob*//*tt2a*/cell_vnew/*nvar no diffraction possible here*//*CellVar*/[tcid]) ) ) ;
		const Real delvxxi /*'='->!isLeft*/=opMul ( /*CellJob*//*tt2a*/cell_delv_xi/*nvar no diffraction possible here*//*CellVar*/[tcid], /*CellJob*//*tt2a*/cell_delx_xi/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		const Real delvxeta /*'='->!isLeft*/=opMul ( /*CellJob*//*tt2a*/cell_delv_eta/*nvar no diffraction possible here*//*CellVar*/[tcid], /*CellJob*//*tt2a*/cell_delx_eta/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		const Real delvxzeta /*'='->!isLeft*/=opMul ( /*CellJob*//*tt2a*/cell_delv_zeta/*nvar no diffraction possible here*//*CellVar*/[tcid], /*CellJob*//*tt2a*/cell_delx_zeta/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		const Real delvxxit /*'='->!isLeft*/=opTernary ( ( delvxxi >  0.  ) ,  0.  , delvxxi ) ;
		const Real delvxetat /*'='->!isLeft*/=opTernary ( ( delvxeta >  0.  ) ,  0.  , delvxeta ) ;
		const Real delvxzetat /*'='->!isLeft*/=opTernary ( ( delvxzeta >  0.  ) ,  0.  , delvxzeta ) ;
		const Real qlin /*'='->!isLeft*/=opMul ( opMul ( - qlc_monoq , rho ) , ( opAdd ( opAdd ( opMul ( delvxxit , ( opSub (  1.0  , /*CellJob*//*tt2a*/cell_phixi/*nvar no diffraction possible here*//*CellVar*/[tcid]) ) ) , opMul ( delvxetat , ( opSub (  1.0  , /*CellJob*//*tt2a*/cell_phieta/*nvar no diffraction possible here*//*CellVar*/[tcid]) ) ) ) , opMul ( delvxzetat , ( opSub (  1.0  , /*CellJob*//*tt2a*/cell_phizeta/*nvar no diffraction possible here*//*CellVar*/[tcid]) ) ) ) ) ) ;
		const Real qquad /*'='->!isLeft*/=opMul ( opMul ( qqc_monoq , rho ) , ( opAdd ( opAdd ( opMul ( opMul ( delvxxit , delvxxit ) , ( opSub (  1.0  , opMul ( /*CellJob*//*tt2a*/cell_phixi/*nvar no diffraction possible here*//*CellVar*/[tcid], /*CellJob*//*tt2a*/cell_phixi/*nvar no diffraction possible here*//*CellVar*/[tcid]) ) ) ) , opMul ( opMul ( delvxetat , delvxetat ) , ( opSub (  1.0  , opMul ( /*CellJob*//*tt2a*/cell_phieta/*nvar no diffraction possible here*//*CellVar*/[tcid], /*CellJob*//*tt2a*/cell_phieta/*nvar no diffraction possible here*//*CellVar*/[tcid]) ) ) ) ) , opMul ( opMul ( delvxzetat , delvxzetat ) , ( opSub (  1.0  , opMul ( /*CellJob*//*tt2a*/cell_phizeta/*nvar no diffraction possible here*//*CellVar*/[tcid], /*CellJob*//*tt2a*/cell_phizeta/*nvar no diffraction possible here*//*CellVar*/[tcid]) ) ) ) ) ) ) ;
		const Real qlint /*'='->!isLeft*/=opTernary ( ( /*CellJob*//*tt2a*/cell_vdov/*nvar no diffraction possible here*//*CellVar*/[tcid]>  0.  ) ,  0.  , qlin ) ;
		const Real qquadt /*'='->!isLeft*/=opTernary ( ( /*CellJob*//*tt2a*/cell_vdov/*nvar no diffraction possible here*//*CellVar*/[tcid]>  0.  ) ,  0.  , qquad ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_qq/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=qquadt ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_ql/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=qlint ;
		}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * applyMaterialPropertiesForElems0 job
// ********************************************************
__global__ void applyMaterialPropertiesForElems0(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_vnew,
		real *cell_vnewc){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_vnewc/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=/*CellJob*//*tt2a*/cell_vnew/*nvar no diffraction possible here*//*CellVar*/[tcid];
		}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * applyMaterialPropertiesForElems1 job
// ********************************************************
__global__ void applyMaterialPropertiesForElems1(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_vnewc){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_vnewc/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*CellJob*//*tt2a*/cell_vnewc/*nvar no diffraction possible here*//*CellVar*/[tcid]< /*tt2o cuda*/option_eosvmin) , /*tt2o cuda*/option_eosvmin, /*CellJob*//*tt2a*/cell_vnewc/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * applyMaterialPropertiesForElems2 job
// ********************************************************
__global__ void applyMaterialPropertiesForElems2(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_vnewc){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_vnewc/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*CellJob*//*tt2a*/cell_vnewc/*nvar no diffraction possible here*//*CellVar*/[tcid]> /*tt2o cuda*/option_eosvmax) , /*tt2o cuda*/option_eosvmax, /*CellJob*//*tt2a*/cell_vnewc/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * applyMaterialPropertiesForElems3 job
// ********************************************************
__global__ void applyMaterialPropertiesForElems3(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_v){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		Real vc /*'='->!isLeft*/=/*CellJob*//*tt2a*/cell_v/*nvar no diffraction possible here*//*CellVar*/[tcid];
		/* DiffractingREADY *//*isLeft*/vc /*'='->!isLeft*/=opTernary ( ( vc < /*tt2o cuda*/option_eosvmin) , /*tt2o cuda*/option_eosvmin, vc ) ;
		/* DiffractingREADY *//*isLeft*/vc /*'='->!isLeft*/=opTernary ( ( vc > /*tt2o cuda*/option_eosvmax) , /*tt2o cuda*/option_eosvmax, vc ) ;
		}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * evalEOSForElems0 job
// ********************************************************
__global__ void evalEOSForElems0(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_e,
		real *cell_delv,
		real *cell_p,
		real *cell_q,
		real *cell_vnewc,
		real *cell_e_old,
		real *cell_delvc,
		real *cell_p_old,
		real *cell_q_old,
		real *cell_compression,
		real *cell_compHalfStep){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_e_old/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=/*CellJob*//*tt2a*/cell_e/*nvar no diffraction possible here*//*CellVar*/[tcid];
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_delvc/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=/*CellJob*//*tt2a*/cell_delv/*nvar no diffraction possible here*//*CellVar*/[tcid];
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_p_old/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=/*CellJob*//*tt2a*/cell_p/*nvar no diffraction possible here*//*CellVar*/[tcid];
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_q_old/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=/*CellJob*//*tt2a*/cell_q/*nvar no diffraction possible here*//*CellVar*/[tcid];
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_compression/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opSub ( ( opDiv (  1.0  , /*CellJob*//*tt2a*/cell_vnewc/*nvar no diffraction possible here*//*CellVar*/[tcid]) ) ,  1.0  ) ;
		{
		const Real vchalf /*'='->!isLeft*/=opSub ( /*CellJob*//*tt2a*/cell_vnewc/*nvar no diffraction possible here*//*CellVar*/[tcid], ( opMul ( 0.5 , /*CellJob*//*tt2a*/cell_delvc/*nvar no diffraction possible here*//*CellVar*/[tcid]) ) ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_compHalfStep/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opSub ( ( opDiv (  1.0  , vchalf ) ) ,  1.0  ) ;
		}}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * evalEOSForElems1 job
// ********************************************************
__global__ void evalEOSForElems1(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_vnewc,
		real *cell_compression,
		real *cell_compHalfStep){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_compHalfStep/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*CellJob*//*tt2a*/cell_vnewc/*nvar no diffraction possible here*//*CellVar*/[tcid]<= /*tt2o cuda*/option_eosvmin) , /*CellJob*//*tt2a*/cell_compression/*nvar no diffraction possible here*//*CellVar*/[tcid], /*CellJob*//*tt2a*/cell_compHalfStep/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * evalEOSForElems6 job
// ********************************************************
__global__ void evalEOSForElems6(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_vnewc,
		real *cell_compHalfStep,
		real *cell_p_old,
		real *cell_compression){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_p_old/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*CellJob*//*tt2a*/cell_vnewc/*nvar no diffraction possible here*//*CellVar*/[tcid]< /*tt2o cuda*/option_eosvmax) , /*CellJob*//*tt2a*/cell_p_old/*nvar no diffraction possible here*//*CellVar*/[tcid],  0.0  ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_compression/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*CellJob*//*tt2a*/cell_vnewc/*nvar no diffraction possible here*//*CellVar*/[tcid]< /*tt2o cuda*/option_eosvmax) , /*CellJob*//*tt2a*/cell_compression/*nvar no diffraction possible here*//*CellVar*/[tcid],  0.0  ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_compHalfStep/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*CellJob*//*tt2a*/cell_vnewc/*nvar no diffraction possible here*//*CellVar*/[tcid]< /*tt2o cuda*/option_eosvmax) , /*CellJob*//*tt2a*/cell_compHalfStep/*nvar no diffraction possible here*//*CellVar*/[tcid],  0.0  ) ;
		}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * evalEOSForElems7 job
// ********************************************************
__global__ void evalEOSForElems7(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_work){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_work/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/= 0.0  ;
		}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * calcEnergyForElems1 job
// ********************************************************
__global__ void calcEnergyForElems1(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_e_old,
		real *cell_delvc,
		real *cell_p_old,
		real *cell_q_old,
		real *cell_work,
		real *cell_e_new){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_e_new/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opAdd ( opSub ( /*CellJob*//*tt2a*/cell_e_old/*nvar no diffraction possible here*//*CellVar*/[tcid], opMul ( opMul ( 0.5 , /*CellJob*//*tt2a*/cell_delvc/*nvar no diffraction possible here*//*CellVar*/[tcid]) , ( opAdd ( /*CellJob*//*tt2a*/cell_p_old/*nvar no diffraction possible here*//*CellVar*/[tcid], /*CellJob*//*tt2a*/cell_q_old/*nvar no diffraction possible here*//*CellVar*/[tcid]) ) ) ) , opMul ( 0.5 , /*CellJob*//*tt2a*/cell_work/*nvar no diffraction possible here*//*CellVar*/[tcid]) ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_e_new/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*CellJob*//*tt2a*/cell_e_new/*nvar no diffraction possible here*//*CellVar*/[tcid]< /*tt2o cuda*/option_emin) , /*tt2o cuda*/option_emin, /*CellJob*//*tt2a*/cell_e_new/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * calcPressureForElemspHalfStepcompHalfStep job
// ********************************************************
__global__ void calcPressureForElemspHalfStepcompHalfStep(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_compHalfStep,
		real *cell_bvc,
		real *cell_e_new,
		real *cell_vnewc,
		real *cell_pHalfStep,
		real *cell_pbvc){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		const Real c1s /*'='->!isLeft*/=opDiv (  2.0  ,  3.0  ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_bvc/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opMul ( c1s , ( opAdd ( /*CellJob*//*tt2a*/cell_compHalfStep/*nvar no diffraction possible here*//*CellVar*/[tcid],  1.0  ) ) ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_pbvc/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=c1s ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_pHalfStep/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opMul ( /*CellJob*//*tt2a*/cell_bvc/*nvar no diffraction possible here*//*CellVar*/[tcid], /*CellJob*//*tt2a*/cell_e_new/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_pHalfStep/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*JOB_CALL*//*got_call*//*has not been found*/rabs ( /*function_call_arguments*//*CellJob*//*tt2a*/cell_pHalfStep/*nvar no diffraction possible here*//*CellVar*/[tcid]/*ARGS*//*got_args*/) < /*tt2o cuda*/option_p_cut) ,  0.0  , /*CellJob*//*tt2a*/cell_pHalfStep/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/*!function_call_arguments*//* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_pHalfStep/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*CellJob*//*tt2a*/cell_vnewc/*nvar no diffraction possible here*//*CellVar*/[tcid]>= /*tt2o cuda*/option_eosvmax) ,  0.0  , /*CellJob*//*tt2a*/cell_pHalfStep/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_pHalfStep/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*CellJob*//*tt2a*/cell_pHalfStep/*nvar no diffraction possible here*//*CellVar*/[tcid]< /*tt2o cuda*/option_pmin) , /*tt2o cuda*/option_pmin, /*CellJob*//*tt2a*/cell_pHalfStep/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * calcEnergyForElems3 job
// ********************************************************
__global__ void calcEnergyForElems3(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_compHalfStep,
		real *cell_delvc,
		real *cell_pbvc,
		real *cell_ql,
		real *cell_qq,
		real *cell_bvc,
		real *cell_pHalfStep,
		real *cell_p_old,
		real *cell_q_old,
		real *cell_q_new,
		real *cell_e_new){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		const Real vhalf /*'='->!isLeft*/=opDiv (  1.0  , ( opAdd (  1.0  , /*CellJob*//*tt2a*/cell_compHalfStep/*nvar no diffraction possible here*//*CellVar*/[tcid]) ) ) ;
		const Real ssc /*'='->!isLeft*/=opDiv ( ( opAdd ( opMul ( /*CellJob*//*tt2a*/cell_pbvc/*nvar no diffraction possible here*//*CellVar*/[tcid], /*CellJob*//*tt2a*/cell_e_new/*nvar no diffraction possible here*//*CellVar*/[tcid]) , opMul ( opMul ( opMul ( vhalf , vhalf ) , /*CellJob*//*tt2a*/cell_bvc/*nvar no diffraction possible here*//*CellVar*/[tcid]) , /*CellJob*//*tt2a*/cell_pHalfStep/*nvar no diffraction possible here*//*CellVar*/[tcid]) ) ) , /*tt2o cuda*/option_refdens) ;
		const Real ssct /*'='->!isLeft*/=opTernary ( ( ssc <=  0.0  ) ,  0.333333e-36  , rsqrt ( ssc ) ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_q_new/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*CellJob*//*tt2a*/cell_delvc/*nvar no diffraction possible here*//*CellVar*/[tcid]>  0.  ) ,  0.0  , ( opAdd ( opMul ( ssct , /*CellJob*//*tt2a*/cell_ql/*nvar no diffraction possible here*//*CellVar*/[tcid]) , /*CellJob*//*tt2a*/cell_qq/*nvar no diffraction possible here*//*CellVar*/[tcid]) ) ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_e_new/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opAdd ( /*CellJob*//*tt2a*/cell_e_new/*nvar no diffraction possible here*//*CellVar*/[tcid], opMul ( opMul ( 0.5 , /*CellJob*//*tt2a*/cell_delvc/*nvar no diffraction possible here*//*CellVar*/[tcid]) , ( opSub ( opMul (  3.0  , ( opAdd ( /*CellJob*//*tt2a*/cell_p_old/*nvar no diffraction possible here*//*CellVar*/[tcid], /*CellJob*//*tt2a*/cell_q_old/*nvar no diffraction possible here*//*CellVar*/[tcid]) ) ) , opMul (  4.0  , ( opAdd ( /*CellJob*//*tt2a*/cell_pHalfStep/*nvar no diffraction possible here*//*CellVar*/[tcid], /*CellJob*//*tt2a*/cell_q_new/*nvar no diffraction possible here*//*CellVar*/[tcid]) ) ) ) ) ) ) ;
		}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * calcEnergyForElems4 job
// ********************************************************
__global__ void calcEnergyForElems4(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_work,
		real *cell_e_new){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_e_new/*nvar no diffraction possible here*//*CellVar*/[tcid]+=opMul ( 0.5 , /*CellJob*//*tt2a*/cell_work/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_e_new/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*JOB_CALL*//*got_call*//*has not been found*/rabs ( /*function_call_arguments*//*CellJob*//*tt2a*/cell_e_new/*nvar no diffraction possible here*//*CellVar*/[tcid]/*ARGS*//*got_args*/) < /*tt2o cuda*/option_e_cut) ,  0.0  , /*CellJob*//*tt2a*/cell_e_new/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/*!function_call_arguments*//* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_e_new/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*CellJob*//*tt2a*/cell_e_new/*nvar no diffraction possible here*//*CellVar*/[tcid]< /*tt2o cuda*/option_emin) , /*tt2o cuda*/option_emin, /*CellJob*//*tt2a*/cell_e_new/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job


// ********************************************************
// * calcPressureForElemsPNewCompression job
// ********************************************************
__global__ void calcPressureForElemsPNewCompression(
		Real *node_coordx,
		Real *node_coordy,
		Real *node_coordz,
		Real *global_deltat,
		Real *global_time,
		int *global_iteration,
		Real *global_min_array,
		Real *global_dtt_courant,
		Real *global_dtt_hydro,
		int *cell_node,
		real *cell_compression,
		real *cell_bvc,
		real *cell_e_new,
		real *cell_vnewc,
		real *cell_pbvc,
		real *cell_p_new){// du job
	/*cudaHookPrefixEnumerate*//*itm=c*/
	CUDA_INI_CELL_THREAD(tcid);
	{// de l'ENUMERATE_
		/*COMPOUND_JOB_INI:*/{
		const Real c1s /*'='->!isLeft*/=opDiv (  2.0  ,  3.0  ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_bvc/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opMul ( c1s , ( opAdd ( /*CellJob*//*tt2a*/cell_compression/*nvar no diffraction possible here*//*CellVar*/[tcid],  1.0  ) ) ) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_pbvc/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=c1s ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_p_new/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opMul ( /*CellJob*//*tt2a*/cell_bvc/*nvar no diffraction possible here*//*CellVar*/[tcid], /*CellJob*//*tt2a*/cell_e_new/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_p_new/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*JOB_CALL*//*got_call*//*has not been found*/rabs ( /*function_call_arguments*//*CellJob*//*tt2a*/cell_p_new/*nvar no diffraction possible here*//*CellVar*/[tcid]/*ARGS*//*got_args*/) < /*tt2o cuda*/option_p_cut) ,  0.0  , /*CellJob*//*tt2a*/cell_p_new/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/*!function_call_arguments*//* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_p_new/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*CellJob*//*tt2a*/cell_vnewc/*nvar no diffraction possible here*//*CellVar*/[tcid]>= /*tt2o cuda*/option_eosvmax) ,  0.0  , /*CellJob*//*tt2a*/cell_p_new/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		/* DiffractingREADY *//*isLeft*//*CellJob*//*tt2a*/cell_p_new/*nvar no diffraction possible here*//*CellVar*/[tcid]/*'='->!isLeft*/=opTernary ( ( /*CellJob*//*tt2a*/cell_p_new/*nvar no diffraction possible here*//*CellVar*/[tcid]< /*tt2o cuda*/option_pmin) , /*tt2o cuda*/option_pmin, /*CellJob*//*tt2a*/cell_p_new/*nvar no diffraction possible here*//*CellVar*/[tcid]) ;
		}/*COMPOUND_JOB_END*/}// de l'ENUMERATE
}// du job