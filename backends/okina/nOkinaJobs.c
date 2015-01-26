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


/*****************************************************************************
 * Diffraction
 *****************************************************************************/
void okinaHookJobDiffractStatement(nablaMain *nabla, nablaJob *job, astNode **n){
  // On backup les statements qu'on rencontre pour �ventuellement les diffracter (real3 => _x, _y & _z)
  // Et on amorce la diffraction
  if ((*n)->ruleid == rulenameToId("expression_statement")
      && (*n)->children->ruleid == rulenameToId("expression")
      //&& (*n)->children->children->ruleid == rulenameToId("expression")
      //&& job->parse.statementToDiffract==NULL
      //&& job->parse.diffractingXYZ==0
      ){
    //dbg("\n[okinaHookJobDiffractStatement] amorce la diffraction");
//#warning Diffracting is turned OFF
      job->parse.statementToDiffract=NULL;//*n;
      // We're juste READY, not diffracting yet!
      job->parse.diffractingXYZ=0;      
      nprintf(nabla, "/* DiffractingREADY */",NULL);
  }
  
  // On avance la diffraction
  if ((*n)->tokenid == ';'
      && job->parse.diffracting==true
      && job->parse.statementToDiffract!=NULL
      && job->parse.diffractingXYZ>0
      && job->parse.diffractingXYZ<3){
    dbg("\n[okinaHookJobDiffractStatement] avance dans la diffraction");
    job->parse.isDotXYZ=job->parse.diffractingXYZ+=1;
    (*n)=job->parse.statementToDiffract;
    nprintf(nabla, NULL, ";\n\t");
    //nprintf(nabla, "\t/*<REdiffracting>*/", "/*diffractingXYZ=%d*/", job->parse.diffractingXYZ);
  }

  // On flush la diffraction 
  if ((*n)->tokenid == ';' 
      && job->parse.diffracting==true
      && job->parse.statementToDiffract!=NULL
      && job->parse.diffractingXYZ>0
      && job->parse.diffractingXYZ==3){
    dbg("\n[okinaHookJobDiffractStatement] Flush de la diffraction");
    job->parse.diffracting=false;
    job->parse.statementToDiffract=NULL;
    job->parse.isDotXYZ=job->parse.diffractingXYZ=0;
    nprintf(nabla, "/*<end of diffracting>*/",NULL);
  }
  //dbg("\n[okinaHookJobDiffractStatement] return from token %s", (*n)->token?(*n)->token:"Null");
}


/*****************************************************************************
 * Fonction prefix � l'ENUMERATE_*
 *****************************************************************************/
char* okinaHookPrefixEnumerate(nablaJob *job){
  char prefix[NABLA_MAX_FILE_NAME];
  //const nablaMain* nabla=job->entity->main;
              
  if (job->parse.returnFromArgument){
    const char *var=dfsFetchFirst(job->stdParamsNode,rulenameToId("direct_declarator"));
    if (sprintf(prefix,"dbgFuncIn();\n\tfor (int i=0; i<threads;i+=1) %s_per_thread[i] = %s;",var,var)<=0){
      error(!0,0,"Error in okinaHookPrefixEnumerate!");
    }
  }else{
    if (sprintf(prefix,"dbgFuncIn();")<=0)
      error(!0,0,"Error in okinaHookPrefixEnumerate!");
  }
      
  //const register char itm=job->item[0];  // (c)ells|(f)aces|(n)odes|(g)lobal
  //nprintf(job->entity->main, "\n\t/*okinaHookPrefixEnumerate*/", "/*itm=%c*/", itm);
  return strdup(prefix);
}


/*****************************************************************************
 * Fonction produisant l'ENUMERATE_* avec XYZ
 *****************************************************************************/
char* okinaHookDumpEnumerateXYZ(nablaJob *job){
  //char *xyz=job->xyz;// Direction
  //nprintf(job->entity->main, "\n\t/*okinaHookDumpEnumerateXYZ*/", "/*xyz=%s, drctn=%s*/", xyz, job->drctn);
  return "// okinaHookDumpEnumerateXYZ has xyz drctn";
}


// ****************************************************************************
// *
// ****************************************************************************
/*static char * okinaReturnVariableNameForOpenMP(nablaJob *job){
  char str[NABLA_MAX_FILE_NAME];
  if (job->is_a_function) return "";
  if (sprintf(str,"%s_per_thread",
              dfsFetchFirst(job->stdParamsNode,rulenameToId("direct_declarator")))<=0)
    error(!0,0,"Could not patch format!");
  return strdup(str);
  }*/
static char * okinaReturnVariableNameForOpenMPWitoutPerThread(nablaJob *job){
  char str[NABLA_MAX_FILE_NAME];
  if (job->is_a_function) return "";
  if (sprintf(str,"%s",
              dfsFetchFirst(job->stdParamsNode,rulenameToId("direct_declarator")))<=0)
    error(!0,0,"Could not patch format!");
  return strdup(str);
}


/*****************************************************************************
 * Fonction produisant l'ENUMERATE_*
 *****************************************************************************/
static char* okinaSelectEnumerate(nablaJob *job){
  const char *grp=job->scope;   // OWN||ALL
  const char *rgn=job->region;  // INNER, OUTER
  const char itm=job->item[0];  // (c)ells|(f)aces|(n)odes|(g)lobal
  //if (job->xyz!=NULL) return okinaHookDumpEnumerateXYZ(job);
  if (itm=='\0') return "\n";// function okinaHookDumpEnumerate\n";
  if (itm=='c' && grp==NULL && rgn==NULL)     return "FOR_EACH_CELL%s%s(c";
  if (itm=='c' && grp==NULL && rgn[0]=='i')   return "#warning Should be INNER\n\tFOR_EACH_CELL%s%s(c";
  if (itm=='c' && grp==NULL && rgn[0]=='o')   return "//#warning Should be OUTER\n\tFOR_EACH_CELL%s%s(c";
  if (itm=='c' && grp[0]=='o' && rgn==NULL)   return "#warning Should be OWN\n\tFOR_EACH_CELL%s%s(c";
  if (itm=='n' && grp==NULL && rgn==NULL)     return "FOR_EACH_NODE%s%s(n";
  if (itm=='n' && grp==NULL && rgn[0]=='i')   return "#warning Should be INNER\n\tFOR_EACH_NODE%s%s(n";
  if (itm=='n' && grp==NULL && rgn[0]=='o')   return "//#warning Should be OUTER\n\tFOR_EACH_NODE%s%s(n";
  if (itm=='n' && grp[0]=='o' && rgn==NULL)   return "#warning Should be OWN\n\tFOR_EACH_NODE%s%s(n";
  if (itm=='n' && grp[0]=='a' && rgn==NULL)   return "#warning Should be ALL\n\tFOR_EACH_NODE%s%s(n";
  if (itm=='n' && grp[0]=='o' && rgn[0]=='i') return "#warning Should be INNER OWN\n\tFOR_EACH_NODE%s%s(n";
  if (itm=='n' && grp[0]=='o' && rgn[0]=='o') return "#warning Should be OUTER OWN\n\tFOR_EACH_NODE%s%s(n";
  if (itm=='f' && grp==NULL && rgn==NULL)     return "FOR_EACH_FACE%s%s(f";
  if (itm=='f' && grp[0]=='o' && rgn==NULL)   return "#warning Should be OWN\n\tFOR_EACH_FACE%s%s(f";
  if (itm=='f' && grp[0]=='o' && rgn[0]=='o') return "#warning Should be OUTER OWN\n\tFOR_EACH_FACE%s%s(f";
  if (itm=='f' && grp[0]=='o' && rgn[0]=='i') return "#warning Should be INNER OWN\n\tFOR_EACH_FACE%s%s(f";
  if (itm=='e' && grp==NULL && rgn==NULL)     return "FOR_EACH_ENV%s%s(e";
  if (itm=='m' && grp==NULL && rgn==NULL)     return "FOR_EACH_MAT%s%s(m";
  
  error(!0,0,"Could not distinguish ENUMERATE!");
  return NULL;
}
char* okinaHookDumpEnumerate(nablaJob *job){
  const char *forall=strdup(okinaSelectEnumerate(job));
  const char *warping=job->parse.selection_statement_in_compound_statement?"":"_WARP";
  char format[NABLA_MAX_FILE_NAME];
  char str[NABLA_MAX_FILE_NAME];
  dbg("\n\t[okinaHookDumpEnumerate] Preparing:");
  dbg("\n\t[okinaHookDumpEnumerate]\t\tforall=%s",forall);
  dbg("\n\t[okinaHookDumpEnumerate]\t\twarping=%s",warping);

  // On pr�pare le format grace � la partie du forall,
  // on rajoute l'extension suivant si on a une returnVariable
  if (job->parse.returnFromArgument){
    const char *ompOkinaLocal=job->parse.returnFromArgument?"_SHARED":"";
    //const char *ompOkinaReturnVariable=okinaReturnVariableNameForOpenMP(job);
    const char *ompOkinaReturnVariableWitoutPerThread=okinaReturnVariableNameForOpenMPWitoutPerThread(job);
    //const char *ompOkinaLocalVariableComa=",";//job->parse.returnFromArgument?",":"";
    //const char *ompOkinaLocalVariableName=job->parse.returnFromArgument?ompOkinaReturnVariable:"";
    if (sprintf(format,"%s%%s%%s)",forall)<=0) error(!0,0,"Could not patch format!");
    if (sprintf(str,format,    // FOR_EACH_XXX%s%s(
                warping,       // _WARP or not
                ompOkinaLocal, // _SHARED or not
                ",",           //ompOkinaLocalVariableComa,
                ompOkinaReturnVariableWitoutPerThread)<=0) error(!0,0,"Could not patch warping within ENUMERATE!");
  }else{
    dbg("\n\t[okinaHookDumpEnumerate] No returnFromArgument");
    if (sprintf(format,"%s%s",  // FOR_EACH_XXX%s%s(x + ')'
                forall,
                job->is_a_function?"":")")<=0)
      error(!0,0,"Could not patch format!");
    dbg("\n[okinaHookDumpEnumerate] format=%s",format);
    if (sprintf(str,format,
                warping,
                "",
                "")<=0)
      error(!0,0,"Could not patch warping within ENUMERATE!");
  }
  return strdup(str);
}


// ****************************************************************************
// * Filtrage du GATHER
// * Une passe devrait �tre faite � priori afin de d�terminer les contextes
// * d'utilisation: au sein d'un forall, postfixed ou pas, etc.
// * Et non pas que sur leurs d�clarations en in et out
// ****************************************************************************
static char* okinaGather(nablaJob *job){
  int i;
  char gathers[1024];
  nablaVariable *var;
  gathers[0]='\0';
  int nbToGather=0;
  int filteredNbToGather=0;

  // Si l'on a trouv� un 'selection_statement_in_compound_statement'
  // dans le corps du kernel, on d�braye les gathers
  // *ou pas*
  if (job->parse.selection_statement_in_compound_statement){
    //nprintf(job->entity->main,
    //"/*selection_statement_in_compound_statement, nothing to do*/",
    //"/*if=>!okinaGather*/");
    //return "";
  }
  
  // On r�cup�re le nombre de variables potentielles � gatherer
  for(var=job->variables_to_gather_scatter;var!=NULL;var=var->next)
    nbToGather+=1;
  //nprintf(job->entity->main, NULL, "/* nbToGather=%d*/", nbToGather);
  
  // S'il y en a pas, on a rien d'autre � faire
  if (nbToGather==0) return "";

  // On filtre suivant s'il y a des forall
  for(var=job->variables_to_gather_scatter;var!=NULL;var=var->next){
    //nprintf(job->entity->main, NULL, "\n\t\t// okinaGather on %s for variable %s_%s", job->item, var->item, var->name);
    //nprintf(job->entity->main, NULL, "\n\t\t// okinaGather enum_enum=%c", job->parse.enum_enum);
    if (job->parse.enum_enum=='\0') continue;
    filteredNbToGather+=1;
  }
  //nprintf(job->entity->main, NULL, "/*filteredNbToGather=%d*/", filteredNbToGather);

  // S'il reste rien apr�s le filtre, on a rien d'autre � faire
  if (filteredNbToGather==0) return "";
  
  strcat(gathers,job->entity->main->simd->gather(job,var,enum_phase_declaration));
  
  for(i=0,var=job->variables_to_gather_scatter;var!=NULL;var=var->next,i+=1){
    // Si c'est pas le gather de l'ordre de la d�claration, on continue
    if (i!=job->parse.iGather) continue;
    strcat(gathers,job->entity->main->simd->gather(job,var,enum_phase_function_call));
    // On informe la suite que cette variable est en train d'�tre gather�e
    nablaVariable *real_variable=nablaVariableFind(job->entity->main->variables, var->name);
    if (real_variable==NULL)
      error(!0,0,"Could not find real variable from gathered variables!");
    real_variable->is_gathered=true;
  }
  job->parse.iGather+=1;
  return strdup(gathers);
}



// ****************************************************************************
// * Flush de la 'vraie' variable depuis celle d�clar�e en in/out
// ****************************************************************************
static void okinaFlushRealVariable(nablaJob *job, nablaVariable *var){
  // On informe la suite que cette variable est en train d'�tre scatter�e
  nablaVariable *real_variable=nablaVariableFind(job->entity->main->variables, var->name);
  if (real_variable==NULL)
    error(!0,0,"Could not find real variable from scattered variables!");
  real_variable->is_gathered=false;
}


// ****************************************************************************
// * Filtrage du SCATTER
// ****************************************************************************
static char* okinaScatter(nablaJob *job){
  int i;
  char scatters[1024];
  nablaVariable *var;
  scatters[0]='\0';
  int nbToScatter=0;
  int filteredNbToScatter=0;
  
  if (job->parse.selection_statement_in_compound_statement){
    nprintf(job->entity->main, "/*selection_statement_in_compound_statement, nothing to do*/",
            "/*if=>!okinaScatter*/");
    return "";
  }
  
  // On r�cup�re le nombre de variables potentielles � scatterer
  for(var=job->variables_to_gather_scatter;var!=NULL;var=var->next)
    nbToScatter+=1;

  // S'il y en a pas, on a rien d'autre � faire
  if (nbToScatter==0) return "";
  
  for(var=job->variables_to_gather_scatter;var!=NULL;var=var->next){
    //nprintf(job->entity->main, NULL, "\n\t\t// okinaScatter on %s for variable %s_%s", job->item, var->item, var->name);
    //nprintf(job->entity->main, NULL, "\n\t\t// okinaScatter enum_enum=%c", job->parse.enum_enum);
    if (job->parse.enum_enum=='\0') continue;
    filteredNbToScatter+=1;
  }
  //nprintf(job->entity->main, NULL, "/*filteredNbToScatter=%d*/", filteredNbToScatter);

  // S'il reste rien apr�s le filtre, on a rien d'autre � faire
  if (filteredNbToScatter==0) return "";
  
  for(i=0,var=job->variables_to_gather_scatter;var!=NULL;var=var->next,i+=1){
    // Si c'est pas le scatter de l'ordre de la d�claration, on continue
    if (i!=job->parse.iScatter) continue;
    okinaFlushRealVariable(job,var);
    // Pour l'instant, on ne scatter pas les node_coord
    if (strcmp(var->name,"coord")==0) continue;
    // Si c'est le cas d'une variable en 'in', pas besoin de la scaterer
    if (var->inout==enum_in_variable) continue;
    strcat(scatters,job->entity->main->simd->scatter(var));
  }
  job->parse.iScatter+=1;
  return strdup(scatters);
}


/*****************************************************************************
 * Fonction postfix � l'ENUMERATE_*
 *****************************************************************************/
char* okinaHookPostfixEnumerate(nablaJob *job){
  if (job->is_a_function) return "";
  if (job->item[0]=='\0') return "// job okinaHookPostfixEnumerate\n";
  if (job->xyz==NULL) return okinaGather(job);
  if (job->xyz!=NULL) return "// Postfix ENUMERATE with xyz direction\n\
\t\tconst int __attribute__((unused)) max_x = NABLA_NB_CELLS_X_AXIS;\n\
\t\tconst int __attribute__((unused)) max_y = NABLA_NB_CELLS_Y_AXIS;\n\
\t\tconst int __attribute__((unused)) max_z = NABLA_NB_CELLS_Z_AXIS;\n\
\t\tconst int delta_x = NABLA_NB_CELLS_Y_AXIS*NABLA_NB_CELLS_Z_AXIS;\n\
\t\tconst int delta_y = 1;\n\
\t\tconst int delta_z = NABLA_NB_CELLS_Y_AXIS;\n\
\t\tconst int delta = (direction==MD_DirX)?delta_x:(direction==MD_DirY)?delta_y:delta_z;\n\
\t\tconst int __attribute__((unused)) prevCell=delta;\n\
\t\tconst int __attribute__((unused)) nextCell=delta;\n";
  error(!0,0,"Could not switch in okinaHookPostfixEnumerate!");
  return NULL;
}


/***************************************************************************** 
 * Traitement des tokens NABLA ITEMS
 *****************************************************************************/
char* okinaHookItem(nablaJob *j, const char job, const char itm, char enum_enum){
  if (job=='c' && enum_enum=='\0' && itm=='c') return "/*chi-c0c*/c";
  if (job=='c' && enum_enum=='\0' && itm=='n') return "/*chi-c0n*/c->";
  if (job=='c' && enum_enum=='f'  && itm=='n') return "/*chi-cfn*/f->";
  if (job=='c' && enum_enum=='f'  && itm=='c') return "/*chi-cfc*/f->";
  if (job=='n' && enum_enum=='f'  && itm=='n') return "/*chi-nfn*/f->";
  if (job=='n' && enum_enum=='f'  && itm=='c') return "/*chi-nfc*/f->";
  if (job=='n' && enum_enum=='\0' && itm=='n') return "/*chi-n0n*/n";
  if (job=='f' && enum_enum=='\0' && itm=='f') return "/*chi-f0f*/f";
  if (job=='f' && enum_enum=='\0' && itm=='n') return "/*chi-f0n*/f->";
  if (job=='f' && enum_enum=='\0' && itm=='c') return "/*chi-f0c*/f->";
  error(!0,0,"Could not switch in okinaHookItem!");
  return NULL;
}


/*****************************************************************************
 * FORALL token switch
 *****************************************************************************/
static void okinaHookSwitchForall(astNode *n, nablaJob *job){
  // Preliminary pertinence test
  if (n->tokenid != FORALL) return;
  // Now we're allowed to work
  switch(n->next->children->tokenid){
  case(CELL):{
    job->parse.enum_enum='c';
    nprintf(job->entity->main, "/*chsf c*/", "FOR_EACH_NODE_WARP_CELL(c)");
    break;
  }
  case(NODE):{
    job->parse.enum_enum='n';
    nprintf(job->entity->main, "/*chsf n*/", "for(int n=0;n<8;++n)");
    break;
  }
  case(FACE):{
    job->parse.enum_enum='f';
    if (job->item[0]=='c')
      nprintf(job->entity->main, "/*chsf fc*/", "for(cFACE)");
    if (job->item[0]=='n')
      nprintf(job->entity->main, "/*chsf fn*/", "for(nFACE)");
    break;
  }
  }
  // Attention au cas o� on a un @ au lieu d'un statement
  if (n->next->next->tokenid == AT)
    nprintf(job->entity->main, "/* Found AT */", NULL);
  // On skip le 'nabla_item' qui nous a renseign� sur le type de forall
  *n=*n->next->next;
}


/*****************************************************************************
 * Diff�rentes actions pour un job Nabla
 *****************************************************************************/
void okinaHookSwitchToken(astNode *n, nablaJob *job){
  nablaMain *nabla=job->entity->main;
  const char cnfgem=job->item[0];
  
  //if (n->token) nprintf(nabla, NULL, "\n/*token=%s*/",n->token);
  if (n->token)
    dbg("\n\t[okinaHookSwitchToken] token: '%s'?", n->token);
 
  okinaHookSwitchForall(n,job);
  
  switch(n->tokenid){
    
  case (MATERIAL):{
    nprintf(nabla, "/*MATERIAL*/", "/*MATERIAL*/");
    break;
  }

  case (MIN_ASSIGN):{
    job->parse.left_of_assignment_operator=false;
    nprintf(nabla, "/*MIN_ASSIGN*/", "/*MIN_ASSIGN*/=ReduceMinToDouble");
    break;
  }
  case (MAX_ASSIGN):{
    job->parse.left_of_assignment_operator=false;
    nprintf(nabla, "/*MAX_ASSIGN*/", "/*MAX_ASSIGN*/=ReduceMaxToDouble");
    break;
  }

  case(CONST):{
    nprintf(nabla, "/*CONST*/", "%sconst ", job->entity->main->pragma->align());
    break;
  }
  case(ALIGNED):{
    nprintf(nabla, "/*ALIGNED*/", "%s", job->entity->main->pragma->align());
    break;
  }
    
  case(INTEGER):{
    nprintf(nabla, "/*INTEGER*/", "integer ");
    break;
  }
    //case(RESTRICT):{nprintf(nabla, "/*RESTRICT*/", "__restrict__ ");break;}
    
  case(POSTFIX_CONSTANT):{
     nprintf(nabla, "/*postfix_constant@true*/", NULL);
     job->parse.postfix_constant=true;
    break;
  }
  case(POSTFIX_CONSTANT_VALUE):{
     nprintf(nabla, "/*postfix_constant_value*/", NULL);
     job->parse.postfix_constant=false;
     job->parse.turnBracketsToParentheses=false;
    break;
  }
  case (FATAL):{
    nprintf(nabla, "/*fatal*/", "fatal");
    break;
  }    
    // On regarde si on hit un appel de fonction
  case(CALL):{
    nablaJob *foundJob;
    nprintf(nabla, "/*JOB_CALL*/", NULL);
    char *callName=n->next->children->children->token;
    nprintf(nabla, "/*got_call*/", NULL);
    if ((foundJob=nablaJobFind(job->entity->jobs,callName))!=NULL){
      if (foundJob->is_a_function!=true){
        nprintf(nabla, "/*isNablaJob*/", NULL);
      }else{
        nprintf(nabla, "/*isNablaFunction*/", NULL);
      }
    }else{
      nprintf(nabla, "/*has not been found*/", NULL);
    }
    break;
  }
  case(END_OF_CALL):{
    nprintf(nabla, "/*ARGS*/", NULL);
    nprintf(nabla, "/*got_args*/", NULL);
    break;
  }

  case(PREPROCS):{
    nprintf(nabla, "/*PREPROCS*/", "\n%s\n",n->token);
    break;
  }
    
  case(UIDTYPE):{
    nprintf(nabla, "UIDTYPE", "int ");
    break;
  }
    
  case(FORALL_INI):{
    nprintf(nabla, "/*FORALL_INI*/", "{\n\t\t\t");//FORALL_INI
    nprintf(nabla, "/*okinaGather*/", "%s",okinaGather(job));
    break;
  }
  case(FORALL_END):{
    nprintf(nabla, "/*okinaScatter*/", okinaScatter(job));
    nprintf(nabla, "/*FORALL_END*/", "\n\t\t}\n\t");//FORALL_END
    job->parse.enum_enum='\0';
    job->parse.turnBracketsToParentheses=false;
    break;
  }

  case(COMPOUND_JOB_INI):{
    if (job->parse.returnFromArgument &&
        ((nabla->colors&BACKEND_COLOR_OpenMP)==BACKEND_COLOR_OpenMP))
      nprintf(nabla, NULL, "int tid = omp_get_thread_num();");
    //nprintf(nabla, NULL, "/*COMPOUND_JOB_INI:*/");
    break;
  }
    
  case(COMPOUND_JOB_END):{
    //nprintf(nabla, NULL, "/*:COMPOUND_JOB_END*/");
    break;
  }
     
  case('}'):{
    nprintf(nabla, NULL, "}"); 
    break;
  }
    
  case('['):{
    if (job->parse.postfix_constant==true
        && job->parse.variableIsArray==true) break;
    if (job->parse.turnBracketsToParentheses==true)
      nprintf(nabla, NULL, "");
    else
      nprintf(nabla, NULL, "[");
    break;
  }

  case(']'):{
    if (job->parse.turnBracketsToParentheses==true){
      if (job->item[0]=='c') nprintf(nabla, "/*tBktOFF*/", "[c]]");
      if (job->item[0]=='n') nprintf(nabla, "/*tBktOFF*/", "[c]]");
      job->parse.turnBracketsToParentheses=false;
    }else{
      nprintf(nabla, NULL, "]");
    }
    //nprintf(nabla, "/*FlushingIsPostfixed*/","/*isDotXYZ=%d*/",job->parse.isDotXYZ);
    //if (job->parse.isDotXYZ==1) nprintf(nabla, NULL, "[c]]/*]+FlushingIsPostfixed*/");
                                        //"[((c>>WARP_BIT)*((1+1+1)<<WARP_BIT))+(c&((1<<WARP_BIT)-1))]]/*]+FlushingIsPostfixed*/");
    //if (job->parse.isDotXYZ==1) nprintf(nabla, NULL, NULL);
    //if (job->parse.isDotXYZ==2) nprintf(nabla, NULL, NULL);
    //if (job->parse.isDotXYZ==3) nprintf(nabla, NULL, NULL);
    job->parse.isPostfixed=0;
    // On flush le isDotXYZ
    job->parse.isDotXYZ=0;
    break;
  }

  case (BOUNDARY_CELL):{
    if (job->parse.enum_enum=='f' && cnfgem=='c') nprintf(nabla, NULL, "f->boundaryCell()");
    if (job->parse.enum_enum=='\0' && cnfgem=='c') nprintf(nabla, NULL, "face->boundaryCell()");
    if (job->parse.enum_enum=='\0' && cnfgem=='f') nprintf(nabla, NULL, "face->boundaryCell()");
   break;
  }
  case (BACKCELL):{
    if (job->parse.enum_enum=='f' && cnfgem=='c') nprintf(nabla, NULL, "f->backCell()");
    if (job->parse.enum_enum=='\0' && cnfgem=='c') nprintf(nabla, NULL, "face->backCell()");
    if (job->parse.enum_enum=='\0' && cnfgem=='f') nprintf(nabla, NULL, "face->backCell()");
    break;
  }
  case (BACKCELLUID):{
    if (cnfgem=='f')
      nprintf(nabla, NULL, "face->backCell().uniqueId()");
    break;
  }
  case (FRONTCELL):{
    if (job->parse.enum_enum=='f' && cnfgem=='c') nprintf(nabla, NULL, "f->frontCell()");
    if (job->parse.enum_enum=='\0' && cnfgem=='f') nprintf(nabla, NULL, "face->frontCell()");
    break;
  }
  case (FRONTCELLUID):{
    if (cnfgem=='f')
      nprintf(nabla, "/*FRONTCELLUID*/", "face->frontCell().uniqueId()");
    break;
  }
  case (NBCELL):{
    if (job->parse.enum_enum=='f'  && cnfgem=='c') nprintf(nabla, NULL, "f->nbCell()");
    if (job->parse.enum_enum=='f'  && cnfgem=='n') nprintf(nabla, NULL, "f->nbCell()");
    if (job->parse.enum_enum=='\0' && cnfgem=='c') nprintf(nabla, NULL, "face->nbCell()");
    if (job->parse.enum_enum=='\0' && cnfgem=='f') nprintf(nabla, NULL, "face->nbCell()");
    if (job->parse.enum_enum=='\0' && cnfgem=='n') nprintf(nabla, NULL, "node->nbCell()");
    break;
  }    
  case (NBNODE):{ if (cnfgem=='c') nprintf(nabla, NULL, "8/*cell->nbNode()*/"); break; }    
    //case (INODE):{ if (cnfgem=='c') nprintf(nabla, NULL, "cell->node"); break; }    

  case (XYZ):{ nprintf(nabla, "/*XYZ*/", NULL); break;}
  case (NEXTCELL):{ nprintf(nabla, "/*token NEXTCELL*/", "nextCell"); break;}
  case (PREVCELL):{ nprintf(nabla, "/*token PREVCELL*/", "prevCell"); break;}
  case (NEXTNODE):{ nprintf(nabla, "/*token NEXTNODE*/", "nextNode"); break; }
  case (PREVNODE):{ nprintf(nabla, "/*token PREVNODE*/", "prevNode"); break; }
  case (PREVLEFT):{ nprintf(nabla, "/*token PREVLEFT*/", "cn.previousLeft()"); break; }
  case (PREVRIGHT):{ nprintf(nabla, "/*token PREVRIGHT*/", "cn.previousRight()"); break; }
  case (NEXTLEFT):{ nprintf(nabla, "/*token NEXTLEFT*/", "cn.nextLeft()"); break; }
  case (NEXTRIGHT):{ nprintf(nabla, "/*token NEXTRIGHT*/", "cn.nextRight()"); break; }
    // Gestion du THIS
  case (THIS):{
    if (cnfgem=='c') nprintf(nabla, "/*token THIS+c*/", "c");
    if (cnfgem=='n') nprintf(nabla, "/*token THIS+n*/", "n");
    if (cnfgem=='f') nprintf(nabla, "/*token THIS+f*/", "f");
    break;
  }
    
  case (SID):{
    nprintf(nabla, NULL, "subDomain()->subDomainId()");
    break;
  }
  case (LID):{
    if (cnfgem=='c') nprintf(nabla, "/*localId c*/", "c->localId()");
    if (cnfgem=='n') nprintf(nabla, "/*localId n*/", "n->localId()");
    break;
  }
  case (UID):{
    if (cnfgem=='c' && (nabla->colors&BACKEND_COLOR_OKINA_STD)==BACKEND_COLOR_OKINA_STD)
      nprintf(nabla, "/*uniqueId c*/", "(WARP_SIZE*c)");
    if (cnfgem=='c' && (nabla->colors&BACKEND_COLOR_OKINA_SSE)==BACKEND_COLOR_OKINA_SSE)
      nprintf(nabla, "/*uniqueId c*/", "integer(WARP_SIZE*c+0,WARP_SIZE*c+1)");
    if (cnfgem=='c' && (nabla->colors&BACKEND_COLOR_OKINA_AVX)==BACKEND_COLOR_OKINA_AVX)
      nprintf(nabla, "/*uniqueId c*/", "integer(WARP_SIZE*c+0,WARP_SIZE*c+1,WARP_SIZE*c+2,WARP_SIZE*c+3)");
    if (cnfgem=='c' && (nabla->colors&BACKEND_COLOR_OKINA_AVX2)==BACKEND_COLOR_OKINA_AVX2)
      nprintf(nabla, "/*uniqueId c*/", "integer(WARP_SIZE*c+0,WARP_SIZE*c+1,WARP_SIZE*c+2,WARP_SIZE*c+3)");
    if (cnfgem=='c' && (nabla->colors&BACKEND_COLOR_OKINA_MIC)==BACKEND_COLOR_OKINA_MIC)
      nprintf(nabla, "/*uniqueId c*/", "integer(WARP_SIZE*c+0,WARP_SIZE*c+1,WARP_SIZE*c+2,WARP_SIZE*c+3,WARP_SIZE*c+4,WARP_SIZE*c+5,WARP_SIZE*c+6,WARP_SIZE*c+7)");
    
    if (cnfgem=='n'&& (nabla->colors&BACKEND_COLOR_OKINA_STD)==BACKEND_COLOR_OKINA_STD)
      nprintf(nabla, "/*uniqueId n*/", "(n)");
    if (cnfgem=='n'&& (nabla->colors&BACKEND_COLOR_OKINA_SSE)==BACKEND_COLOR_OKINA_SSE)
      nprintf(nabla, "/*uniqueId n*/", "integer(WARP_SIZE*n+0,WARP_SIZE*n+1)");
    if (cnfgem=='n'&& (nabla->colors&BACKEND_COLOR_OKINA_AVX)==BACKEND_COLOR_OKINA_AVX)
      nprintf(nabla, "/*uniqueId n*/", "integer(WARP_SIZE*n+0,WARP_SIZE*n+1,WARP_SIZE*n+2,WARP_SIZE*n+3)");
    if (cnfgem=='n'&& (nabla->colors&BACKEND_COLOR_OKINA_MIC)==BACKEND_COLOR_OKINA_MIC)
      nprintf(nabla, "/*uniqueId n*/", "integer(WARP_SIZE*n+0,WARP_SIZE*n+1,WARP_SIZE*n+2,WARP_SIZE*n+3,WARP_SIZE*n+4,WARP_SIZE*n+5,WARP_SIZE*n+6,WARP_SIZE*n+7)");
    break;
  }
  case (AT):{ nprintf(nabla, "/*knAt*/", "; knAt"); break; }
  case ('='):{
    nprintf(nabla, "/*'='->!isLeft*/", "=");
    job->parse.left_of_assignment_operator=false;
    job->parse.turnBracketsToParentheses=false;
    job->parse.variableIsArray=false;
    break;
  }
  case (RSH_ASSIGN):{ job->parse.left_of_assignment_operator=false; nprintf(nabla, NULL, ">>="); break; }
  case (LSH_ASSIGN):{ job->parse.left_of_assignment_operator=false; nprintf(nabla, NULL, "<<="); break; }
  case (ADD_ASSIGN):{ job->parse.left_of_assignment_operator=false; nprintf(nabla, NULL, "+="); break; }
  case (SUB_ASSIGN):{ job->parse.left_of_assignment_operator=false; nprintf(nabla, NULL, "-="); break; }
  case (MUL_ASSIGN):{ job->parse.left_of_assignment_operator=false; nprintf(nabla, NULL, "*="); break; }
  case (DIV_ASSIGN):{ job->parse.left_of_assignment_operator=false; nprintf(nabla, NULL, "/="); break; }
  case (MOD_ASSIGN):{ job->parse.left_of_assignment_operator=false; nprintf(nabla, NULL, "%%="); break; }
  case (AND_ASSIGN):{ job->parse.left_of_assignment_operator=false; nprintf(nabla, NULL, "&="); break; }
  case (XOR_ASSIGN):{ job->parse.left_of_assignment_operator=false; nprintf(nabla, NULL, "^="); break; }
  case (IOR_ASSIGN):{ job->parse.left_of_assignment_operator=false; nprintf(nabla, NULL, "|="); break; }

    
  case (LSH_OP):{ job->parse.left_of_assignment_operator=true; nprintf(nabla, NULL, "<<"); break; }
  case (RETURN):{
    if ((nabla->colors&BACKEND_COLOR_OpenMP)==BACKEND_COLOR_OpenMP){
      char mnx[4]={'M','x','x','\0'};
      const char *var=dfsFetchFirst(job->stdParamsNode,rulenameToId("direct_declarator"));
      astNode *min,*max,*compound_statement=dfsFetch(job->nblParamsNode,rulenameToId("compound_statement"));
      compound_statement=compound_statement->parent;
      assert(compound_statement!=NULL);
      //printf("compound_statement->rule=%s",compound_statement->rule);
      assert(compound_statement->ruleid==rulenameToId("compound_statement"));
      /////////////////////////////////////
      // A *little* bit too cavalier here!
      /////////////////////////////////////
      min=max=NULL;
      min=dfsFetchToken(compound_statement,"min");
      max=dfsFetchToken(compound_statement,"max");
      assert(min!=NULL || max !=NULL);
      if (min!=NULL) {mnx[1]='i';mnx[2]='n'; nprintf(nabla,"/*MIN*/","/*OpenMP REDUCE MIN*/");}
      if (max!=NULL) {mnx[1]='a';mnx[2]='x'; nprintf(nabla,"/*MAX*/","/*OpenMP REDUCE MMAXIN*/");}
      //printf("mnx=%s\n",mnx); fflush(stdout);
      nprintf(nabla, NULL, "\n\t\t}/* des sources */\n\t}/* de l'ENUMERATE */\
\n\tfor (int i=0; i<threads; i+=1){\n\
//var=%s, mnx=%s\n\
\t\t%s=(Reduce%sToDouble(%s_per_thread[i])<Reduce%sToDouble(%s))?Reduce%sToDouble(%s_per_thread[i]):Reduce%sToDouble(%s); \
\n\t\t//info()<<\"%s=\"<<%s;\
  \n\t}\n\treturn ",var,mnx,var,mnx,var,mnx,var,mnx,var,mnx,var,var,var);
      job->parse.returnFromArgument=false;
    }else{
      nprintf(nabla, NULL, "\n\t\t}/* des sources */\n\t}/* de l'ENUMERATE */\n\treturn ");
    }
    job->parse.got_a_return=true;
    job->parse.got_a_return_and_the_semi_colon=false;
    break;
  }
  case ('{'):{nprintf(nabla, NULL, "{\n\t\t"); break; }    
  case ('&'):{nprintf(nabla, NULL, "&"); break; }    
  case (';'):{
    job->parse.variableIsArray=false;
    job->parse.turnBracketsToParentheses=false;
    nprintf(nabla, NULL, ";\n\t\t");
    if (job->parse.function_call_arguments==true){
      job->parse.function_call_arguments=false;
      nprintf(nabla, "/*!function_call_arguments*/", NULL);
    }
    if (job->parse.got_a_return)
      job->parse.got_a_return_and_the_semi_colon=true;
    break;
  }
  default:{
    if (n->token!=NULL) nprintf(nabla, NULL, "%s ", n->token);
    //if (n->token!=NULL) nprintf(nabla, NULL, "/*default*/%s ", n->token);
    break;
  }
  }
}


/*****************************************************************************
  * Dump d'extra param�tres
 *****************************************************************************/
void okinaHookAddExtraParameters(nablaMain *nabla, nablaJob *job, int *numParams){
  nprintf(nabla, "/* direct return from okinaHookAddExtraParameters*/", NULL);
  return;
  // Rajout pour l'instant syst�matiquement des node_coords et du global_deltat
  nablaVariable *var;
  if (*numParams!=0) nprintf(nabla, NULL, ",");
  nprintf(nabla, NULL, "\n\t\treal3 *node_coords");
  *numParams+=1;
  // Et on rajoute les variables globales
  for(var=nabla->variables;var!=NULL;var=var->next){
    //if (strcmp(var->name, "time")==0) continue;
    if (strcmp(var->item, "global")!=0) continue;
    nprintf(nabla, NULL, ",\n\t\t%s *global_%s",
            (var->type[0]=='r')?"real":(var->type[0]=='i')?"int":"/*Unknown type*/",
            var->name);
    *numParams+=1;
  }
  
  // Rajout pour l'instant syst�matiquement des connectivit�s
  if (job->item[0]=='c')
    okinaAddExtraConnectivitiesParameters(nabla, numParams);
}



// ****************************************************************************
// * Dump d'extra connectivity
// ****************************************************************************
void okinaAddExtraConnectivitiesArguments(nablaMain *nabla, int *numParams){
  return;
}

void okinaAddExtraConnectivitiesParameters(nablaMain *nabla, int *numParams){
  return;
}


// ****************************************************************************
// * Dump dans le src des parametres nabla en in comme en out
// * On va surtout remplir les variables 'in' utilis�es de support diff�rent
// * pour pr�parer les GATHER/SCATTER
// ****************************************************************************
void okinaHookDumpNablaParameterList(nablaMain *nabla,
                                     nablaJob *job,
                                     astNode *n,
                                     int *numParams){
  dbg("\n\t[okinaHookDumpNablaParameterList]");
  // S'il n'y a pas de in ni de out, on a rien � faire
  if (n==NULL) return;
  // Aux premier COMPOUND_JOB_INI ou '@', on a termin�
  if (n->tokenid==COMPOUND_JOB_INI) return;
  if (n->tokenid=='@') return;
  // Si on trouve un token 'OUT', c'est qu'on passe des 'in' aux 'out'
  if (n->tokenid==OUT) job->parse.inout=enum_out_variable;
  // Si on trouve un token 'INOUT', c'est qu'on passe des 'out' aux 'inout'
  if (n->tokenid==INOUT) job->parse.inout=enum_inout_variable;
  // D�s qu'on hit une d�claration, c'est qu'on a une variable candidate
  if (n->ruleid==rulenameToId("direct_declarator")){
    // On la r�cup�re
    nablaVariable *var=nablaVariableFind(nabla->variables, n->children->token);
    dbg("\n\t[okinaHookDumpNablaParameterList] Looking for variable '%s'", n->children->token);
    // Si elle n'existe pas, c'est pas normal � ce stade: c'est une erreur de nom
    if (var == NULL)
      return exit(NABLA_ERROR|fprintf(stderr,
                                      "\n[okinaHookDumpNablaParameterList] Cannot find variable '%s'!\n",
                                      n->children->token));
    // Si elles n'ont pas le m�me support, c'est qu'il va falloir ins�rer un gather/scatter
    if (var->item[0] != job->item[0]){
      //nprintf(nabla, NULL, "\n\t\t/* gather/scatter for %s_%s*/", var->item, var->name);
      // Cr�ation d'une nouvelle in_out_variable
      nablaVariable *new = nablaVariableNew(NULL);
      new->name=strdup(var->name);
      new->item=strdup(var->item);
      new->type=strdup(var->type);
      new->dim=var->dim;
      new->size=var->size;
      new->inout=job->parse.inout;
      // Rajout � notre liste
      if (job->variables_to_gather_scatter==NULL)
        job->variables_to_gather_scatter=new;
      else
        nablaVariableLast(job->variables_to_gather_scatter)->next=new;
    }
  }
  if (n->children != NULL) okinaHookDumpNablaParameterList(nabla,job,n->children,numParams);
  if (n->next != NULL) okinaHookDumpNablaParameterList(nabla,job,n->next, numParams);

}



/*****************************************************************************
  * Dump d'extra arguments
 *****************************************************************************/
void okinaAddExtraArguments(nablaMain *nabla, nablaJob *job, int *numParams){
  nprintf(nabla,"\n\t\t/*okinaAddExtraArguments*/",NULL);
}


/*****************************************************************************
  * Dump dans le src des arguments nabla en in comme en out
 *****************************************************************************/
void okinaDumpNablaArgumentList(nablaMain *nabla, astNode *n, int *numParams){
  nprintf(nabla,"\n\t\t/*okinaDumpNablaArgumentList*/",NULL);
}


/*****************************************************************************
  * Dump dans le src l'appel des fonction de debug des arguments nabla  en out
 *****************************************************************************/
void okinaDumpNablaDebugFunctionFromOutArguments(nablaMain *nabla, astNode *n, bool in_or_out){
  nprintf(nabla,"\n\t\t/*okinaDumpNablaDebugFunctionFromOutArguments*/",NULL);
}


// *****************************************************************************
// * Ajout des variables d'un job trouv� depuis une fonction @�e
// *****************************************************************************
void okinaAddNablaVariableList(nablaMain *nabla, astNode *n, nablaVariable **variables){
  nprintf(nabla,"\n/*okinaAddNablaVariableList*/",NULL);
}


/*****************************************************************************
 * G�n�ration d'un kernel associ� � un support
 *****************************************************************************/
void okinaHookJob(nablaMain *nabla, astNode *n){
  nablaJob *job = nablaJobNew(nabla->entity);
  nablaJobAdd(nabla->entity, job);
  nablaJobFill(nabla,job,n,NULL);
  
  // On teste *ou pas* que le job retourne bien 'void' dans le cas de OKINA
  //if ((strcmp(job->rtntp,"void")!=0) && (job->is_an_entry_point==true))
  //  exit(NABLA_ERROR|fprintf(stderr, "\n[okinaHookJob] Error with return type which is not void\n"));
}


