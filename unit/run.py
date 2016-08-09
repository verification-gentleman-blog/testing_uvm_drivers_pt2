#!/bin/env python2.7

import argparse
import os

parser = argparse.ArgumentParser(description="Run unit tests")
parser.add_argument("-g", "--gui", help="start in GUI mode",
                    action="store_true")
args = parser.parse_args()

command = ['runSVUnit']
command.append('-s ius')

if args.gui:
    command.append('-c -linedebug')
    command.append('-r -gui')

os.system(' '.join(command))
