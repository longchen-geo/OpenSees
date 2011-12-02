// $Revision: 1.1 $
// $Date: 2007-06-06 19:34:31 $
// $Source: /usr/local/cvs/OpenSees/SRC/domain/component/TclUpdateMaterialCommand.cpp,v $

// fmk

#include <TclModelBuilder.h>
#include <Domain.h>
#include <MatParameter.h>

#include <string.h>

int
TclCommand_UpdateMaterialsCommand(ClientData clientData, 
				  Tcl_Interp *interp, 
				  int argc,
				  TCL_Char **argv, 
				  TclModelBuilder *theTclBuilder,
				  Domain *theDomain)
{
  opserr << "TclCommand_UpdateMaterialsCommand()\n";

  if (argc < 5) {
    opserr << "WARNING insufficient number of UpdateMaterialStage arguments\n";
    opserr << "Want: UpdateMaterialStage material matTag? stage value?" << endln;
    return TCL_ERROR;
  }
  
  if (strcmp(argv[1],"-material") != 0) {
    opserr << "WARNING UpdateMaterialStage: Only accept parameter '-material' for now" << endln;
    return TCL_ERROR;		
  }		
  
  int materialTag, value;
  double valueD;
  
  if (Tcl_GetInt(interp, argv[2], &materialTag) != TCL_OK) {
    opserr << "WARNING MYSstage: invalid material tag" << endln;
    return TCL_ERROR;		
  }

  int parTag = theDomain->getNumParameters();
  parTag++;

  if (argc > 5) {
    if (strcmp(argv[5],"-parameter") == 0) {
      if (Tcl_GetInt(interp, argv[6], &parTag) != TCL_OK) {
	opserr << "WARNING UpdateMaterialStage: invalid parameter tag" << endln;
	return TCL_ERROR;		
      }
    }
  }	

  MatParameter *theParameter = new MatParameter(parTag, materialTag, argv[3]);

  if (theDomain->addParameter(theParameter) < 0) {
    opserr << "WARNING could not add updateMaterialStage - MaterialStageParameter to domain" << endln;
    return TCL_ERROR;		
  }

  if (Tcl_GetInt(interp, argv[4], &value) != TCL_OK) {
    if (Tcl_GetDouble(interp, argv[4], &valueD) != TCL_OK) {
      opserr << "WARNING UpdateMaterialStage: could not read value" << endln;
      return TCL_ERROR;		
    } else {
      return theDomain->updateParameter(parTag, valueD);
    }
  }

  return theDomain->updateParameter(parTag, value);
}


