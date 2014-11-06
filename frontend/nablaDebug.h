/*****************************************************************************
 * File : nccDbg.h
 *****************************************************************************
 * Date	 Author		Description
 * 100105 camierjs	Initial version
 *****************************************************************************/
#ifndef _NCC_DBG_H_
#define _NCC_DBG_H_

#define	DBG_OFF		0x0000ul // Debug off
#define	DBG_EMG		0x0001ul // system is unusable
#define	DBG_ALR		0x0002ul // action must be taken immediately
#define	DBG_CTL		0x0004ul // critical conditions
#define	DBG_ERR		0x0008ul // error conditions
#define	DBG_SYS		0x000Ful
			
#define	DBG_WNG		0x0010ul // warning conditions
#define	DBG_NTC		0x0020ul // normal but significant condition
#define	DBG_LOG		0x0040ul // debug-level messages
#define	DBG_LOW		0x0080ul
#define	DBG_STD		0x00F0ul
	
#define	DBG_HASH		0x0100ul
#define	DBG_MODULO	0x0200ul
#define	DBG_CYC		0x0400ul
#define	DBG_DBG		0x0800ul
#define	DBG_DEBUG	0x0F00ul
	
#define	DBG_ALL		0xFFFFul

#define NCC_DBG_STD_LVL DBG_OFF

void dbgt(const bool flag, const int fd, const char *msg, ...);
NABLA_STATUS dbg(const char *str, ...);
void printfdbg(const char *str, ...);

void dbgOpenTraceFile(const char *file);
void dbgCloseTraceFile(void);

unsigned long dbgGet(void);
unsigned long dbgSet(unsigned long flg);

void busy(unsigned long flg);

void ncc_printff(const char *str, ...);

bool ncc_key_q(void);


#endif // _NABLA_DBG_H_