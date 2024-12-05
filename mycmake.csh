#!/bin/tcsh

#cmake . -DCMAKE_C_COMPILER=/opt/homebrew/bin/gcc-13 -DCMAKE_CXX_COMPILER=/opt/homebrew/bin/g++-13 -DCMAKE_INSTALL_EXTERNAL_PREFIX=.bmad_external
#cmake . -DCMAKE_INSTALL_EXTERNAL_PREFIX=.bmad_external


if ( -e /home/cfsd/laster/DOWNLOAD/cmake-3.30.6/bin/cmake ) then
    /home/cfsd/laster/DOWNLOAD/cmake-3.30.6/bin/cmake . -DCMAKE_INSTALL_EXTERNAL_PREFIX=.bmad_external
else
    cmake . -DCMAKE_INSTALL_EXTERNAL_PREFIX=.bmad_external
endif
