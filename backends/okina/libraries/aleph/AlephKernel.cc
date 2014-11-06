#include "Aleph.h"
#include "IAlephFactory.h"

// ****************************************************************************
// * AlephKernel utilis� par Kappa o� l'on met le m_sub_domain � NULL
// ****************************************************************************
AlephKernel::AlephKernel(IParallelMng* wpm,
                         Integer size,
                         IAlephFactory* factory,
                         Integer alephUnderlyingSolver,
                         Integer alephNumberOfCores,
                         bool alephOrdering):
  TraceAccessor(wpm->traceMng()),
  m_sub_domain(NULL),
  m_isParallel(wpm->isParallel()),
  m_rank(wpm->commRank()),
  m_size(size),
  m_world_size(wpm->commSize()),
  m_there_are_idles(true),
  m_i_am_an_other(true),
  m_parallel(wpm),
  m_world_parallel(wpm),
  m_configured(false),
  m_factory(factory),
  m_topology(NULL),
  m_ordering(NULL),
  m_indexing(NULL),
  m_aleph_vector_idx(0),
  // Pour l'instant, on met Sloop par d�faut
  m_underlying_solver((alephUnderlyingSolver==0?1:alephUnderlyingSolver)),
  m_reorder(alephOrdering),
  m_solver_index(0),
  m_solver_size(alephNumberOfCores),
  m_solved(false),
  m_has_been_initialized(false),
  m_solver_ranks(0),
  m_sub_parallel_mng_queue(0),
  m_matrix_queue(0),
  m_arguments_queue(0),
  m_results_queue(0)
{ setup(); }


// ****************************************************************************
// * Kernel standard dont la factory est pass� en argument
// * Cela correspond � l'ancienne API utilis�e encore dans certains tests
// ****************************************************************************
AlephKernel::AlephKernel(ITraceMng* tm,
                         ISubDomain* sd,
                         IAlephFactory* factory,
								 Integer alephUnderlyingSolver,
								 Integer alephNumberOfCores,
                         bool alephOrdering):
  TraceAccessor(tm),
  m_sub_domain(sd),
  m_isParallel(sd->parallelMng()->isParallel()),
  m_rank(sd->parallelMng()->commRank()),
  m_size(sd->parallelMng()->commSize()),
  m_world_size(sd->parallelMng()->worldParallelMng()->commSize()),
  m_there_are_idles(m_size!=m_world_size),
  m_i_am_an_other(sd->parallelMng()->worldParallelMng()->commRank()>m_size),
  m_parallel(sd->parallelMng()),
  m_world_parallel(sd->parallelMng()->worldParallelMng()),
  m_configured(false),
  m_factory(factory),
  m_topology(NULL),
  m_ordering(NULL),
  m_indexing(NULL),
  m_aleph_vector_idx(0),
  // Pour l'instant, on met Sloop par d�faut
  m_underlying_solver((alephUnderlyingSolver==0?1:alephUnderlyingSolver)),
  m_reorder(alephOrdering),
  m_solver_index(0),
  m_solver_size(alephNumberOfCores),
  m_solved(false),
  m_has_been_initialized(false),
  m_solver_ranks(0),
  m_sub_parallel_mng_queue(0),
  m_matrix_queue(0),
  m_arguments_queue(0),
  m_results_queue(0)
{ setup(); }


// *****************************************************************************
// * Aleph Kernel minimaliste pour utiliser avec l'indexing
// * C'est ce kernel qui cr��e lui m�me sa factory
// * et qui doit g�rer son initialization.
// * Il a en plus des options underlying_solver et number_of_cores
// *****************************************************************************
AlephKernel::AlephKernel(ISubDomain* sd,
								 Integer alephUnderlyingSolver,
								 Integer alephNumberOfCores):
  TraceAccessor(sd->parallelMng()->traceMng()),
  m_sub_domain(sd),
  m_isParallel(sd->parallelMng()->isParallel()),
  m_rank(sd->parallelMng()->commRank()),
  m_size(sd->parallelMng()->commSize()),
  m_world_size(sd->parallelMng()->worldParallelMng()->commSize()),
  m_there_are_idles(m_size!=m_world_size),
  m_i_am_an_other(sd->parallelMng()->worldParallelMng()->commRank()>m_size),
  m_parallel(sd->parallelMng()),
  m_world_parallel(sd->parallelMng()->worldParallelMng()),
  m_configured(false),
//m_factory(new AlephFactory(sd->application(),sd->parallelMng()->traceMng())),
  m_factory(new AlephFactory(sd->parallelMng()->traceMng())),
  m_topology(new AlephTopology(this)),
  m_ordering(new AlephOrdering(this)),
  m_indexing(new AlephIndexing(this)),
  m_aleph_vector_idx(0),
  m_underlying_solver(alephUnderlyingSolver==0?1:alephUnderlyingSolver),
  m_reorder(false),
  m_solver_index(0),
  m_solver_size(alephNumberOfCores),
  m_solved(false),
  m_has_been_initialized(false),
  m_solver_ranks(0),
  m_sub_parallel_mng_queue(0),
  m_matrix_queue(0),
  m_arguments_queue(0),
  m_results_queue(0){
  debug()<<"\33[1;31m[AlephKernel] New kernel with indexing+init options!\33[0m";
  setup();
}


// *****************************************************************************
// * Setup: configuration g�n�rale
// *****************************************************************************
void AlephKernel::setup(void){
  if (m_sub_domain){
    debug()<<"\33[1;31m[AlephKernel] thisParallelMng's size="<<m_size<<"\33[0m";
    debug()<<"\33[1;31m[AlephKernel] worldParallelMng's size="<<m_world_size<<"\33[0m";
  }else
    debug()<<"\33[1;31m[AlephKernel] I am an additional site #"<< m_rank <<" among "<<m_world_size<<"\33[0m";
  // Solveur utilis� par d�faut
  debug()<<"\33[1;31m[AlephKernel] Aleph underlying solver has been set to "
                  << m_underlying_solver<<"\33[0m";
  // Par d�faut, on utilise tous les coeurs allou�s au calcul pour chaque r�solution
  if (m_solver_size==0){
    m_solver_size=m_world_size;
    debug()<<"\33[1;31m[AlephKernel] Aleph Number of Cores"
           << " now matches world's number of processors: "
           <<m_solver_size<<"\33[0m";
  }
  if (m_solver_size>m_size){
    m_solver_size=m_size;
    debug()<<"\33[1;31m[AlephKernel] Aleph Number of Cores"
           << " exceeds in size, reverting to "<<m_size<<"\33[0m";
  }
  if ((m_size%m_solver_size)!=0)
    throw FatalErrorException("AlephKernel", "Aleph Number of Cores modulo size");
  debug()<<"\33[1;31m[AlephKernel] Each solver takes "
         <<m_solver_size<<" site(s)"<<"\33[0m";
  // S'il y a des 'autres, on les tient au courant de la configuration
  if (m_there_are_idles && !m_i_am_an_other){
    Array<Integer> cfg(0);
    cfg.add(m_underlying_solver);
    cfg.add(m_solver_size);
    cfg.add((m_reorder==true)?1:0);
    cfg.add(m_size);
    debug()<<"\33[1;31m[AlephKernel] Sending to others configuration: "<<cfg<<"\33[0m";
    m_world_parallel->broadcast(cfg,0);//.view(),0);
  }
}


/******************************************************************************
 *****************************************************************************/
AlephKernel::~AlephKernel(void){ 
  debug()<<"\33[1;5;31m[~AlephKernel]"<<"\33[0m";
  //delete m_factory;
  ALEPH_ASSERT((m_topology),("m_topology is NULL")); delete m_topology; m_topology=NULL;
  ALEPH_ASSERT((m_ordering),("m_ordering is NULL")); delete m_ordering; m_ordering=NULL;
  //ALEPH_ASSERT((m_indexing),("m_indexing is NULL")); delete m_indexing; m_indexing=NULL;
  for(Integer i=0,iMax=m_results_queue.size(); i<iMax; ++i){
    debug()<<"\33[1;31m\t[~AlephKernel] results (iters,norms) #"<<i<<"\33[0m";
    ALEPH_ASSERT((m_results_queue.at(i)),("m_results_queue.at(i) is NULL"));
    delete m_results_queue.at(i);
    m_results_queue.setAt(i,NULL); 
  }
  for(Integer i=0,iMax=m_matrix_queue.size(); i<iMax; ++i){
    debug()<<"\33[1;31m\t[~AlephKernel] matrix #"<<i<<"\33[0m";
    ALEPH_ASSERT((m_matrix_queue.at(i)),("m_matrix_queue.at(i) is NULL"));
    delete m_matrix_queue.at(i);
    m_matrix_queue.setAt(i,NULL);
  }
  for(Integer i=0,iMax=m_arguments_queue.size(); i<iMax; ++i){
    debug()<<"\33[1;31m\t[~AlephKernel] arguments #"<<i<<"->m_x_vector\33[0m";
    ALEPH_ASSERT((m_arguments_queue.at(i)->m_x_vector),("m_arguments_queue.at(i)->m_x_vector is NULL"));
    delete m_arguments_queue.at(i)->m_x_vector;
    m_arguments_queue.at(i)->m_x_vector=NULL;
    
    debug()<<"\33[1;31m\t[~AlephKernel] arguments #"<<i<<"->m_b_vector\33[0m";
    ALEPH_ASSERT((m_arguments_queue.at(i)->m_b_vector),("m_arguments_queue.at(i)->m_b_vector is NULL"));
    delete m_arguments_queue.at(i)->m_b_vector;
    m_arguments_queue.at(i)->m_b_vector=NULL;
    
    debug()<<"\33[1;31m\t[~AlephKernel] arguments #"<<i<<"->m_tmp_vector\33[0m";
    ALEPH_ASSERT((m_arguments_queue.at(i)->m_tmp_vector),("m_arguments_queue.at(i)->m_tmp_vector is NULL"));
    delete m_arguments_queue.at(i)->m_tmp_vector;
    m_arguments_queue.at(i)->m_tmp_vector=NULL;
    
    // Hypre ou PETSc ont par exemple une m_topology_implementation � NULL
    /*if (m_arguments_queue.at(i)->m_topology_implementation!=NULL){
      debug()<<"\33[1;31m\t[~AlephKernel] arguments #"<<i<<"->m_topology_implementation\33[0m";
      delete m_arguments_queue.at(i)->m_topology_implementation;
      m_arguments_queue.at(i)->m_topology_implementation=NULL;
      }*/
    // les m_params sont pass�s via le postSolver
    // On laisse le soin � l'appelent de deleter ce m_params
    /*debug()<<"\33[1;31m\t[~AlephKernel] arguments #"<<i<<"->m_params\33[0m";
    ALEPH_ASSERT((m_arguments_queue.at(i)->m_params),("m_arguments_queue.at(i)->m_params is NULL"));
    delete m_arguments_queue.at(i)->m_params;
    m_arguments_queue.at(i)->m_params=NULL;*/
    
    debug()<<"\33[1;31m\t[~AlephKernel] arguments #"<<i<<"\33[0m";
    ALEPH_ASSERT((m_arguments_queue.at(i)),("m_arguments_queue.at(i) is NULL"));
    delete m_arguments_queue.at(i);
    m_arguments_queue.setAt(i,NULL);
  }
  for(Integer i=0,iMax=m_sub_parallel_mng_queue.size(); i<iMax; ++i){
    debug()<<"\33[1;31m\t[~AlephKernel] sub_parallel_mng #"<<i<<", "<<m_sub_parallel_mng_queue.at(i)<<"\33[0m";
    if (m_sub_parallel_mng_queue.at(i)==NULL) continue;
    // PETSc seems not to like this too much
    //delete m_sub_parallel_mng_queue.at(i);
    m_sub_parallel_mng_queue.setAt(i,NULL);
  }
  debug()<<"\33[1;5;31m[~AlephKernel] done"<<"\33[0m";
}


/******************************************************************************
 * d80dee82
*****************************************************************************/
void AlephKernel::initialize(Integer global_nb_row,
                             Integer local_nb_row){
  //Timer::Action ta(subDomain(),"AlephKernel::initialize");
  if (m_there_are_idles && !m_i_am_an_other){
    m_world_parallel->broadcast(Array<unsigned long>(1,0xd80dee82l).view(),0);
    Array<Integer> args(0);
    args.add(global_nb_row);
    args.add(local_nb_row);
    m_world_parallel->broadcast(args.view(),0);
  }
  debug()<<"\33[1;31m[initialize] Geometry set to "<<global_nb_row
        <<" lines, I see "<<local_nb_row<<" of them"<<"\33[0m";
  m_topology=new AlephTopology(traceMng(), this, global_nb_row, local_nb_row);
  m_ordering=new AlephOrdering(this,global_nb_row,local_nb_row,m_reorder);
  debug()<<"\33[1;31m[initialize] done"<<"\33[0m";
  m_has_been_initialized=true;
}


/******************************************************************************
 * 4b97b15d
*****************************************************************************/
void AlephKernel::break_and_return(void){
  if (m_there_are_idles && !m_i_am_an_other)
    m_world_parallel->broadcast(Array<unsigned long>(1,0x4b97b15dl).view(),0);
}


/******************************************************************************
Mod[Floor[
  Table[n, {n, 
     mSolverIndex*mSize, (mSolverIndex + 1)*mSize - 1}]/(mSize/
     mSolverSize)], mSize]
*****************************************************************************/
void AlephKernel::mapranks(Array<Integer> &ranks){ 
  debug()<<"\33[1;31m[mapranks] mapranks starting @ "
         <<m_solver_index*m_size
         <<", m_size="<<m_size
         <<", m_solver_size="<<m_solver_size
         <<", m_world_size="<<m_world_size<<"\33[0m";traceMng()->flush();
  for(int rnk=m_solver_index*m_size;rnk<(m_solver_index+1)*m_size;rnk+=1){
    const int map=(rnk/(m_size/m_solver_size))%m_world_size;
    debug()<<"\33[1;31m[mapranks] map="<<map<<"\33[0m";
    ranks[rnk%m_size]=map;
    debug()<<"\33[1;31m[mapranks] mapped solver #"<<m_solver_index
          <<", core "<<rnk%m_size<<" --> site "<<map<<"\33[0m";
  }
}


/******************************************************************************
 *****************************************************************************/
bool AlephKernel::hitranks(Integer rank, ArrayView<Integer> ranks){
  for(int rnk=ranks.size()-1;rnk>=0;rnk-=1)
    if (ranks[rnk]==rank) return true;
  return false;
}


/******************************************************************************
 *****************************************************************************/
IParallelMng *AlephKernel::createUnderlyingParallelMng(Integer nb_wanted_sites){ 
  debug()<<"\33[1;31m[createUnderlyingParallelMng] nb_wanted_sites="<<nb_wanted_sites<<"\33[0m";
  Array<Integer> kept_ranks(0);
  for(Integer rnk=0; rnk<m_world_size; rnk+=1){
    if (hitranks(rnk,m_solver_ranks[m_solver_index])){
      kept_ranks.push_back(rnk);
      debug()<<"\33[1;31m[createUnderlyingParallelMng] keeping "<<rnk<<"\33[0m";
    }else{
      debug()<<"\33[1;31m[createUnderlyingParallelMng] avoiding "<<rnk<<"\33[0m";
    }
  }
  debug()<<"\33[1;31m[createUnderlyingParallelMng] Now createSubParallelMng of size="
        <<kept_ranks.size()<<"\33[0m";
  IParallelMng *upm=m_world_parallel->createSubParallelMng(kept_ranks.constView());
  if (!upm){
    debug()<<"\33[1;31m[createUnderlyingParallelMng] not in sub-Comm!"<<"\33[0m";
    return NULL;
  }
  debug()<<"\33[1;31m[createUnderlyingParallelMng] done: upm="<<upm<<"\33[0m";
  traceMng()->flush();
  return upm;
}


/******************************************************************************
 * BaseForm[Hash["createSolverMatrix", "CRC32"], 16] = ef162166
 *****************************************************************************/
AlephMatrix* AlephKernel::createSolverMatrix(void){
  if (isInitialized()==false){
    debug()<<"\33[1;31m[createSolverMatrix] has_NOT_been_initialized!\33[0m"<<"\33[0m";
    return new AlephMatrix(this);
  }
    
  if (m_there_are_idles && !m_i_am_an_other)
    m_world_parallel->broadcast(Array<unsigned long>(1,0xef162166l).view(),0);

  debug()<<"\33[1;31m[createSolverMatrix]\33[0m"<<"\33[0m";
  
  m_solved=false;
    
  if (!m_configured){
    debug()<<"\33[1;31m[createSolverMatrix] UN configured, building Underlying Parallel Managers index="
          <<index()<<"\33[0m";
    traceMng()->flush();
    m_solver_ranks.add(Array<Integer>(m_world_size));
    m_solver_ranks[m_solver_index].fill(-1);
    mapranks(m_solver_ranks[m_solver_index]);
    traceMng()->flush();
    IParallelMng* upm=createUnderlyingParallelMng(m_solver_size);
    if (upm){
      debug()<<"\33[1;31m[createSolverMatrix] upm->isParallel()="<<upm->isParallel()<<"\33[0m";
      debug()<<"\33[1;31m[createSolverMatrix] upm->commSize()="<<upm->commSize()<<"\33[0m";
      debug()<<"\33[1;31m[createSolverMatrix] upm->commRank()="<<upm->commRank()<<"\33[0m";
    }else{
      debug()<<"\33[1;31m[createSolverMatrix] upm NULL"<<"\33[0m";
    }
    m_sub_parallel_mng_queue.add(upm);
    debug()<<"\33[1;31m[createSolverMatrix] Queuing new kernel arguments: X, B and Tmp with their topolgy"
           <<"\33[0m";
    // On va chercher la topologie avant toute autres choses afin que la biblioth�que
    // sous-jacente la prenne en compte pour les vecteurs et la matrice � venir
    IAlephTopology *underlying_topology=factory()->GetTopology(this,index(),topology()->nb_row_size());
    // Dans le cas d'une biblioth�que qui poss�de une IAlephTopology
    // On trig le prefix, on fera le postfix apres les solves
    if (underlying_topology!=NULL)
      underlying_topology->backupAndInitialize();
    m_arguments_queue.add(new AlephKernelArguments(traceMng(),
                                                   new AlephVector(this),  // Vecteur X
                                                   new AlephVector(this),  // Vecteur B
                                                   new AlephVector(this),  // Vecteur tmp (pour l'isAlreadySolved)
                                                   underlying_topology));
    // On initialise le vecteur temporaire qui n'est pas vu de l'API
    // Pas besoin de l'assembler, il sert en output puis comme buffer
    debug()<<"\33[1;31m[createSolverMatrix] Creating Tmp vector for this set of arguments"<<"\33[0m";
    m_arguments_queue.at(m_solver_index)->m_tmp_vector->create();
    // On initialise la matrice apres la topologies et les vecteurs
    debug()<<"\33[1;31m[createSolverMatrix] Now queuing the matrix\33[0m";
    m_matrix_queue.add(new AlephMatrix(this));
    debug()<<"\33[1;31m[createSolverMatrix] Now queuing the space for the resolution results\33[0m";
    m_results_queue.add(new AlephKernelResults());
  }else{
    if (getTopologyImplementation(m_solver_index)!=NULL)
      getTopologyImplementation(m_solver_index)->backupAndInitialize();
  }
  debug()<<"\33[1;31m[createSolverMatrix] done!\33[0m";
  traceMng()->flush();
  return m_matrix_queue[m_solver_index];
}


/******************************************************************************
 * WARNING:
 * the 1st call returns the Bth RHS vector,
 * the 2nd call returns the Xth solution vector.
 * c4b28f2
 *****************************************************************************/
AlephVector* AlephKernel::createSolverVector(void){
  if (m_has_been_initialized==false){
    debug()<<"\33[1;31m[createSolverVector] has_NOT_been_initialized!\33[0m";
    return new AlephVector(this);
  }
  if (m_there_are_idles && !m_i_am_an_other)
    m_world_parallel->broadcast(Array<unsigned long>(1,0xc4b28f2l).view(),0);
  m_aleph_vector_idx++;
  if ((m_aleph_vector_idx%2)==0){
	 debug()<<"\33[1;31m[createSolverVector] Get "<<m_solver_index<<"th X vector\33[0m";
	 return m_arguments_queue.at(m_solver_index)->m_x_vector;
  }else{
	 debug()<<"\33[1;31m[createSolverVector] Get "<<m_solver_index<<"th B vector\33[0m";
	 return m_arguments_queue.at(m_solver_index)->m_b_vector;
  }
  traceMng()->flush();
}


/******************************************************************************
 * ba9488be
 *****************************************************************************/
void AlephKernel::postSolver(AlephParams *params,
                             AlephMatrix *fromThisMatrix,
                             AlephVector *fromeThisX,
                             AlephVector *fromThisB){  
  if (!isInitialized()){
    debug()<<"\33[1;31m[postSolver] Trying to post a solver to an uninitialized kernel!\33[0m";
    debug()<<"\33[1;31m[postSolver] Now telling Indexer to do its job!\33[0m";
    indexing()->nowYouCanBuildTheTopology(fromThisMatrix,fromeThisX,fromThisB);
  }

  if (m_there_are_idles && !m_i_am_an_other){
    m_world_parallel->broadcast(Array<unsigned long>(1,0xba9488bel).view(),0);
    Array<Real> real_args(0);
    real_args.add(params->epsilon());
    real_args.add(params->alpha());
    real_args.add(params->minRHSNorm());
    real_args.add(params->DDMCParameterAmgDiagonalThreshold());
    
    Array<int> bool_args(0);
    bool_args.add(params->xoUser());
    bool_args.add(params->checkRealResidue());
    bool_args.add(params->printRealResidue());
    bool_args.add(params->debugInfo());
    bool_args.add(params->convergenceAnalyse());
    bool_args.add(params->stopErrorStrategy());
    bool_args.add(params->writeMatrixToFileErrorStrategy());
    bool_args.add(params->DDMCParameterListingOutput());
    bool_args.add(params->printCpuTimeResolution());
    bool_args.add(params->getKeepSolverStructure());
    bool_args.add(params->getSequentialSolver());

    Array<Integer> int_args(0);
    int_args.add(params->maxIter());
    int_args.add(params->gamma());
    int_args.add((Integer)params->precond());
    int_args.add((Integer)params->method());
    int_args.add((Integer)params->amgCoarseningMethod());
    int_args.add(params->getOutputLevel());
    int_args.add(params->getAmgCycle());
    int_args.add(params->getAmgSolverIter());
    int_args.add(params->getAmgSmootherIter());
    int_args.add((Integer)params->getAmgSmootherOption());
    int_args.add((Integer)params->getAmgCoarseningOption());
    int_args.add((Integer)params->getAmgCoarseSolverOption());
    int_args.add((Integer)params->getCriteriaStop());

    // not broadcasted writeMatrixNameErrorStrategy
    m_world_parallel->broadcast(real_args.view(),0);
    m_world_parallel->broadcast(bool_args.view(),0);
    m_world_parallel->broadcast(int_args.view(),0);
  }

  debug()<<"\33[1;31m[postSolver] Queuing solver "<< m_solver_index<<"\33[0m";
  debug()<<"\33[1;31m[postSolver] Backuping its params @"<<params<<"\33[0m";
  m_arguments_queue.at(m_solver_index)->m_params=params;
  
  // Mis � jour des indices solvers et sites
  debug()<<"\33[1;31m[postSolver] Mis � jour des indices solvers et sites"<<"\33[0m";
  m_solver_index+=1;
  debug()<<"\33[1;31m[postSolver] m_solver_index="<< m_solver_index<<"\33[0m";
  traceMng()->flush();
}


/******************************************************************************
 * Ce sont ces arguments qui doivent �tre remplis
 * bf8d3adf
 *****************************************************************************/
AlephVector* AlephKernel::syncSolver(Integer gid, Integer& nb_iteration, Real* residual_norm){
  if (m_there_are_idles && !m_i_am_an_other){
    m_world_parallel->broadcast(Array<unsigned long>(1,0xbf8d3adfl).view(),0);
    m_world_parallel->broadcast(Array<Integer>(1,gid).view(),0);
  }

  if (!m_solved){
    debug()<<"\33[1;31m[syncSolver] Not solved, launching the work"<<"\33[0m";
    workSolver();
    m_solved=true;
  }
  
  debug()<<"\33[1;31m[syncSolver] Syncing "<< gid<<"\33[0m";
  AlephVector* aleph_vector_x = m_arguments_queue.at(gid)->m_x_vector;
  aleph_vector_x->reassemble_waitAndFill();
  m_matrix_queue.at(gid)->reassemble_waitAndFill(m_results_queue.at(gid)->m_nb_iteration,
                                                 m_results_queue.at(gid)->m_residual_norm);

  debug()<<"\33[1;31m[syncSolver] Finishing "<< gid<<"\33[0m";
  nb_iteration=m_results_queue.at(gid)->m_nb_iteration;
  residual_norm[0]=m_results_queue.at(gid)->m_residual_norm[0];
  residual_norm[1]=m_results_queue.at(gid)->m_residual_norm[1];
  residual_norm[2]=m_results_queue.at(gid)->m_residual_norm[2];
  residual_norm[3]=m_results_queue.at(gid)->m_residual_norm[3];
  
  if (getTopologyImplementation(gid)!=NULL)
    getTopologyImplementation(gid)->restore();

  debug()<<"\33[1;31m[syncSolver] Done "<< gid<<"\33[0m";
  traceMng()->flush();
  return m_arguments_queue.at(gid)->m_x_vector;
}
 

/******************************************************************************
 *****************************************************************************/
void AlephKernel::workSolver(void){
  debug()<<"\33[1;31m[workSolver] Now working"<<"\33[0m";
  for( int gid=0;gid<m_solver_index;++gid){
	 debug()<<"\33[1;31m[workSolver] Waiting for assembling "<< gid<<"\33[0m";
	 AlephVector* aleph_vector_x = m_arguments_queue.at(gid)->m_x_vector;
	 AlephVector* aleph_vector_b = m_arguments_queue.at(gid)->m_b_vector;
	 AlephMatrix* aleph_matrix_A = m_matrix_queue.at(gid);
	 aleph_matrix_A->assemble_waitAndFill();
 	 aleph_vector_b->assemble_waitAndFill();
 	 aleph_vector_x->assemble_waitAndFill();
    traceMng()->flush();
  }
  
  if (!m_configured){
    debug()<<"\33[1;31m[workSolver] NOW CONFIGURED!"<<"\33[0m";
    traceMng()->flush();
    m_configured=true;
  }

  for( int gid=0;gid<m_solver_index;++gid){
	 debug()<<"\33[1;31m[workSolver] Solving "<< gid <<" ?"<<"\33[0m";
    if (getTopologyImplementation(gid)!=NULL)
      getTopologyImplementation(gid)->backupAndInitialize();
	 m_matrix_queue.at(gid)->solveNow(m_arguments_queue.at(gid)->m_x_vector,
                                     m_arguments_queue.at(gid)->m_b_vector,
                                     m_arguments_queue.at(gid)->m_tmp_vector,
                                     m_results_queue.at(gid)->m_nb_iteration,
                                     m_results_queue.at(gid)->m_residual_norm,
                                     m_arguments_queue.at(gid)->m_params);
    // Apr�s le solve, on 'restore' la session
    if (getTopologyImplementation(gid)!=NULL)
      getTopologyImplementation(gid)->restore();
  }
    
  for( int gid=0;gid<m_solver_index;++gid){
	 debug()<<"\33[1;31m[workSolver] Posting re-assembling "<<gid<<"\33[0m";
	 m_arguments_queue.at(gid)->m_x_vector->reassemble();
	 m_matrix_queue.at(gid)->reassemble(m_results_queue.at(gid)->m_nb_iteration,
                                       m_results_queue.at(gid)->m_residual_norm);
  }
  traceMng()->flush();
  // Flush number of pending solvers
  m_solver_index=0;
}

