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
 * Traitement des transformations '[', '(' & ''
 *****************************************************************************/
void ccHookTurnBracketsToParentheses(nablaMain* nabla, nablaJob *job, nablaVariable *var, char cnfg){
  dbg("\n\t[actJobItemParse] primaryExpression hits variable");
  if (  (cnfg=='c' && var->item[0]=='n')
      ||(cnfg=='c' && var->item[0]=='f')
      ||(cnfg=='n' && var->item[0]!='n')            
      ||(cnfg=='f' && var->item[0]!='f')
      ||(cnfg=='e' && var->item[0]!='e')
      ||(cnfg=='m' && var->item[0]!='m')
      ){
    if (!job->parse.selection_statement_in_compound_statement){
      nprintf(nabla, "/*turnBracketsToParentheses@true*/", "/*%c %c*/", cnfg, var->item[0]);
      nprintf(nabla, "/*turnBracketsToParentheses@true*/", NULL);
    }else{
      nprintf(nabla, "/*turnBracketsToParentheses+if@true*/", "cell_node[", cnfg, var->item[0]);
    }
    job->parse.turnBracketsToParentheses=true;
  }else{
    if (job->parse.postfix_constant==true
        && job->parse.variableIsArray==true) return;
    if (job->parse.isDotXYZ==1) nprintf(nabla, "/*ccHookTurnBracketsToParentheses_X*/", NULL);
    if (job->parse.isDotXYZ==2) nprintf(nabla, "/*ccHookTurnBracketsToParentheses_Y*/", NULL);
    if (job->parse.isDotXYZ==3) nprintf(nabla, "/*ccHookTurnBracketsToParentheses_Z*/", NULL);
    job->parse.isDotXYZ=0;
    job->parse.turnBracketsToParentheses=false;
  }
}


/***************************************************************************** 
 * Traitement des tokens SYSTEM
 *****************************************************************************/
void ccHookSystem(astNode * n,nablaMain *arc, const char cnf, char enum_enum){
  char *itm=(cnf=='c')?"cell":(cnf=='n')?"node":"face";
  char *etm=(enum_enum=='c')?"c":(enum_enum=='n')?"n":"f";
  if (n->tokenid == LID)           nprintf(arc, "/*chs*/", "[%s->localId()]",itm);//asInteger
  if (n->tokenid == SID)           nprintf(arc, "/*chs*/", "[subDomain()->subDomainId()]");
  if (n->tokenid == THIS)          nprintf(arc, "/*chs THIS*/", NULL);
  if (n->tokenid == NBNODE)        nprintf(arc, "/*chs NBNODE*/", NULL);
  if (n->tokenid == NBCELL)        nprintf(arc, "/*chs NBCELL*/", NULL);
  //if (n->tokenid == INODE)         nprintf(arc, "/*chs INODE*/", NULL);
  if (n->tokenid == BOUNDARY_CELL) nprintf(arc, "/*chs BOUNDARY_CELL*/", NULL);
  if (n->tokenid == FATAL)         nprintf(arc, "/*chs*/", "throw FatalErrorException");
  if (n->tokenid == BACKCELL)      nprintf(arc, "/*chs*/", "[%s->backCell()]",(enum_enum=='\0')?itm:etm);
  if (n->tokenid == BACKCELLUID)   nprintf(arc, "/*chs*/", "[%s->backCell().uniqueId()]",itm);
  if (n->tokenid == FRONTCELL)     nprintf(arc, "/*chs*/", "[%s->frontCell()]",(enum_enum=='\0')?itm:etm);
  if (n->tokenid == FRONTCELLUID)  nprintf(arc, "/*chs*/", "[%s->frontCell().uniqueId()]",itm);
  if (n->tokenid == NEXTCELL)      nprintf(arc, NULL, ")");
  if (n->tokenid == PREVCELL)      nprintf(arc, NULL, ")");
  if (n->tokenid == NEXTNODE)      nprintf(arc, NULL, "[n])+nextNode))");
  if (n->tokenid == PREVNODE)      nprintf(arc, NULL, "[n])-prevNode))");
  if (n->tokenid == PREVLEFT)      nprintf(arc, "/*chs PREVLEFT*/", "[cn.previousLeft()]");
  if (n->tokenid == PREVRIGHT)     nprintf(arc, "/*chs PREVRIGHT*/", "[cn.previousRight()]");
  if (n->tokenid == NEXTLEFT)      nprintf(arc, "/*chs NEXTLEFT*/", "[cn.nextLeft()]");
  if (n->tokenid == NEXTRIGHT)     nprintf(arc, "/*chs NEXTRIGHT*/", "[cn.nextRight()]");
  //error(!0,0,"Could not switch Cc Hook System!");
}


/*****************************************************************************
 * Pr�pare le nom de la variable
 *****************************************************************************/
static void nvar(nablaMain *nabla, nablaVariable *var, nablaJob *job){
  if (!job->parse.selection_statement_in_compound_statement){
    nprintf(nabla, "/*tt2a*/", "%s_%s", var->item, var->name);
  }else{
    nprintf(nabla,NULL,"/*%s*/",var->type);
    if (strcmp(var->type,"real")==0)
      nprintf(nabla, "/*tt2a(if+real)*/", "((double*)%s_%s)", var->item, var->name);
    if (strcmp(var->type,"integer")==0)
      nprintf(nabla, "/*tt2a(if+int)*/", "((int*)%s_%s)", var->item, var->name);
    if (strcmp(var->type,"real3")==0)
      nprintf(nabla, "/*tt2a(if+real3)*/", "/*if+real3 still in real3 vs double3*/%s_%s", var->item, var->name);
    //nprintf(nabla, "/*tt2a(if+real3)*/", "((double3*)%s_%s)", var->item, var->name);
  }    
  if (strcmp(var->type,"real3")!=0){
    nprintf(nabla, "/*nvar no diffraction possible here*/",NULL);
    return;
  }
  return;
}


/*****************************************************************************
 * Postfix d'un .x|y|z slon le isDotXYZ
 *****************************************************************************/
static void setDotXYZ(nablaMain *nabla, nablaVariable *var, nablaJob *job){
  switch (job->parse.isDotXYZ){
  case(0): break;
  case(1): {nprintf(nabla, "/*setDotX+flush*/", ""); break;}
  case(2): {nprintf(nabla, "/*setDotY+flush*/", ""); break;}
  case(3): {nprintf(nabla, "/*setDotZ+flush*/", ""); break;}
  default:exit(NABLA_ERROR|fprintf(stderr, "\n[setDotXYZ] Switch isDotXYZ error\n"));
  }
  // Flush isDotXYZ
  job->parse.isDotXYZ=0;
  job->parse.turnBracketsToParentheses=false;
}


/*****************************************************************************
 * Tokens to gathered  variables
 *****************************************************************************/
static bool ccHookTurnTokenToGatheredVariable(nablaMain *arc,
                                                 nablaVariable *var,
                                                 nablaJob *job){
  //nprintf(arc, NULL, "/*gathered variable?*/");
  if (!var->is_gathered) return false;
  nprintf(arc, "/*gathered variable!*/", "gathered_%s_%s",var->item,var->name);
  return true;
}


/*****************************************************************************
 * Tokens to variables 'CELL Job' switch
 *****************************************************************************/
static void ccHookTurnTokenToVariableForCellJob(nablaMain *arc,
                                                  nablaVariable *var,
                                                  nablaJob *job){
  const char cnfg=job->item[0];
  char enum_enum=job->parse.enum_enum;
  int isPostfixed=job->parse.isPostfixed;

  // Preliminary pertinence test
  if (cnfg != 'c') return;
  
  //nprintf(arc, "/*CellJob*/","/*CellJob*/");
  
  // On dump le nom de la variable trouv�e, sauf pour les globals qu'on doit faire pr�c�d� d'un '*'
  if ((job->parse.function_call_arguments==true)&&(var->dim==1)){
    //nprintf(arc, "/*function_call_arguments,*/","&");
  }
  switch (var->item[0]){
  case ('c'):{
    nvar(arc,var,job);
    nprintf(arc, "/*CellVar*/",
            "%s",
            ((var->dim==0)? (isPostfixed==2)?"":"[c":
             (enum_enum!='\0')?"[n+8*c":
             (var->dim==1)?"[8*c":"[c"));
    job->parse.variableIsArray=(var->dim==1)?true:false;
    if (job->parse.postfix_constant==true
        && job->parse.variableIsArray==true)
      nprintf(arc, NULL,"+");
    else
      nprintf(arc, NULL,"]");
    break;
  }
  case ('n'):{
    nvar(arc,var,job);
    if (enum_enum=='f') nprintf(arc, "/*f*/", "[");
    if (enum_enum=='n') nprintf(arc, "/*n*/", "[cell_node[n*NABLA_NB_CELLS+c]]");
    if (isPostfixed!=2 && enum_enum=='\0'){
      if (job->parse.postfix_constant==true)
        nprintf(arc, "/*NodeVar + postfix_constant*/", "[");
      else
        nprintf(arc, "/*NodeVar 0*/", "[cell_node_");
    }
    if (isPostfixed==2 && enum_enum=='\0') nprintf(arc, "/*NodeVar 2&0*/", "[cell_node_");
    if (job->parse.postfix_constant!=true) setDotXYZ(arc,var,job);
    break;
  }
  case ('f'):{
    nvar(arc,var,job);
    if (enum_enum=='f') nprintf(arc, "/*FaceVar*/", "[f]");
    if (enum_enum=='\0') nprintf(arc, "/*FaceVar*/", "[cell->face");
    break;
  }
  case ('g'):{
    nprintf(arc, "/*GlobalVar*/", "%s_%s[0]", var->item, var->name);
    break;      // GLOBAL variable
  }
  default:exit(NABLA_ERROR|fprintf(stderr, "\n[ncc] CELLS job ccHookTurnTokenToVariableForCellJob\n"));
  }
}


/*****************************************************************************
 * Tokens to variables 'NODE Job' switch
 *****************************************************************************/
static void ccHookTurnTokenToVariableForNodeJob(nablaMain *arc,
                                                  nablaVariable *var,
                                                  nablaJob *job){
  const char cnfg=job->item[0];
  char enum_enum=job->parse.enum_enum;
  int isPostfixed=job->parse.isPostfixed;

  // Preliminary pertinence test
  if (cnfg != 'n') return;
  nprintf(arc, "/*NodeJob*/",NULL);

  // On dump le nom de la variable trouv�e, sauf pour les globals qu'on doit faire pr�c�d� d'un '*'
  if (var->item[0]!='g') nvar(arc,var,job);

  switch (var->item[0]){
  case ('c'):{
    if (var->dim!=0)     nprintf(arc, "/*CellVar dim!0*/", "[c][c");
    if (enum_enum=='f')  nprintf(arc, "/*CellVar f*/", "[");
    if (enum_enum=='n')  nprintf(arc, "/*CellVar n*/", "[n]");
    if (enum_enum=='c')  nprintf(arc, "/*CellVar c*/", "[c]");
    if (enum_enum=='\0') nprintf(arc, "/*CellVar 0*/", "[cell->node");
    break;
  }
  case ('n'):{
    if ((isPostfixed!=2) && enum_enum=='f')  nprintf(arc, "/*NodeVar !2f*/", "[n]");
    if ((isPostfixed==2) && enum_enum=='f')  ;//nprintf(arc, NULL);
    if ((isPostfixed==2) && enum_enum=='\0') nprintf(arc, "/*NodeVar 20*/", NULL);
    if ((isPostfixed!=2) && enum_enum=='n')  nprintf(arc, "/*NodeVar !2n*/", "[n]");
    if ((isPostfixed!=2) && enum_enum=='c')  nprintf(arc, "/*NodeVar !2c*/", "[n]");
    if ((isPostfixed!=2) && enum_enum=='\0') nprintf(arc, "/*NodeVar !20*/", "[n]");
    break;
  }
  case ('f'):{
    if (enum_enum=='f')  nprintf(arc, "/*FaceVar f*/", "[f]");
    if (enum_enum=='\0') nprintf(arc, "/*FaceVar 0*/", "[face]");
    break;
  }
  case ('g'):{
    nprintf(arc, "/*GlobalVar*/", "%s_%s[0]", var->item, var->name);
    break;
  }
  default:exit(NABLA_ERROR|fprintf(stderr, "\n[ncc] NODES job ccHookTurnTokenToVariableForNodeJob\n"));
  }
}


/*****************************************************************************
 * Tokens to variables 'FACE Job' switch
 *****************************************************************************/
static void ccHookTurnTokenToVariableForFaceJob(nablaMain *arc,
                                                  nablaVariable *var,
                                                  nablaJob *job){
  const char cnfg=job->item[0];
  char enum_enum=job->parse.enum_enum;
  int isPostfixed=job->parse.isPostfixed;

  // Preliminary pertinence test
  if (cnfg != 'f') return;
  nprintf(arc, "/*FaceJob*/", NULL);
  // On dump le nom de la variable trouv�e, sauf pour les globals qu'on doit faire pr�c�d� d'un '*'
  if (var->item[0]!='g') nvar(arc,var,job);
  switch (var->item[0]){
  case ('c'):{
    nprintf(arc, "/*CellVar*/",
            "%s",
            ((var->dim==0)?
             ((enum_enum=='\0')?
              (isPostfixed==2)?"[":"[face->cell"
              :"[c")
             :"[cell][node->cell")); 
    break;
  }
  case ('n'):{
    nprintf(arc, "/*NodeVar*/", "[face->node");
    break;
  }
  case ('f'):{
    nprintf(arc, "/*FaceVar*/", "[face]");
    break;
  }
  case ('g'):{
    nprintf(arc, "/*GlobalVar*/", "%s_%s[0]", var->item, var->name);
    break;
  }
  default:exit(NABLA_ERROR|fprintf(stderr, "\n[ncc] CELLS job ccHookTurnTokenToVariableForFaceJob\n"));
  }
}


/*****************************************************************************
 * Tokens to variables 'Std Function' switch
 *****************************************************************************/
static void ccHookTurnTokenToVariableForStdFunction(nablaMain *arc,
                                                    nablaVariable *var,
                                                    nablaJob *job){
  const char cnfg=job->item[0];
  // Preliminary pertinence test
  if (cnfg != '\0') return;
  nprintf(arc, "/*StdJob*/", NULL);// Fonction standard
  // On dump le nom de la variable trouv�e, sauf pour les globals qu'on doit faire pr�c�d� d'un '*'
  if (var->item[0]!='g') nvar(arc,var,job);
  switch (var->item[0]){
  case ('c'):{
    nprintf(arc, "/*CellVar*/", NULL);// CELL variable
    break;
  }
  case ('n'):{
    nprintf(arc, "/*NodeVar*/", NULL); // NODE variable
    break;
  }
  case ('f'):{
    nprintf(arc, "/*FaceVar*/", NULL);// FACE variable
    break;
  }
  case('g'):{
    nprintf(arc, "/*GlobalVar*/", "%s_%s[0]", var->item, var->name);
    break;
  }
  default:exit(NABLA_ERROR|fprintf(stderr, "\n[ncc] StdJob ccHookTurnTokenToVariableForStdFunction\n"));
  }
}


/*****************************************************************************
 * Transformation de tokens en variables selon les contextes dans le cas d'un '[Cell|node]Enumerator'
 *****************************************************************************/
nablaVariable *ccHookTurnTokenToVariable(astNode * n,
                                            nablaMain *arc,
                                            nablaJob *job){
  nablaVariable *var=nablaVariableFind(arc->variables, n->token);
  // Si on ne trouve pas de variable, on a rien � faire
  if (var == NULL) return NULL;
  dbg("\n\t[ccHookTurnTokenToVariable] %s_%s token=%s", var->item, var->name, n->token);

  // Set good isDotXYZ
  if (job->parse.isDotXYZ==0 && strcmp(var->type,"real3")==0 && job->parse.left_of_assignment_operator==true){
//    #warning Diffracting OFF
    //nprintf(arc, NULL, "/* DiffractingNOW */");
    //job->parse.diffracting=true;
    //job->parse.isDotXYZ=job->parse.diffractingXYZ=1;
  }
  //nprintf(arc, NULL, "\n\t/*ccHookTurnTokenToVariable::isDotXYZ=%d, job->parse.diffractingXYZ=%d*/", job->parse.isDotXYZ, job->parse.diffractingXYZ);

  // Check whether this variable is being gathered
  if (ccHookTurnTokenToGatheredVariable(arc,var,job)){
    return var;
  }
  
  // Check whether there's job for a cell job
  ccHookTurnTokenToVariableForCellJob(arc,var,job);
  
  // Check whether there's job for a node job
  ccHookTurnTokenToVariableForNodeJob(arc,var,job);
  
  // Check whether there's job for a face job
  ccHookTurnTokenToVariableForFaceJob(arc,var,job);
  
  // Check whether there's job for a face job
  ccHookTurnTokenToVariableForStdFunction(arc,var,job);
  return var;
}


/***************************************************************************** 
 * Upcase de la cha�ne donn�e en argument
 *****************************************************************************/
static inline char *itemUPCASE(const char *itm){
  if (itm[0]=='c') return "CELLS";
  if (itm[0]=='n') return "NODES";
  if (itm[0]=='g') return "GLOBAL";
  dbg("\n\t[itemUPCASE] itm=%s", itm);
  exit(NABLA_ERROR|fprintf(stderr, "\n[itemUPCASE] Error with given item\n"));
  return NULL;
}


/***************************************************************************** 
 * enums pour les diff�rents dumps � faire: d�claration, malloc et free
 *****************************************************************************/
typedef enum {
  CC_VARIABLES_DECLARATION=0,
  CC_VARIABLES_MALLOC,
  CC_VARIABLES_FREE
} CC_VARIABLES_SWITCH;


// Pointeur de fonction vers une qui dump ce que l'on souhaite
typedef NABLA_STATUS (*pFunDump)(nablaMain *nabla, nablaVariable *var, char *postfix, char *depth);


/***************************************************************************** 
 * Dump d'un MALLOC d'une variables dans le fichier source
 *****************************************************************************/
static NABLA_STATUS ccGenerateSingleVariableMalloc(nablaMain *nabla,
                                                    nablaVariable *var,
                                                    char *postfix,
                                                    char *depth){
  nprintf(nabla,"\n\t// ccGenerateSingleVariableMalloc",NULL);
  return NABLA_OK;
}


/***************************************************************************** 
 * Dump d'un FREE d'une variables dans le fichier source
 *****************************************************************************/
static NABLA_STATUS ccGenerateSingleVariableFree(nablaMain *nabla,
                                                  nablaVariable *var,
                                                  char *postfix,
                                                  char *depth){  
  nprintf(nabla,"\n\t// ccGenerateSingleVariableFree",NULL);
  return NABLA_OK;
}


/***************************************************************************** 
 * Dump d'une variables dans le fichier
 *****************************************************************************/
static NABLA_STATUS ccGenerateSingleVariable(nablaMain *nabla,
                                              nablaVariable *var,
                                              char *postfix,
                                              char *depth){  
  nprintf(nabla,"\n\t// ccGenerateSingleVariable",NULL);
  if (var->dim==0)
    fprintf(nabla->entity->hdr,"\n%s %s_%s%s%s[NABLA_NB_%s_WARP] __attribute__ ((aligned(WARP_ALIGN)));",
            postfix?"real":var->type, var->item, var->name, postfix?postfix:"", depth?depth:"",
            itemUPCASE(var->item));
  if (var->dim==1)
    fprintf(nabla->entity->hdr,"\n%s %s_%s%s[%ld*NABLA_NB_%s_WARP] __attribute__ ((aligned(WARP_ALIGN)));;",
            postfix?"real":var->type,
            var->item,var->name,
            postfix?postfix:"",
            var->size,
            itemUPCASE(var->item));
  return NABLA_OK;
}


/***************************************************************************** 
 * Retourne quelle fonction selon l'enum donn�
 *****************************************************************************/
static pFunDump witch2func(CC_VARIABLES_SWITCH witch){
  switch (witch){
  case (CC_VARIABLES_DECLARATION): return ccGenerateSingleVariable;
  case (CC_VARIABLES_MALLOC): return ccGenerateSingleVariableMalloc;
  case (CC_VARIABLES_FREE): return ccGenerateSingleVariableFree;
  default: exit(NABLA_ERROR|fprintf(stderr, "\n[witch2switch] Error with witch\n"));
  }
}


/***************************************************************************** 
 * Dump d'une variables de dimension 1
 *****************************************************************************/
static NABLA_STATUS ccGenericVariableDim1(nablaMain *nabla, nablaVariable *var, pFunDump fDump){
  //int i;
  //char depth[]="[0]";
  dbg("\n[ccGenerateVariableDim1] variable %s", var->name);
  //for(i=0;i<NABLA_HARDCODED_VARIABLE_DIM_1_DEPTH;++i,depth[1]+=1) fDump(nabla, var, NULL, depth);
  fDump(nabla, var, NULL, "/*8*/");
  return NABLA_OK;
}

/***************************************************************************** 
 * Dump d'une variables de dimension 0
 *****************************************************************************/
static NABLA_STATUS ccGenericVariableDim0(nablaMain *nabla, nablaVariable *var, pFunDump fDump){  
  dbg("\n[ccGenerateVariableDim0] variable %s", var->name);
  if (strcmp(var->type,"real3")!=0)
    return fDump(nabla, var, NULL, NULL);
  else
    return fDump(nabla, var, NULL, NULL);
  return NABLA_ERROR;
}

/***************************************************************************** 
 * Dump d'une variables
 *****************************************************************************/
static NABLA_STATUS ccGenericVariable(nablaMain *nabla, nablaVariable *var, pFunDump fDump){  
  if (!var->axl_it) return NABLA_OK;
  if (var->item==NULL) return NABLA_ERROR;
  if (var->name==NULL) return NABLA_ERROR;
  if (var->type==NULL) return NABLA_ERROR;
  if (var->dim==0) return ccGenericVariableDim0(nabla,var,fDump);
  if (var->dim==1) return ccGenericVariableDim1(nabla,var,fDump);
  dbg("\n[ccGenericVariable] variable dim error: %d", var->dim);
  exit(NABLA_ERROR|fprintf(stderr, "\n[ccGenericVariable] Error with given variable\n"));
}


/***************************************************************************** 
 * Dump des options
 *****************************************************************************/
static void ccOptions(nablaMain *nabla){
  nablaOption *opt;
  fprintf(nabla->entity->hdr,"\n\n\n\
// ********************************************************\n\
// * Options\n\
// ********************************************************");
  for(opt=nabla->options;opt!=NULL;opt=opt->next)
    fprintf(nabla->entity->hdr,
            "\n#define %s %s",
            opt->name, opt->dflt);
}

/***************************************************************************** 
 * Dump des globals
 *****************************************************************************/
static void ccGlobals(nablaMain *nabla){
  fprintf(nabla->entity->hdr,"\n\n\n\
// ********************************************************\n\
// * Temps de la simulation\n\
// ********************************************************\n\
Real global_deltat[1];\n\
int global_iteration;\n\
double global_time;\n");
}


/***************************************************************************** 
 * Dump des variables
 *****************************************************************************/
void ccVariablesPrefix(nablaMain *nabla){
  nablaVariable *var;

  fprintf(nabla->entity->hdr,"\n\n\
// ********************************************************\n\
// * Variables\n\
// ********************************************************");
  for(var=nabla->variables;var!=NULL;var=var->next){
    if (ccGenericVariable(nabla, var, witch2func(CC_VARIABLES_DECLARATION))==NABLA_ERROR)
      exit(NABLA_ERROR|fprintf(stderr, "\n[ccVariables] Error with variable %s\n", var->name));
    if (ccGenericVariable(nabla, var, witch2func(CC_VARIABLES_MALLOC))==NABLA_ERROR)
      exit(NABLA_ERROR|fprintf(stderr, "\n[ccVariables] Error with variable %s\n", var->name));
  }
  ccOptions(nabla);
  ccGlobals(nabla);
}



void ccVariablesPostfix(nablaMain *nabla){
  nablaVariable *var;
  for(var=nabla->variables;var!=NULL;var=var->next)
    if (ccGenericVariable(nabla, var, witch2func(CC_VARIABLES_FREE))==NABLA_ERROR)
      exit(NABLA_ERROR|fprintf(stderr, "\n[ccVariables] Error with variable %s\n", var->name));
}


