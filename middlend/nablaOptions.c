/*****************************************************************************
 * CEA - DAM/DSSI/SNEC/LECM                                                  *
 *****************************************************************************
 * File     : nccArcOptions.c      									       			  *
 * Author   : Camier Jean-Sylvain														  *
 * Created  : 2012.11.30																	  *
 * Updated  : 2012.11.30																	  *
 *****************************************************************************
 * Description: 																				  *
 *****************************************************************************
 * Date			Author	Description														  *
 * 2012.11.30	camierjs	Creation															  *
 *****************************************************************************/
#include "nabla.h"

nablaOption *nablaOptionNew(nablaMain *nabla){
	nablaOption *option;
	option = (nablaOption *)malloc(sizeof(nablaOption));
 	assert(option != NULL);
   option->axl_it=true; // Par d�faut, on dump la option dans le fichier AXL
   option->type=option->name=option->dflt=NULL;
   option->main=nabla;
   option->next=NULL;
  	return option; 
}

nablaOption *nablaOptionLast(nablaOption *options) {
   while(options->next != NULL){
     options = options->next;
   }
   return options;
}

nablaOption *nablaOptionAdd(nablaMain *nabla, nablaOption *option) {
  assert(option != NULL);
  if (nabla->options == NULL)
    nabla->options=option;
  else
    nablaOptionLast(nabla->options)->next=option;
  return NABLA_OK;
}


/*
 * 
 */
nablaOption *findOptionName(nablaOption *options, char *name) {
  nablaOption *option=options;
  //dbg("\n\t[findOptionName] %s", name);
  //assert(option != NULL && name != NULL);
  if (option==NULL) return NULL;
  while(option != NULL) {
    //dbg(" ?%s", option->name);
    if(strcmp(option->name, name) == 0){
      //dbg(" Yes!");
      return option;
    }
    option = option->next;
  }
  //dbg(" Nope!");
  return NULL;
}


/***************************************************************************** 
 * type_specifier
 *****************************************************************************/
static void actOptionsTypeSpecifier(astNode * n, void *generic_arg){
  nablaMain *nabla=(nablaMain*)generic_arg;
  nablaOption *option = nablaOptionNew(nabla);
  dbg("\n\t\t[actGenericOptionsTypeSpecifier] %s",n->children->token);
  nablaOptionAdd(nabla, option);
  option->type=toolStrDownCase(n->children->token);
}


/***************************************************************************** 
 * direct_declarator
 *****************************************************************************/
static void actOptionsDirectDeclarator(astNode * n, void *generic_arg){
  nablaMain *nabla=(nablaMain*)generic_arg;
  nablaOption *option =nablaOptionLast(nabla->options);
  dbg("\n\t\t[actGenericOptionsDirectDeclarator] %s", n->children->token);
  option->name=strdup(n->children->token);
}


/***************************************************************************** 
 * primary_expression
 *****************************************************************************/
void catTillToken(astNode * n, char *dflt){
  if (n==NULL) return;
  if (n->token != NULL){
    dbg("\n\t\t\t[catTillToken] %s", n->token);
    if (n->tokenid != ';'){
      dflt=realloc(dflt, strlen(dflt)+strlen(n->token));
      strcat(dflt,n->token);
    }
  }
  if (n->children != NULL) catTillToken(n->children, dflt);
  if (n->next != NULL) catTillToken(n->next, dflt);
}


static void actOptionsPrimaryExpression(astNode * n, void *generic_arg){
  nablaMain *nabla=(nablaMain*)generic_arg;
  nablaOption *option =nablaOptionLast(nabla->options);
  dbg("\n\t\t[actOptionsPrimaryExpression] %s", n->children->token);
  option->dflt=strdup(n->children->token);
  catTillToken(n->children->next, option->dflt);
  dbg("\n\t\t[actOptionsPrimaryExpression] final option->dflt is '%s'", option->dflt);
}




/***************************************************************************** 
 * Scan pour la d�claration des options
 *****************************************************************************/
void nablaOptions(astNode * n, int ruleid, nablaMain *nabla){
  RuleAction tokact[]={
    {rulenameToId("type_specifier"),actOptionsTypeSpecifier},
    {rulenameToId("direct_declarator"),actOptionsDirectDeclarator},
    {rulenameToId("primary_expression"),actOptionsPrimaryExpression},
    {0,NULL}};
  assert(ruleid!=1);
  if (n->rule != NULL)
    if (ruleid ==  n->ruleid)
      scanTokensForActions(n, tokact, (void*)nabla);
  if (n->children != NULL) nablaOptions(n->children, ruleid, nabla);
  if (n->next != NULL) nablaOptions(n->next, ruleid, nabla);
}


/*****************************************************************************
 * Transformation de tokens en options
 *****************************************************************************/
nablaOption *turnTokenToOption(astNode * n, nablaMain *arc){
  nablaOption *opt=findOptionName(arc->options, n->token);
  // Si on ne trouve pas d'option, on a rien � faire
  if (opt == NULL) return NULL;
  arc->hook->turnTokenToOption(arc,opt);
  return opt;
}
