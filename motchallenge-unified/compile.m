mex utils/assignmentoptimal.c -outdir utils
mex utils/clearMOTMex.cpp -outdir utils
mex utils/costBlockMex.cpp -outdir utils COMPFLAGS="/openmp $COMPFLAGS"