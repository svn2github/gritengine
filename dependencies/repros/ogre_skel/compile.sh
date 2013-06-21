#!/bin/bash

g++ -g repro.c++ -o repro.ogre  `pkg-config OGRE --libs --cflags`
