#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"


#include <libxml/xmlmemory.h>
#include <libxml/tree.h>
#include <libxml/valid.h>
#include <libxml/xpath.h>
#include <libxml/xpathInternals.h>
#include <libxml/parserInternals.h>
#include <libxml/hash.h>
#include <libxml/xpointer.h>
#include <libxml/debugXML.h>
#include <libxml/xmlerror.h>
#include <libxml/threads.h>
#include <libxml/globals.h>
#include <libxml/pattern.h>


static void
xmlXPathEndsWithFunction (xmlXPathParserContextPtr ctxt, int nargs) 
{
  xmlXPathObjectPtr hay, needle;
  int m, n; 
  int v = 0;

  CHECK_ARITY (2);

  CAST_TO_STRING;
  CHECK_TYPE (XPATH_STRING);
  needle = valuePop (ctxt);

  CAST_TO_STRING;
  hay = valuePop (ctxt);

  if ((hay == NULL) || (hay->type != XPATH_STRING)) 
    {
      xmlXPathFreeObject (hay); 
      xmlXPathFreeObject (needle);
      XP_ERROR (XPATH_INVALID_TYPE);
    }

  m = xmlStrlen (hay->stringval);
  n = xmlStrlen (needle->stringval);

  if (m >= n) 
    if (! xmlStrncmp (hay->stringval + (m - n), needle->stringval, n)) 
      v = 1;

  valuePush (ctxt, xmlXPathNewBoolean (v));

  xmlXPathFreeObject (hay); 
  xmlXPathFreeObject (needle);
}


static void
xmlXPathStringJoinFunction(xmlXPathParserContextPtr ctxt, int nargs) 
{
  xmlXPathObjectPtr nodeset = NULL, separator = NULL;
  xmlChar * res = NULL; 
  const xmlChar * sep = NULL;

  switch (nargs)
    {
      case 1:
        CHECK_ARITY(1);
        break;
      default:
        CHECK_ARITY(2);
    }

  if (nargs == 2)
    {
      CAST_TO_STRING;
      CHECK_TYPE (XPATH_STRING);
      separator = valuePop (ctxt);
    }

  nodeset = valuePop (ctxt);

  if ((nodeset == NULL) ||
      ((nodeset->type != XPATH_NODESET) &&
       (nodeset->type != XPATH_XSLT_TREE)))
      XP_ERROR (XPATH_INVALID_TYPE);

  if (separator != NULL) 
    sep = separator->stringval;
  else
    sep = "";

  if ((nodeset->nodesetval != NULL) &&
      (nodeset->nodesetval->nodeTab != NULL)) 
    {
      xmlNodePtr cur;
      
      int len = 0, n = 0, i, j, k;

      for (i = 0, n = 0; i < nodeset->nodesetval->nodeNr; i++)
        {
          xmlNodePtr cur = nodeset->nodesetval->nodeTab[i];
          if (cur->content)
            {
              len += xmlStrlen (cur->content); 
              n++;
            }
        }

      len += (n - 1) * xmlStrlen (sep);

      res = xmlMalloc ((len + 1) * sizeof (xmlChar));

      for (i = 0, j = 0; i < nodeset->nodesetval->nodeNr; i++)
        {
          xmlNodePtr cur = nodeset->nodesetval->nodeTab[i];
          if (cur->content)
            {
              for (k = 0; k < xmlStrlen (cur->content); k++, j++)
                res[j] = cur->content[k];
              for (k = 0; k < xmlStrlen (sep); k++, j++)
                res[j] = sep[k];
            }
      
        }

      res[len] = 0;
    } 
  else 
    {
      res = xmlMalloc (1);
      res[0] = 0;
    }


  valuePush (ctxt, xmlXPathNewString (res));

  xmlXPathFreeObject (nodeset); 

  if (separator != NULL)
    xmlXPathFreeObject (separator); 
}


MODULE = XML::LibXML::MoreFunctions		PACKAGE = XML::LibXML::MoreFunctions		


void
registerFunctions (sv)
        SV * sv
    INIT:
        xmlXPathContextPtr ctxt = INT2PTR (xmlXPathContextPtr, SvIV (SvRV (sv)));
        if (ctxt == NULL) 
          croak ("XPathContext: missing xpath context\n");
    CODE:
        xmlXPathRegisterFunc (ctxt, (const xmlChar *)"ends-with", xmlXPathEndsWithFunction);
        xmlXPathRegisterFunc (ctxt, (const xmlChar *)"string-join", xmlXPathStringJoinFunction);

