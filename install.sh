#/bin/tcsh
#/opt/local/packages/Modules/default/init/sh
#module load intel/17.0.1 openmpi/1.10.5
export SOURCE=`pwd`
export TPL_INSTALL_PREFIX=$SOURCE/inst-tpl
export JALI_INSTALL_PREFIX=$SOURCE/inst-jali
mkdir build-tpl
cd build-tpl
cmake \
    -D CMAKE_C_COMPILER=`which mpicc` \
    -D CMAKE_CXX_COMPILER=`which mpiCC` \
    -D CMAKE_Fortran_COMPILER=`which mpif90` \
    -D DISABLE_EXTERNAL_DOWNLOAD:BOOL=FALSE \
    -D TPL_DOWNLOAD_DIR:PATH=/usr/local/codes/ngc/private/tpl-downloads/ \
    -D TPL_INSTALL_PREFIX=$TPL_INSTALL_PREFIX \
    $SOURCE/config/SuperBuild/
make -j
make install
cd ..
mkdir build-jali
cd build-jali
cmake \
  -C $TPL_INSTALL_PREFIX/share/cmake/Jali-tpl-config.cmake \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_CXX_FLAGS='-std=c++11' \
  -D CMAKE_INSTALL_PREFIX:FILEPATH=$JALI_INSTALL_PREFIX \
  -D HDF5_NO_SYSTEM_PATHS:BOOL=TRUE \
  -D BOOST_ROOT:FILEPATH=$TPL_INSTALL_PREFIX \
  -D ENABLE_MSTK_Mesh:BOOL=TRUE \
  -D ENABLE_STK_Mesh:BOOL=FALSE \
  -D ENABLE_MOAB_Mesh:BOOL=FALSE \
  ${SOURCE}
make -j
#make test
make install
exit