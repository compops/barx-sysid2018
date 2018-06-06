"""File for recreating experiments in paper."""
import sys

import python.illustration_gmms as illustration_gmms
import python.example1_arx as example1_arx
import python.example2_arxgmm as example2_arxgmm
import python.example3_eegdata as example3_eegdata

if len(sys.argv) > 1:
    if int(sys.argv[1]) == 0:
        illustration_gmms.run()
    elif int(sys.argv[1]) == 1:
        example1_arx.run()
    elif int(sys.argv[1]) == 2:
        example2_arxgmm.run()
    elif int(sys.argv[1]) == 3:
        example3_eegdata.run()
    else:
        raise NameError("Unknown example to run...")
else:
    raise NameError("Need to supply an argument to function call (0, 1, 2, 3) corresponding to the numerical illustration to run.")
