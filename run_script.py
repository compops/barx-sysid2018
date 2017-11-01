"""File for recreating experiments in paper."""

import os
dir_path = os.path.dirname(os.path.realpath(__file__))
print(dir_path)

import python.illustration_gmms as illustration_gmms
import python.example1_arx as example1_arx
import python.example2_arxgmm as example2_arxgmm
import python.example3_eegdata as example3_eegdata

illustration_gmms.run()
example1_arx.run()
example2_arxgmm.run()
example3_eegdata.run()
