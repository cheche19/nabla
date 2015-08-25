///////////////////////////////////////////////////////////////////////////////
// NABLA - a Numerical Analysis Based LAnguage                               //
//                                                                           //
// Copyright (C) 2014~2015 CEA/DAM/DIF                                       //
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
#ifndef _NABLA_MIDDLEND_HOOKS_H_
#define _NABLA_MIDDLEND_HOOKS_H_

// Structure des hooks que l'on va utiliser afin de générer pour AVX ou MIC
typedef struct nHookSimdStruct{
  char* (*bits)(void);
  char* (*gather)(nablaJob*,nablaVariable*,enum_phase);
  char* (*scatter)(nablaVariable*);
  char* (*prevCell)(void);
  char* (*nextCell)(void);
  char* (*includes)(void);
} nHookSimd;

// Structure des hooks que l'on va utiliser afin de générer avec ou sans parallel color
typedef struct nHookParallelStruct{
  char* (*sync)(void);
  char* (*spawn)(void);
  char* (*loop)(struct nablaMainStruct*);
  char* (*includes)(void);
} nHookParallel;

// Structure des hooks que l'on va utiliser afin de générer les pragmas
typedef struct nHookPragmaStruct{
  char* (*ivdep)(void);
  char* (*align)(void);
} nHookPragma;

typedef struct nHookHeaderStruct{
  char** forwards;
  nWhatWith* defines;
  nWhatWith* typedefs;
  void (*dump)(struct nablaMainStruct*);  
  void (*open)(struct nablaMainStruct*);  
  void (*enums)(struct nablaMainStruct*);  
  void (*prefix)(struct nablaMainStruct*);  
  void (*include)(struct nablaMainStruct*);  
  void (*postfix)(struct nablaMainStruct*);
} nHookHeader;

// Hooks for Sources
typedef struct nHookSourceStruct{
  void (*open)(struct nablaMainStruct *);  
  void (*include)(struct nablaMainStruct *);  
} nHookSource;

// Hooks for Main
typedef struct nHookMainStruct{
  NABLA_STATUS (*prefix)(struct nablaMainStruct *);  
  NABLA_STATUS (*preInit)(struct nablaMainStruct *);  
  NABLA_STATUS (*varInitKernel)(struct nablaMainStruct *);  
  NABLA_STATUS (*varInitCall)(struct nablaMainStruct *);  
  NABLA_STATUS (*main)(struct nablaMainStruct *);  
  NABLA_STATUS (*postInit)(struct nablaMainStruct *);  
  NABLA_STATUS (*postfix)(struct nablaMainStruct *);  
} nHookMain;

// Mesh Hooks
typedef struct nHookMeshStruct{
  void (*prefix)(struct nablaMainStruct *);  
  void (*core)(struct nablaMainStruct *);  
  void (*postfix)(struct nablaMainStruct *);  
} nHookMesh;

// Variables Hooks
typedef struct nHookVarsStruct{
  void (*init)(struct nablaMainStruct *);  
  void (*prefix)(struct nablaMainStruct *);  
  void (*postfix)(struct nablaMainStruct *);  
} nHookVars;


typedef struct nHookForAllStruct{
  // Prefix à l'ENUMERATE_*
  char* (*prefix)(nablaJob*);  
  // Dump l'ENUMERATE_*
  char* (*dump)(nablaJob*);  
  // Dump la référence à un item au sein d'un ENUMERATE_*
  char* (*item)(nablaJob*,const char, const char, char);
  // Dump l'ENUMERATE_*
  char* (*postfix)(nablaJob*);  
} nHookForAll;

typedef struct nHookTokenStruct{
  // Gestion des différentes actions pour un job
  void (*svvitch)(astNode*, nablaJob*);
  // Transformation de tokens en variables selon l'ENUMERATE_*
  nablaVariable* (*variable)(astNode*, struct nablaMainStruct*, nablaJob*);
  // Hook pour mettre en forme les options
  void (*option)(struct nablaMainStruct*,nablaOption*);
  void (*system)(astNode*, struct nablaMainStruct*, const char, char);
  void (*iteration)(struct nablaMainStruct*);
  void (*exit)(struct nablaMainStruct*);
  void (*time)(struct nablaMainStruct*);
  void (*fatal)(struct nablaMainStruct*);
  void (*turnBracketsToParentheses)(nablaMain*, nablaJob*, nablaVariable*, char);
} nHookToken;

typedef struct nHookGrammarStruct{
  // Hook de génération d'un kernel associé à une fonction
  void (*function)(struct nablaMainStruct*, astNode*);
  // Génération d'un kernel associé à un support
  void (*job)(struct nablaMainStruct*, astNode*);
  // Génération d'un kernel associé à une reduction
  void (*reduction)(struct nablaMainStruct *, astNode *);
  // Should be removed: Hook pour transformer les variables à returner
  bool (*primary_expression_to_return)(struct nablaMainStruct*, nablaJob*, astNode*);
  // Hook returnFromArgument for OKINA and OMP
  void (*returnFromArgument)(struct nablaMainStruct*, nablaJob*);
} nHookGrammar;

typedef struct nHookCallStruct{
  // Hooks pour rajouter au fur et à mesure qu'on les découvre
  // les fonctions appelées et les arguments
  void (*addCallNames)(struct nablaMainStruct*,nablaJob*,astNode*);
  void (*addArguments)(struct nablaMainStruct*,nablaJob*);
  // Hook pour préfixer les points d'entrée (à-la inline, par exemple)
  char* (*entryPointPrefix)(struct nablaMainStruct*,nablaJob*);
  // Hook pour associer aux fonctions appelées les arguments à rajouter
  void (*dfsForCalls)(struct nablaMainStruct*,nablaJob*,astNode*,const char *,astNode *);
  void (*addExtraParameters)(nablaMain*, nablaJob*, int*);
  void (*dumpNablaParameterList)(nablaMain*, nablaJob*, astNode*,int*);
} nHookCall;

// ****************************************************************************
// * Backend HOOKS
// ****************************************************************************
typedef struct nHooksStruct{
  const nHookForAll *forall;
  const nHookToken *token;
  const nHookGrammar *grammar;
  const nHookCall *call;
  const nHookSimd *simd;
  const nHookParallel *parallel;
  const nHookPragma *pragma;
  const nHookHeader *header;
  const nHookSource *source;
  const nHookMesh *mesh;
  const nHookVars *vars;
  const nHookMain *main;
} nHooks;


#endif // _NABLA_MIDDLEND_HOOKS_H_