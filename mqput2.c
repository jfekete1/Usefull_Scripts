/********************************************************************/
/*                                                                  */
/*   MQPUT2 has 1 required input parameter                          */
/*                                                                  */
/*      -f name of the parameter file                               */
/*                                                                  */
/*   Additional parameters can be used to override certain of the   */
/*   parameters in the parameter file, including the message        */
/*   count, queue manager name, queue name and batch size.  The     */
/*   think time parameter can also be overriden for the MQPUTS      */
/*   program.                                                       */
/*                                                                  */
/*   The input parameter file contains all values, including the    */
/*   name of the queue and queue manager to write data to, the      */
/*   total number of messages to write, any MQMD parameters and     */
/*   a list of files which contain the message data.                */
/*                                                                  */
/*   This program can be compiled into two different programs,      */
/*   depending on the setting of the NOTUNE compile option.         */
/*   The normal MQPUT2 program works by periodically observing      */
/*   the depth of a queue and trying to maintain the depth          */
/*   between a low and high water mark.  A sleeptime parameter      */
/*   determines how often the program checks the queue depth.       */
/*                                                                  */
/*   The other version of the program (NOTUNE option selected)      */
/*   does not check the depth of the queue.  It takes a             */
/*   thinktime parameter.  The program will write batchsize         */
/*   messages and then sleep for the thinktime parameter,           */
/*   which is specified in milliseconds.                            */
/*                                                                  */
/********************************************************************/

/********************************************************************/
/*                                                                  */
/* Changes in V1.01                                                 */
/*                                                                  */
/* 1) fixed bug with groupidx parameter overlaying qname.           */
/*                                                                  */
/********************************************************************/

/********************************************************************/
/*                                                                  */
/* Changes in V1.1                                                  */
/*                                                                  */
/* 1) Added support for psc and jms folders in RFH2.                */
/* 2) Added support for Sun Solaris.                                */
/* 3) Use keyword rather than positional arguments.                 */
/*                                                                  */
/********************************************************************/

/********************************************************************/
/*                                                                  */
/* Changes in V1.11                                                 */
/*                                                                  */
/* 1) fixed bug with argument overrides being ignored.              */
/*                                                                  */
/********************************************************************/

/********************************************************************/
/*                                                                  */
/* Changes in V1.20                                                 */
/*                                                                  */
/* 1) Added support for message groups.                             */
/*                                                                  */
/********************************************************************/

/********************************************************************/
/*                                                                  */
/* Changes in V1.21                                                 */
/*                                                                  */
/* 1) Added support for thinktime.                                  */
/*                                                                  */
/********************************************************************/

/********************************************************************/
/*                                                                  */
/* Changes in V1.22                                                 */
/*                                                                  */
/* 1) Formatted start and stop times.                               */
/*                                                                  */
/********************************************************************/

/********************************************************************/
/*                                                                  */
/* Changes in V1.23                                                 */
/*                                                                  */
/* 1) Added checks for malloc failures and total memory used.       */
/*                                                                  */
/********************************************************************/

/********************************************************************/
/*                                                                  */
/* Changes in V1.3                                                  */
/*                                                                  */
/* 1) Added support to use MQMDs saved with the data.               */
/*                                                                  */
/********************************************************************/

/********************************************************************/
/*                                                                  */
/* Changes in V1.31                                                 */
/*                                                                  */
/* 1) Added support for Linux.                                                          */
/*                                                                  */
/********************************************************************/

/********************************************************************/
/*                                                                  */
/* Changes in V1.4                                                  */
/*                                                                  */
/* 1) Added support for Usr folder in RFH2.                             */
/* 2) Added support for folder contents in XML.                     */
/* 3) Split RFH processing into separate module.                    */
/*                                                                  */
/********************************************************************/

/********************************************************************/
/*                                                                  */
/* Changes in V1.5                                                  */
/*                                                                  */
/* 1) Added support for handling break key.                             */
/* 2) Made MQPUTS use think time and MQPUT2 ignore think time.      */
/* 3) Added limited support for latency measurements.               */
/* 4) Added support for global override of think time.              */
/*                                                                  */
/********************************************************************/

/********************************************************************/
/*                                                                  */
/* Changes in V1.6                                                  */
/*                                                                  */
/* 1) Fixed bug where use of rfh=1 or 2 was causing truncation.     */
/* 2) Straightened out routines that read files and handle          */
/*    delimiters.                                   .               */
/* 3) Added routine to release acquired storage before ending.      */
/* 4) Added ignoreMQMD option.                                      */
/*                                                                  */
/********************************************************************/

/********************************************************************/
/*                                                                  */
/* Changes in V1.6.2                                                */
/*                                                                  */
/* 1) Added verbose argument to suppress file messages.             */
/* 2) Fixed problem with MQINQ for cluster queue (rc=2068).         */
/* 3) Fixed problem with start and stop times when using embedded   */
/*    MQMDs in message files.  The elapsed time of the run is now   */
/*    reported.                                                     */
/*                                                                  */
/********************************************************************/

/********************************************************************/
/*                                                                  */
/* Changes in V1.6.3                                                */
/*                                                                  */
/* 1) Corrected bug where FEEDBACK parameter not recognized.        */
/*                                                                  */
/********************************************************************/

/********************************************************************/
/*                                                                  */
/* Changes in V2.0                                                  */
/*                                                                  */
/* 1) Major internal restructing to eliminate global variables.     */
/* 2) Support for all fields in MQMD.                               */
/* 3) Changed some counters to 64-bit integers to avoid overflows;  */
/*                                                                  */
/********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <time.h>
#include "signal.h"

#ifdef WIN32
#include <windows.h>
#endif

#ifdef SOLARIS
#include <ctype.h>
#include <unistd.h>
#include <sys/time.h>
#endif

#ifndef WIN32
void Sleep(int amount)
{
        usleep(amount*1000);
}
#endif

/*************************************************************/
/*                                                           */
/* MY_TIME_T                                                 */
/* The definition of this data type is platform specific.    */
/*                                                           */
/*************************************************************/

#ifdef WIN32
typedef unsigned __int64 MY_TIME_T;
#else
typedef struct timeval MY_TIME_T;
#endif

/* common subroutines include */
#include "int64defs.h"
#include "comsubs.h"

/* parameter file processing routines */
#include "putparms.h"
#include "parmline.h"

/* includes for MQI */
#include <cmqc.h>

/* MQ subroutines include */
#include "qsubs.h"
#include "rfhsubs.h"

static char copyright[] = "(C) Copyright IBM Corp, 2001 - 2009";
static char Version[]=\
"@(#)MQPut2 V2.0 - Message Broker Performance driver test tool  - Jim MacNair ";

#ifdef _DEBUG
static char Level[]="mqput2.c V2.0 Debug version ("__DATE__" "__TIME__")";
#else
#ifdef NOTUNE
#ifdef MQCLIENT
static char Level[]="mqputsc.c V2.0 Client version ("__DATE__" "__TIME__")";
#else
static char Level[]="mqputs.c V2.0 Release version ("__DATE__" "__TIME__")";
#endif
#else
#ifdef MQCLIENT
static char Level[]="mqput2c.c V2.0 Client version ("__DATE__" "__TIME__")";
#else
static char Level[]="mqput2.c V2.0 Release version ("__DATE__" "__TIME__")";
#endif
#endif
#endif

        MQHCONN                 qm=0;                   /* queue manager connection handle */
        MQHOBJ                  q=0;                    /* queue handle used for mqput     */
#ifndef NOTUNE
        MQHOBJ                  Hinq=0;                 /* inquire object handle           */
#endif

        /* global termination switch */
        volatile int    terminate=0;

/*************************************************************/
/*                                                           */
/* GetTime routine to get high precision time.               */
/*                                                           */
/*************************************************************/

#ifdef WIN32
MY_TIME_T GetTime()

{
        MY_TIME_T       count;
        if (!QueryPerformanceCounter((LARGE_INTEGER *)&count))
        {
                count = 0;
        }

        return(count);
}
#else
MY_TIME_T GetTime()


{
        MY_TIME_T       tv;
        gettimeofday(&tv, 0);
        return(tv);
}
#endif

/*********************************************************/
/* DiffTime - difference in microseconds between two     */
/*  high precision times.                                */
/*********************************************************/

#ifdef _WIN32
double DiffTime(MY_TIME_T start, MY_TIME_T end)

{
//      unsigned long diffLong;
        __int64         diff;
        __int64         freq;
        double          usecs;

        /* calulate the difference in the high frequency counter */
        diff = (end - start) * 1000000;

        //diffLong = (unsigned long)(end-start);
        /* get the frequency*/
        QueryPerformanceFrequency((LARGE_INTEGER *)&freq);

        /* calculate the result */

        //usecs = (double)diffLong*1000*1000/freq;
        usecs = (double)diff / freq;

        /* return the result */
        return(usecs);
}
#else
double DiffTime(MY_TIME_T start, MY_TIME_T end)

{
  unsigned long val;
  if (end.tv_usec < start.tv_usec)
  {
      val = 1000000;
      val += start.tv_usec - end.tv_usec;
  }
  else
  {
      val = end.tv_usec - start.tv_usec;
  }
  val += (end.tv_sec - start.tv_sec)*1000000;
  return((double)val/1.0);
}
#endif

/*********************************************************/
/* formatTimeDiffSecs - format a number of seconds       */
/*  resulting from a difference between two times.       */
/*********************************************************/

void formatTimeDiffSecs(char * result, double time)

{
        int             secs=0;
        int             usecs=0;
        int             i;
        char    tempStr[8];

        result[0] = 0;

        /* calculate the average latency */
        secs = (int)(time / 1000000);
        usecs = (int)(time) % 1000000;

        /* get the microseconds as a string */
        sprintf(tempStr, "%6.2d", usecs);

        /* replace any leading blanks with zeros */
        i = 0;
        while ((i < (int)strlen(tempStr)) && (' ' == tempStr[i]))
        {
                tempStr[i] = '0';
                i++;
        }

        /* display the results */
        sprintf(result, "%d.%s", secs, tempStr);
}

/**************************************************************/
/*                                                            */
/* This routine puts a message on the queue.                  */
/*                                                            */
/**************************************************************/

int putMessage(FILEPTR* fptr, 
                           MQCHAR8 *puttime, 
                           int *groupOpen,
                           putParms *parms)

{
        MQLONG  compcode=0;
        MQLONG  reason=0;
        int             minSize;
        MQMD    msgdesc = {MQMD_DEFAULT};
        MQPMO   mqpmo = {MQPMO_DEFAULT};
        MY_TIME_T       perfCounter;            /* high performance counter to measure latency */

        /* check if we are using an mqmd from the file */
        if (fptr->mqmdptr != NULL)
        {
                /* set the get message options */
                if (parms->batchsize > 1)
                {
                        /* use syncpoints */
                        mqpmo.Options = MQPMO_SYNCPOINT | MQPMO_FAIL_IF_QUIESCING;
                }
                else
                {
                        /* no synchpoint, each message as a separate UOW */
                        mqpmo.Options = MQPMO_NO_SYNCPOINT | MQPMO_FAIL_IF_QUIESCING;
                }

                mqpmo.Options |= MQPMO_SET_ALL_CONTEXT;

                if (1 == fptr->newMsgId)
                {
                        mqpmo.Options |= MQPMO_NEW_MSG_ID;
                }

                /* set the MQMD */
                memcpy(&msgdesc, fptr->mqmdptr, sizeof(MQMD));
        }
        else
        {
                /* set the get message options */
                if (parms->batchsize > 1)
                {
                        /* use syncpoints */
                        mqpmo.Options = MQPMO_SYNCPOINT | MQPMO_NEW_MSG_ID | MQPMO_FAIL_IF_QUIESCING;
                }
                else
                {
                        /* no synchpoint, each message as a separate UOW */
                        mqpmo.Options = MQPMO_NO_SYNCPOINT | MQPMO_NEW_MSG_ID | MQPMO_FAIL_IF_QUIESCING;
                }

                if ((1 == fptr->inGroup) || (1 == fptr->lastGroup))
                {
                        mqpmo.Options |= MQPMO_LOGICAL_ORDER;

                        if (1 == fptr->inGroup)
                        {
                                msgdesc.MsgFlags |= MQMF_MSG_IN_GROUP;
                        }

                        if (1 == fptr->lastGroup)
                        {
                                msgdesc.MsgFlags |= MQMF_LAST_MSG_IN_GROUP;
                        }
                }

                /* Indicate V2 of MQMD */
                msgdesc.Version = MQMD_VERSION_2;

                /* set the persistence, etc if specified */
                msgdesc.Persistence = fptr->Persist;
                msgdesc.Encoding = fptr->Encoding;
                msgdesc.CodedCharSetId = fptr->Codepage;

                /* check if message expiry was specified */
                if (fptr->Expiry > 0)
                {
                        msgdesc.Expiry = fptr->Expiry;
                }

                /* check if message type was specified */
                if (fptr->Msgtype > 0)
                {
                        msgdesc.MsgType = fptr->Msgtype;
                }

                /* check if message priority was specified */
                if (fptr->Priority != MQPRI_PRIORITY_AS_Q_DEF)
                {
                        msgdesc.Priority = fptr->Priority;
                }

                /* check if report options were specified */
                if (fptr->Report > 0)
                {
                        msgdesc.Report = fptr->Report;
                }

                /* set the message format in the MQMD was specified */
                switch (fptr->hasRFH)
                {
                case RFH_NO:
                        {
                                if (1 == fptr->FormatSet)
                                {
                                        memcpy(msgdesc.Format, fptr->Format, MQ_FORMAT_LENGTH);
                                }

                                break;
                        }
                case RFH_V1:
                        {
                                memcpy(msgdesc.Format, MQFMT_RF_HEADER, sizeof(msgdesc.Format));
                                break;
                        }
                case RFH_V2:
                        {
                                memcpy(msgdesc.Format, MQFMT_RF_HEADER_2, sizeof(msgdesc.Format));
                                break;
                        }
                case RFH_XML:
                        {
                                memcpy(msgdesc.Format, MQFMT_RF_HEADER_2, sizeof(msgdesc.Format));
                                break;
                        }
                }

                /* check if a reply to queue manager was specified */
                if (fptr->ReplyQM[0] != 0)
                {
                        memset(msgdesc.ReplyToQMgr, 0, sizeof(msgdesc.ReplyToQMgr));
                        memcpy(msgdesc.ReplyToQMgr, fptr->ReplyQM, strlen(fptr->ReplyQM));
                }

                /* check if a reply to queue was specified */
                if (fptr->ReplyQ[0] != 0)
                {
                        memset(msgdesc.ReplyToQ, 0, sizeof(msgdesc.ReplyToQ));
                        memcpy(msgdesc.ReplyToQ, fptr->ReplyQ, strlen(fptr->ReplyQ));
                }

                /* check if a correl id was specified */
                if (1 == fptr->CorrelIdSet)
                {
                        memcpy(msgdesc.CorrelId, fptr->CorrelId, MQ_CORREL_ID_LENGTH);
                }
                else
                {
                        memset(msgdesc.CorrelId, 0, MQ_CORREL_ID_LENGTH);
                }

                /* check if a group id was specified */
                if (1 == (*groupOpen))
                {
                        memcpy(msgdesc.GroupId, parms->saveGroupId, MQ_GROUP_ID_LENGTH);
                }
                else
                {
                        if (1 == fptr->GroupIdSet)
                        {
                                memcpy(msgdesc.GroupId, fptr->GroupId, MQ_GROUP_ID_LENGTH);
                                msgdesc.MsgFlags |= MQMF_LAST_MSG_IN_GROUP | MQMF_MSG_IN_GROUP ;
                        }
                        else
                        {
                                memset(msgdesc.GroupId, 0, sizeof(msgdesc.GroupId));
                        }
                }

                /* check if an accounting token was specified */
                if (1 == fptr->AcctTokenSet)
                {
                        /* set the accounting token value */
                        memcpy(msgdesc.AccountingToken, fptr->AccountingToken, MQ_ACCOUNTING_TOKEN_LENGTH);
                }
        }

        /* check if we are going to replace the front of the message with a timestamp */
        minSize = strlen(parms->qmname) + sizeof(MY_TIME_T) + 1;
        if ((1 == fptr->setTimeStamp) && ((fptr->length - fptr->rfhlen) > minSize))
        {
                perfCounter = GetTime();

                /* insert the performance counter into the first 8 bytes of the message data */
                /* note that this will clobber the first 8 bytes of the message data */
                /* this should only be done if the mqtimes2 program is processing the messages */
                /* and the latency option is selected for mqtimes2 */
                memcpy(fptr->userDataPtr, &perfCounter, sizeof(MY_TIME_T));
                strcpy(fptr->userDataPtr + sizeof(MY_TIME_T), parms->qmname);
        }

        /* perform the MQPUT */
        MQPUT(qm, q, &msgdesc, &mqpmo, fptr->length, fptr->dataptr, &compcode, &reason);

        /* check for errors */
        checkerror("MQPUT", compcode, reason, parms->qname);

        if (0 == compcode)
        {
                /* keep track of the number of bytes we have written */
                parms->byteswritten += fptr->length;
        }

        /* check if this message is part of a group */
        if (1 == fptr->inGroup)
        {
                (*groupOpen) = 1;
        }

        /* check if this is the last message in a group */
        if (1 == fptr->lastGroup)
        {
                (*groupOpen) = 0;
        }

        if ((*groupOpen) == 1)
        {
                memset(parms->saveGroupId, 0, sizeof(parms->saveGroupId));
                memcpy(parms->saveGroupId, msgdesc.GroupId, MQ_GROUP_ID_LENGTH);
        }

        memcpy(puttime, msgdesc.PutTime, sizeof(msgdesc.PutTime));

        return compcode;
}

/**************************************************************/
/*                                                            */
/* This routine gets the number of messages on the queue.     */
/*                                                            */
/**************************************************************/

#ifndef NOTUNE
MQLONG openQueueInq(MQLONG openOpt, MQOD objdesc, const char * qmname, const char * qname, putParms *parms)

{
        MQLONG  compcode;
        MQLONG  reason;
        MQLONG  Select[1];                      /* attribute selectors           */
        MQLONG  IAV[1];                         /* integer attribute values      */
        MQLONG  compcode2;
        MQLONG  reason2;

        MQOPEN(qm,                              /* connection handle              */
                   &objdesc,            /* object descriptor for queue    */
                   openOpt,                     /* open options                   */
                   &Hinq,                       /* object handle for MQINQ        */
                   &compcode,           /* MQOPEN completion code         */
                   &reason);            /* reason code                    */

        checkerror("MQOPEN(Inq)", compcode, reason, qmname);

        if (MQCC_OK == compcode)
        {
                /* try and get the queue depth */
                /*  this will fail if the queue is really a cluster queue */
                Select[0] = MQIA_CURRENT_Q_DEPTH;
                MQINQ(qm,                       /* connection handle                 */
                          Hinq,                 /* object handle                     */
                          1L,                   /* Selector count                    */
                          Select,               /* Selector array                    */
                          1L,                   /* integer attribute count           */
                          IAV,                  /* integer attribute array           */
                          0L,                   /* character attribute count         */
                          NULL,                 /* character attribute array         */
                          /*  note - can use NULL because count is zero      */
                          &compcode2,   /* completion code                   */
                          &reason2);    /* reason code                       */

                /* check for a 2068 return code, indicating that the     */
                /* queue must be open for something besides queue depth. */
                if ((compcode2 != MQCC_OK) && (0 == parms->reopenInq) && (2068 == reason2))
                {
                        /* only try this once */
                        parms->reopenInq = 1;

                        /* close the queue so we can reopen with the browse option added */
                        MQCLOSE(qm, &Hinq, MQCO_NONE, &compcode2, &reason2);
                        Hinq = 0;

                        /* now try to reopen the queue with a browse option as well */
                        openOpt |= MQOO_BROWSE;    /* open to inquire attributes     */
                        
                        /* try the open again */
                        compcode = openQueueInq(openOpt, objdesc, qmname, qname, parms);
                }
        }

        /* check for errors */
        checkerror("MQOPEN(Inq)", compcode, reason, qname);

        return compcode;
}

MQLONG getQueueDepth(const char * qmname)

{
        MQLONG  numOnQueue=0;           /* Number of messages on Queue   */
        MQLONG  Select[1];                      /* attribute selectors           */
        MQLONG  IAV[1];                         /* integer attribute values      */
        MQLONG  compcode;
        MQLONG  reason;

        /* get the current queue depth */
        Select[0] = MQIA_CURRENT_Q_DEPTH;
        MQINQ(qm,                       /* connection handle                 */
                  Hinq,                 /* object handle                     */
                  1L,                   /* Selector count                    */
                  Select,               /* Selector array                    */
                  1L,                   /* integer attribute count           */
                  IAV,                  /* integer attribute array           */
                  0L,                   /* character attribute count         */
                  NULL,                 /* character attribute array         */
                  /*  note - can use NULL because count is zero      */
                  &compcode,    /* completion code                   */
                  &reason);             /* reason code                       */

        checkerror("MQINQ", compcode, reason, qmname);
        if (MQCC_OK == compcode)
        {
                numOnQueue= IAV[0];   /* currdepth */
        }

        return numOnQueue;
}
#endif

/**************************************************************/
/*                                                            */
/* Check if the sleep time is too much or not enough.         */
/*                                                            */
/**************************************************************/

#ifndef NOTUNE
void adjustSleeptime(const int numOnQueue, const int lastdepth, putParms * parms)

{
        int     origSleeptime = parms->sleeptime;
        int minAdjCount;

        /* first, check if the queue is drained */
        if (numOnQueue == 0)
        {
                /* queue is empty, we need to cut the sleeptime */
                parms->sleeptime >>= 1;
        }
        else
        {
                /* check if the counts are the same */
                if (numOnQueue == lastdepth)
                {
                        /* no messages were processed */
                        /* this indicates that we are checking too often */
                        /* increase the sleep time by 50% */
                        parms->sleeptime += (parms->sleeptime >> 1) + 1;
                }
                else
                {
                        /* we don't want to adjust if the rate is high enough */
                        /* first, calculate the difference between the desired */
                        /* and maximum values */
                        minAdjCount = (parms->qmax - parms->qdepth) >> 2;
                        if ((lastdepth > numOnQueue) && ((lastdepth - numOnQueue) < minAdjCount))
                        {
                                /* not enough messages were processed */
                                /* increase the sleeptime by a 12% */
                                parms->sleeptime += (parms->sleeptime >> 3) + 1;
                        }
                }
        }

        /* make sure we are within the allowed limits for sleeptime */
        if (parms->sleeptime < MIN_SLEEP)
        {
                printf(" sleeptime below minimum (%d) - forced to minimum\n", parms->sleeptime);
                parms->sleeptime = MIN_SLEEP;
        }

        if (parms->sleeptime > MAX_SLEEP)
        {
                printf(" sleeptime above maximum (%d) - forced to maximum\n", parms->sleeptime);
                parms->sleeptime = MAX_SLEEP;
        }

        /* tell what we did */
        if (origSleeptime != parms->sleeptime)
        {
#ifdef WIN32
                printf(" sleeptime changed from %d to %d milliseconds numOnQueue %d lastdepth %d written %I64d\n", 
                                origSleeptime, parms->sleeptime, numOnQueue, lastdepth, parms->msgwritten);
#else
                printf(" sleeptime changed from %d to %d milliseconds numOnQueue %d lastdepth %d written %lld\n", 
                                origSleeptime, parms->sleeptime, numOnQueue, lastdepth, parms->msgwritten);
#endif
        }
}
#endif

/**************************************************************/
/*                                                            */
/* Subroutine to format a time.                               */
/*                                                            */
/* The input time should be 8 numbers (hhmmsshh)              */
/*                                                            */
/**************************************************************/

void formatTime(char *timeOut, char *timeIn)

{
        timeOut[0] = timeIn[0];
        timeOut[1] = timeIn[1];
        timeOut[2] = ':';
        timeOut[3] = timeIn[2];
        timeOut[4] = timeIn[3];
        timeOut[5] = ':';
        timeOut[6] = timeIn[4];
        timeOut[7] = timeIn[5];
        timeOut[8] = ':';
        timeOut[9] = timeIn[6];
        timeOut[10] = timeIn[7];
        timeOut[11] = 0;
}

void InterruptHandler (int sigVal) 

{ 
        /* issue message indicating user cancelled the program */
        printf("Program terminated by user\n");

        /* set a switch to terminate the program */
        terminate = 1;
}

/**************************************************************/
/*                                                            */
/* Display command format.                                    */
/*                                                            */
/**************************************************************/

void printHelp(char *pgmName)

{
        printf("%s\n", Level);
        printf("format is:\n");
#ifdef NOTUNE
        printf("  %s -f parm_file {-v} {-m QMgr} {-q queue} {-c count} {-b batchsize} {-p} {-t thinktime}\n", pgmName);
#else
        printf("  %s -f parm_file {-v} {-m QMgr} {-q queue} {-c count} {-b batchsize} {-p}\n", pgmName);
#endif
        printf("   parm_file is the fully qualified name of the parameters file\n");
        printf("   -v verbose\n");
        printf("   Overrides\n");
        printf("   -m name of queue manager\n");
        printf("   -q name of queue\n");
        printf("   -c message count\n");
        printf("   -b batch size\n");
        printf("   -p purge queue before writing messages\n");
#ifdef NOTUNE
        printf("   -t think time\n");
#endif
}

int main(int argc, char **argv)

{
        int                     uowcount=0;
        int                     groupOpen = 0;
        int                     notDone;
        MQLONG          compcode;
        MQLONG          reason;
        MQOD            objdesc = {MQOD_DEFAULT};
        MQLONG          openopt = 0;
        MQLONG          datalen=0;
        MQLONG          maxMsgLen=0;
        int                     numWrittenMin=-1;
        int                     numWrittenMax=0;
        int                     iElapsed=0;
        int64_t         MsgsAtLastInterval=0;
        int64_t         lastInterval;
#ifndef NOTUNE
        int                     numOnQueueMin=0;
        int                     numOnQueueMax=0;
        int                     writeCount;
        int                     lastdepth;
        int64_t         saveCount;
        MQLONG          numOnQueue;                                     /* Number of messages on Queue   */
        MQLONG          O_optionsq;                                     /* inquire MQOPEN options        */
#endif
        MQCHAR8         puttime;
        char            formTime[16];
        char            *msgdata;
        MY_TIME_T       startTime;
        MY_TIME_T       endTime;
        MY_TIME_T       prevTime;
        time_t          startTOD;
        time_t          endTOD;
        double          elapsed=0.0;
        double          avgrate;
        FILEPTR         *fptr=NULL;
        FILEPTR         *fileptr;
        putParms        parms;

        printf(Level);

        /* print the copyright statement */
        printf("\nCopyright (c) IBM Corp., 2001-2008\n");

        /* initialize the work areas */
        initializeParms(&parms);

        /* check for too few input parameters */
        if (argc < 2)
        {
                printHelp(argv[0]);
                exit(99);
        }

        /* check for help request */
        if ((argv[1][0] == '?') || (argv[1][1] == '?'))
        {
                printHelp(argv[0]);
                exit(0);
        }

        /* process any command line arguments */
        processArgs(argc, argv, &parms);

        if (parms.err != 0)
        {
                printHelp(argv[0]);
                exit(99);
        }

        /* process the parameters file data */
        fptr = processParmFile(parms.parmFilename, &parms);

        /* start with the first message */
        fileptr = fptr;

        /* check for overrides */
        processOverrides(&parms);

        /* check if we found any message data files */
        if (NULL == fptr)
        {
                printf("***** No message data files found - program terminating\n");
                return 94;
        }

        if (parms.err != 0)
        {
                printf("***** Error detected (err=%d) - program terminating\n", parms.err);
                return parms.err;
        }

        /* tell how many files and messages we found */
        printf("Total files read %d\n", parms.fileCount);
        printf("Total messages found %d\n", parms.mesgCount);

        /* explain what parameters are being used */
#ifdef WIN32
        printf("\n%I64d messages to be written to queue %s on queue manager %s\n", parms.totcount, &(parms.qname), &(parms.qmname));
#else
        printf("\n%lld messages to be written to queue %s on queue manager %s\n", parms.totcount, &(parms.qname), &(parms.qmname));
#endif

        if (1 == parms.setTimeStamp)
        {
                /* indicate that we are adding a timestamp to the message */
                printf("Some data in message will be overlaid with time stamp\n");
        }

#ifdef NOTUNE
        printf("thinkTime = %d batchsize = %d\n", parms.thinkTime, parms.batchsize);
#else
        printf("minimum queue depth %d max %d batchsize %d\n", parms.qdepth, parms.qmax, parms.batchsize);
        printf("initial sleep time %d tune = %d\n", parms.sleeptime, parms.tune);
#endif

        /* set a termination handler */
        signal(SIGINT, InterruptHandler);

        /* Connect to the queue manager */
#ifdef MQCLIENT
        clientConnect2QM((char *)&(parms.qmname), &qm, &maxMsgLen, &compcode, &reason);
#else
        connect2QM((char *)&(parms.qmname), &qm, &compcode, &reason);
#endif

        /* check for errors */
        if (compcode != MQCC_OK)
        {
                return 98;
        }

        /* set the queue open options */
        strcpy(objdesc.ObjectName, parms.qname);
        strcpy(objdesc.ObjectQMgrName, parms.remoteQM);
        openopt = MQOO_OUTPUT + MQOO_FAIL_IF_QUIESCING;

        /* check if we need to set all context */
        if (1 == parms.foundMQMD)
        {
                openopt |= MQOO_SET_ALL_CONTEXT;
        }

        /* open the queue for output */
        printf("opening queue %s for output\n", parms.qname);
        MQOPEN(qm, &objdesc, openopt, &q, &compcode, &reason);

        /* check for errors */
        checkerror("MQOPEN", compcode, reason, parms.qname);
        if (compcode != MQCC_OK)
        {
                return 97;
        }

#ifdef NOTUNE
        /**************************************************************/
        /*                                                            */
        /*   Check if all the messages have been written              */
        /*                                                            */
        /**************************************************************/

        if (parms.msgwritten < parms.totcount)
        {
                notDone = 1;
        }
        else
        {
                notDone = 0;
        }
#else
        /**************************************************************/
        /*                                                            */
        /*   Open named queue for INQUIRE                             */
        /*                                                            */
        /**************************************************************/

        O_optionsq = MQOO_INQUIRE    /* open to inquire attributes     */
                                 + MQOO_FAIL_IF_QUIESCING;

        /* open the queue for inquiry */
        compcode = openQueueInq(O_optionsq, objdesc, parms.qmname, parms.qname, &parms);

        if (compcode != MQCC_OK)
        {
                return 96;
        }

        numOnQueue = getQueueDepth(parms.qmname);

        /**************************************************************/
        /*                                                            */
        /*   Check if all the messages have been written              */
        /*                                                            */
        /**************************************************************/

        if (((parms.msgwritten + numOnQueue) < parms.qmax) && (parms.msgwritten < parms.totcount))
        {
                notDone = 1;
        }
        else
        {
                notDone = 0;
        }
#endif

        /* remember the starting time */
        startTime = GetTime();
        prevTime = GetTime();

        /* if monitoring queue depth top up the queue to hold qmax messages */
        /* prime the queue with an initial number of messages               */
        /* After this, we will monitor the queue depth and                  */
        /* try to keep the queue depth at a specified amount                */
        /* if not monitoring queue depth this loop writes all the messages  */
        while ((compcode == MQCC_OK) && (1 == notDone) && (0 == terminate))
        {
                /* get the data pointer and length from the next message */
                datalen = fileptr->length;
                msgdata = fileptr->dataptr;

                /* perform the MQPUT */
                compcode = putMessage(fileptr,
                                                          &puttime,
                                                          &groupOpen,
                                                          &parms);

                /* check for errors */
                if (compcode == MQCC_OK)
                {
                        if (0 == parms.msgwritten)
                        {
                                /* write out the time the first messsage was sent */
                                time(&startTOD);
                                printf("First message written at %s\n", ctime(&startTOD));

                                /* write out the time of the first message */
                                formatTime(formTime, puttime);
                                printf("MQ Timestamp of first message written at %8.8s\n", formTime);
                        }

                        /* increment the message count */
                        parms.msgwritten++;

                        /* remember how many messages are in this uow */
                        uowcount++;

                        /* check if we are supposed to report progress */
                        if ((parms.reportEvery > 0) && ((parms.msgwritten % parms.reportEvery) == 0))
                        {
                                /* report the time to put a given number of messages */
                                /* calculate the amount of time it took */
                                elapsed = DiffTime(prevTime, GetTime());

                                /* update the time for the next interval */
                                prevTime = GetTime();

                                /* format the difference as a string (seconds and 6 decimal places) */
                                formatTimeDiffSecs(formTime, elapsed);

                                if (elapsed > 0.0)
                                {
                                        /* avoid any 32-bit overflows */
                                        lastInterval = parms.msgwritten - MsgsAtLastInterval;
                                        lastInterval *= 1000000;

                                        /* get the message rate */
                                        avgrate = (double)(lastInterval / elapsed);

                                        /* convert the rate to a 64-bit integer */
                                        lastInterval = (int64_t)avgrate;

                                        /* write out the time it took to write the messages */
#ifdef WIN32
                                        printf("%I64d messages written in %s seconds rate %I64d\n", parms.msgwritten - MsgsAtLastInterval, formTime, lastInterval);
#else
                                        printf("%lld messages written in %s seconds rate %lld\n", parms.msgwritten - MsgsAtLastInterval, formTime, lastInterval);
#endif
                                }
                                else
                                {
                                        /* write out the time it took to write the messages without the rate */
#ifdef WIN32
                                        printf("%I64d messages written in %s seconds\n", parms.msgwritten - MsgsAtLastInterval, formTime);
#else
                                        printf("%lld messages written in %s seconds\n", parms.msgwritten - MsgsAtLastInterval, formTime);
#endif
                                }

                                /* remember the count at the beginning of the next interval */
                                MsgsAtLastInterval = parms.msgwritten;
                        }

#ifdef NOTUNE
                        /* was a think time specified? */
                        if ((fileptr->thinkTime > 0) && (0 == groupOpen))
                        {
                                /* do not do a commit if batchsize is > 1 and we have not written that many messages */
                                if ((parms.batchsize <= 1) || (uowcount >= parms.batchsize))
                                {
                                        /* commit the message */
                                        MQCMIT(qm, &compcode, &reason);
                                        checkerror("MQCMIT", compcode, reason, parms.qname);
                                        uowcount = 0;

                                        /* delay the amount specified by the think time parameter */
                                        Sleep(fileptr->thinkTime);
                                }
                        }
#endif

                        /* move on to the next message file */
                        fileptr = (FILEPTR *)fileptr->nextfile;
                        if (NULL == fileptr)
                        {
                                /* go back to the first message data file */
                                fileptr = fptr;
                        }

                        /* check if we nee to issue a commit */
                        /* if a group is in progress */
                        /* make sure to commit only after */
                        /* the group is finished */
                        if ((parms.batchsize > 1) && (uowcount >= parms.batchsize) && (0 == groupOpen))
                        {
                                MQCMIT(qm, &compcode, &reason);
                                checkerror("MQCMIT", compcode, reason, parms.qname);
                                uowcount = 0;
                        }
                }

#ifdef NOTUNE
                if (parms.msgwritten >= parms.totcount)
                {
                        /* end as soon as the group is finished */
                        notDone = groupOpen;
                }
#else
                if (((parms.msgwritten + numOnQueue) >= parms.qmax) || (parms.msgwritten >= parms.totcount))
                {
                        /* end as soon as the group is finished */
                        notDone = groupOpen;
                }
#endif
        } /* while */

        if (uowcount > 0)
        {
                MQCMIT(qm, &compcode, &reason);
                checkerror("MQCMIT", compcode, reason, parms.qname);
                uowcount = 0;
        }

#ifndef NOTUNE
        /* give the initial number of messages written */
        if (parms.tune == 1)
        {
#ifdef WIN32
                printf("initial number of messages written %I64d\n", parms.msgwritten);
#else
                printf("initial number of messages written %lld\n", parms.msgwritten);
#endif
        }

        /* enter message loop */
        if (parms.msgwritten < parms.totcount)
        {
                notDone = 1;
        }
        else
        {
                notDone = 0;
        }

        /* start the main loop */
        while ((compcode == MQCC_OK) && (1 == notDone) && (0 == parms.err) && (0 == terminate))
        {
                /* initialize the last depth variable */
                lastdepth = getQueueDepth(parms.qmname);

                /* issue a wait for sleeptime milliseconds */
                Sleep(parms.sleeptime); /*sleep in millisecs*/

                /* get the current queue depth */
                numOnQueue = getQueueDepth(parms.qmname);

                /* remember the minimum and maximum counts */
                if ((numOnQueueMax == 0) || (numOnQueue < numOnQueueMin))
                {
                        numOnQueueMin = numOnQueue;
                }

                if (numOnQueue > numOnQueueMax)
                {
                        numOnQueueMax = numOnQueue;
                }

                /* issue error message if we find no messages on queue */
                if (numOnQueue == 0)
                {
#ifdef WIN32
                        printf("***** warning - no messages on queue after %I64d msgs written\n", parms.msgwritten);
#else
                        printf("***** warning - no messages on queue after %lld msgs written\n", parms.msgwritten);
#endif
                        printf("***** decrease sleeptime parameter from %d\n", parms.sleeptime);
                }

                /* check if we are tuning the sleeptime parameter */
                if (1 == parms.tune)
                {
                        /* give the current message count */
                        printf("number on queue %d, lastdepth %d\n", numOnQueue, lastdepth);

                        /* check if we want to adjust the sleep time */
                        adjustSleeptime(numOnQueue, lastdepth, &parms);
                }

                /* check if we are below the minimum depth */
                if (numOnQueue < parms.qdepth)
                {
                        /* check if we need to update our max and min statistics */
                        writeCount = parms.qdepth - numOnQueue;
                        if ((-1 == numWrittenMin) || (writeCount < numWrittenMin))
                        {
                                numWrittenMin = writeCount;
                        }

                        if (writeCount > numWrittenMax)
                        {
                                numWrittenMax = writeCount;
                        }

                        /* remember the number of messages written previously */
                        saveCount = parms.msgwritten;

                        /* check the depth of the queue */
                        while ((MQCC_OK == compcode) && (numOnQueue < parms.qmax) && (parms.msgwritten < parms.totcount) && (0 == terminate))
                        {
                                /* get the data pointer and length from the next message */
                                datalen = fileptr->length;
                                msgdata = fileptr->dataptr;

                                /* perform the MQPUT */
                                compcode = putMessage(fileptr, 
                                                                          &puttime, 
                                                                          &groupOpen,
                                                                          &parms);

                                /* check for errors */
                                if (MQCC_OK == compcode)
                                {
                                        if (0 == parms.msgwritten)
                                        {
                                                /* write out the time the first messsage was sent */
                                                time(&startTOD);
                                                printf("First message written at %s\n", ctime(&startTOD));

                                                /* write out the time of the first message */
                                                formatTime(formTime, puttime);
                                                printf("MQ Timestamp of first message written at %8.8s\n", formTime);
                                        }

                                        /* check if we are supposed to report progress */
                                        if ((parms.reportEvery > 0) && ((parms.msgwritten % parms.reportEvery) == 0))
                                        {
                                                /* report the time to put a given number of messages */
                                                /* calculate the amount of time it took */
                                                elapsed = DiffTime(prevTime, GetTime());

                                                /* update the time for the next interval */
                                                prevTime = GetTime();

                                                /* format the difference as a string (seconds and 6 decimal places) */
                                                formatTimeDiffSecs(formTime, elapsed);

                                                if (elapsed > 0.0)
                                                {
                                                        lastInterval = parms.msgwritten - MsgsAtLastInterval;
                                                        lastInterval *= 1000000;

                                                        /* get the message rate */
                                                        avgrate = (double)(lastInterval / elapsed);

                                                        /* convert the rate to a 64-bit integer */
                                                        lastInterval = (int64_t)avgrate;

                                                        /* write out the time it took to write the messages */
#ifdef WIN32
                                                        printf("%I64d messages written in %s seconds rate %I64d\n", parms.msgwritten - MsgsAtLastInterval, formTime, lastInterval);
#else
                                                        printf("%lld messages written in %s seconds rate %lld\n", parms.msgwritten - MsgsAtLastInterval, formTime, lastInterval);
#endif
                                                }
                                                else
                                                {
                                                        /* write out the time it took to write the messages without the rate */
#ifdef WIN32
                                                        printf("%I64d messages written in %s seconds\n", parms.msgwritten - MsgsAtLastInterval, formTime);
#else
                                                        printf("%lld messages written in %s seconds\n", parms.msgwritten - MsgsAtLastInterval, formTime);
#endif
                                                }

                                                /* remember the count at the beginning of the next interval */
                                                MsgsAtLastInterval = parms.msgwritten;
                                        }

                                        /* move on to the next message file */
                                        fileptr = (FILEPTR *)fileptr->nextfile;
                                        if (NULL == fileptr)
                                        {
                                                /* go back to the first message data file */
                                                fileptr = fptr;
                                        }

                                        /* increment the message count and uow counter */
                                        parms.msgwritten++;
                                        numOnQueue++;
                                        uowcount++;

                                        /* check if we need to issue a commit */
                                        if ((parms.batchsize > 1) && (uowcount >= parms.batchsize))
                                        {
                                                MQCMIT(qm, &compcode, &reason);
                                                checkerror("MQCMIT", compcode, reason, parms.qname);
                                                uowcount = 0;
                                        }
                                }
                        }

                        /* commit the messages we have just written */
                        if ((parms.batchsize > 1) && (uowcount > 0))
                        {
                                MQCMIT(qm, &compcode, &reason);
                                checkerror("MQCMIT", compcode, reason, parms.qname);
                                uowcount = 0;
                        }

                        if (1 == parms.tune)
                        {
#ifdef WIN32
                                printf("%I64d messages written to queue\n",parms.msgwritten - saveCount);
#else
                                printf("%lld messages written to queue\n",parms.msgwritten - saveCount);
#endif
                        }
                }

                if (parms.msgwritten >= parms.totcount)
                {
                        /* make sure we do not end in the middle of a group */
                        notDone = groupOpen;
                }
        }

        /* check if tuning of the sleep time was requested */
        if (1 == parms.tune)
        {
                /* write out the final sleep time value */
                printf("final sleep time value %d\n", parms.sleeptime);
        }

        /* write out the minimum and maximum number of messages on the queue */
        printf("number on queue after sleep - min %d, max %d\n", numOnQueueMin, numOnQueueMax);
#endif

        /* remember the ending time */
        endTime = GetTime();

        /* write out the time the first messsage was sent */
        time(&endTOD);
        printf("Last message written at %s\n", ctime(&endTOD));

        /* write out the MQ timestamp of the last message */
        formatTime(formTime, puttime);
        printf("MQ timestamp of last message written at %8.8s\n", formTime);

        /* dump out the total message count */
#ifdef WIN32
        printf("\nTotal messages written %I64d out of %d\n", parms.msgwritten, parms.totcount);
#else
        printf("\nTotal messages written %lld out of %d\n", parms.msgwritten, parms.totcount);
#endif

        if (parms.msgwritten > 0)
        {
                /* calculate the total elapsed time */
                elapsed = DiffTime(startTime, endTime);
                formatTimeDiffSecs(formTime, elapsed);
                printf("Total elapsed time in seconds %s\n", formTime);
        }

#ifdef WIN32
        printf("Total bytes written   %I64d\n", parms.byteswritten);
#else
        printf("Total bytes written   %lld\n", parms.byteswritten);
#endif

        printf("Total memory used %d\n", parms.memUsed);
#ifndef NOTUNE
        if (numWrittenMax > 0)
        {
                printf("Messages written in interval  min=%d max=%d\n", numWrittenMin, numWrittenMax);
        }
#endif

        /* close the input queue */
        printf("\nclosing the queue\n");
        MQCLOSE(qm, &q, MQCO_NONE, &compcode, &reason);

        checkerror("MQCLOSE", compcode, reason, parms.qname);

#ifndef NOTUNE
        /* close the inquiry queue handle */
        printf("closing the inquiry queue\n");
        MQCLOSE(qm, &Hinq, MQCO_NONE, &compcode, &reason);

        checkerror("MQCLOSE", compcode, reason, parms.qname);
#endif

        /* Disconnect from the queue manager */
        printf("disconnecting from the queue manager\n");
        MQDISC(&qm, &compcode, &reason);

        checkerror("MQDISC", compcode, reason, parms.qmname);

        /* release any storage used for RFH areas */
        releaseRFH(&parms);

        /* release any storage we acquired for files */
        fileptr = fptr;
        while (fileptr != NULL)
        {
                /* do we have any acquired storage associated with this control block */
                if (fileptr->acqStorAddr != NULL)
                {
                        /* release the acquired storage */
                        free(fileptr->acqStorAddr);
                }

                /* remember the address of the current control block */
                fptr = fileptr;

                /* move on to the next control block */
                fileptr = (FILEPTR *)fileptr->nextfile;

                /* release the FILEPTR control block */
                free(fptr);
        }

        /******************************************************************/
        /*                                                                */
        /* END OF PROGRAM                                                 */
        /*                                                                */
        /******************************************************************/

#ifdef NOTUNE
        printf("MQPUTS program ended\n");
#else
        printf("MQPUT2 program ended\n");
#endif


        return(0);
}
