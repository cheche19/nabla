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
#include "nabla.h"
#include "nabla.tab.h"


// ****************************************************************************
// * Dump des variables appelées
// ****************************************************************************
void okinaHookDfsForCalls(struct nablaMainStruct *nabla,
                                 nablaJob *fct,
                                 astNode *n,
                                 const char *namespace,
                                 astNode *nParams){
  // Maintenant qu'on a tous les called_variables potentielles, on remplit aussi le hdr
  // On remplit la ligne du hdr
  hprintf(nabla, NULL, "\n%s %s %s%s(",
          nabla->hook->entryPointPrefix(nabla,fct),
          fct->rtntp,
          namespace?"Entity::":"",
          fct->name);
  // On va chercher les paramètres standards pour le hdr
  dumpParameterTypeList(nabla->entity->hdr, nParams);
  hprintf(nabla, NULL, ");");
}


// ****************************************************************************
// * Dump du préfix des points d'entrées: inline ou pas
// ****************************************************************************
char* okinaHookEntryPointPrefix(struct nablaMainStruct *nabla, nablaJob *entry_point){
  //return "";
  return "static inline";
}

void okinaHookIteration(struct nablaMainStruct *nabla){
  nprintf(nabla, "/*ITERATION*/", "okina_iteration()");
}
void okinaHookExit(struct nablaMainStruct *nabla){
  nprintf(nabla, "/*EXIT*/", "exit(0.0)");
}
void okinaHookTime(struct nablaMainStruct *nabla){
  nprintf(nabla, "/*TIME*/", "global_time");
}
void okinaHookFatal(struct nablaMainStruct *nabla){
  nprintf(nabla, NULL, "fatal");
}
void okinaHookAddCallNames(struct nablaMainStruct *nabla,nablaJob *fct,astNode *n){
  nablaJob *foundJob;
  char *callName=n->next->children->children->token;
  nprintf(nabla, "/*function_got_call*/", "/*%s*/",callName);
  fct->parse.function_call_name=NULL;
  if ((foundJob=nablaJobFind(fct->entity->jobs,callName))!=NULL){
    if (foundJob->is_a_function!=true){
      nprintf(nabla, "/*isNablaJob*/", NULL);
      fct->parse.function_call_name=strdup(callName);
    }else{
      nprintf(nabla, "/*isNablaFunction*/", NULL);
    }
  }else{
    nprintf(nabla, "/*has not been found*/", NULL);
  }
}
void okinaHookAddArguments(struct nablaMainStruct *nabla,nablaJob *fct){
  // En Okina, par contre il faut les y mettre
  if (fct->parse.function_call_name!=NULL){
    //nprintf(nabla, "/*ShouldDumpParamsInOkina*/", "/*Arg*/");
    int numParams=1;
    nablaJob *called=nablaJobFind(fct->entity->jobs,fct->parse.function_call_name);
    okinaAddExtraArguments(nabla, called, &numParams);
    if (called->nblParamsNode != NULL)
      okinaDumpNablaArgumentList(nabla,called->nblParamsNode,&numParams);
  }
}

void okinaHookTurnTokenToOption(struct nablaMainStruct *nabla,nablaOption *opt){
  nprintf(nabla, "/*tt2o okina*/", "%s", opt->name);
}



/*****************************************************************************
 * Okina libraries
 *****************************************************************************/
void okinaHookLibraries(astNode * n, nablaEntity *entity){
  fprintf(entity->src, "\n/*lib %s*/",n->children->token);
}



/*****************************************************************************
 * Génération d'un kernel associé à un support
 *****************************************************************************/
void okinaHookJob(nablaMain *nabla, astNode *n){
  nablaJob *job = nablaJobNew(nabla->entity);
  nablaJobAdd(nabla->entity, job);
  nablaJobFill(nabla,job,n,NULL);
  // On teste *ou pas* que le job retourne bien 'void' dans le cas de OKINA
  //if ((strcmp(job->rtntp,"void")!=0) && (job->is_an_entry_point==true))
  //  exit(NABLA_ERROR|fprintf(stderr, "\n[okinaHookJob] Error with return type which is not void\n"));
}

