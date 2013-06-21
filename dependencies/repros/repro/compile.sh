#!/bin/bash

g++ -g repro.c++ -DOGRE_MEMORY_ALLOCATOR=1 `pkg-config --cflags --libs OGRE` -o repro
