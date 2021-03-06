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
#include "nabla.h"


// ****************************************************************************
// * List des noeuds alloués
// ****************************************************************************
typedef struct nAstList{
  node *n;
  struct nAstList *next; 
} nAstList;
static nAstList *nast=NULL;
static nAstList *nlst=NULL;
void nAstListFree(void){
  for(nAstList *this,*list=nast;list!=NULL;){
    list=(this=list)->next;
    free(this->n);
    free(this);
  }
}


// ****************************************************************************
// * astNewNode
// ****************************************************************************
node *astNewNode(char *token, const unsigned int tokenid) {
  node *n = (node*)calloc(1,sizeof(node));
  assert(n);
  
  nAstList *nl=(nAstList*)calloc(1,sizeof(nAstList));
  assert(nl);
  nl->n=n;
  if (nast==NULL) nast=nlst=nl;
  else nlst=nlst->next=nl;
  
  n->tokenid=tokenid;
  if (token==NULL) return n;
  //dbg("\n\t[astNewNode] Non-Empty UTF8 Token: ('%s',#%d)", token, tokenid);
  n->token_utf8=sdup(token);
  n->token=utf2ascii(n->token_utf8);
  //dbg("\n\t[astNewNode] Non-Empty ASCII Token: ('%s',#%d)", n->token, tokenid);
  return n; 
}


// ****************************************************************************
// * astNewNodeRule
// ****************************************************************************
node *astNewNodeRule(const char *rule, unsigned int ruleid) {
  node *n=astNewNode(NULL,0);
  assert(rule != NULL);
  n->rule = rule; 
  n->ruleid = ruleid;   
  return n;
}


// ****************************************************************************
// * astAddChild
// ****************************************************************************
node *astAddChild(node *root, node *child) {
  assert(root != NULL && child != NULL);
  node *next=root->children;
  // On set le parent du nouvel enfant
  child->parent=root;
  // S'il n'y a pas de fils, on le crée
  if (root->children==NULL) return root->children = child;
  // Sinon, on scrute jusqu'au dernier enfant
  for(;next->next!=NULL;next=next->next);
  // Et on l'append
  return next->next=child;
}


// ****************************************************************************
// * astAddNext
// ****************************************************************************
node *astAddNext(node *root, node *n) {
  assert(root != NULL && n != NULL);
  node *next=root;
  // On set le parent du nouvel enfant
  n->parent=root->parent;
  // S'il n'y a pas de frère, on le crée
  if(root->next == NULL) return root->next = n;
  // Sinon, on scrute jusqu'au dernier enfant
  for(;next->next!=NULL;next=next->next);
  // Et on l'append
  return next->next=n;
}

