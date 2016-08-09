#!/bin/env python2.7

import argparse
import os

parser = argparse.ArgumentParser(description="Run unit tests")
args = parser.parse_args()

command = ['runSVUnit']
command.append('-s ius')

os.system(' '.join(command))
