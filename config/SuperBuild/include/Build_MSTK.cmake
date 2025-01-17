# Copyright (c) 2019, Triad National Security, LLC
# All rights reserved.

# Copyright 2019. Triad National Security, LLC. This software was
# produced under U.S. Government contract 89233218CNA000001 for Los
# Alamos National Laboratory (LANL), which is operated by Triad
# National Security, LLC for the U.S. Department of Energy. 
# All rights in the program are reserved by Triad National Security,
# LLC, and the U.S. Department of Energy/National Nuclear Security
# Administration. The Government is granted for itself and others acting
# on its behalf a nonexclusive, paid-up, irrevocable worldwide license
# in this material to reproduce, prepare derivative works, distribute
# copies to the public, perform publicly and display publicly, and to
# permit others to do so
 
# 
# This is open source software distributed under the 3-clause BSD license.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
# 
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of Triad National Security, LLC, Los Alamos
#    National Laboratory, LANL, the U.S. Government, nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.

 
# THIS SOFTWARE IS PROVIDED BY TRIAD NATIONAL SECURITY, LLC AND
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
# TRIAD NATIONAL SECURITY, LLC OR CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#
# Build TPL: MSTK 
#    
# --- Define all the directories and common external project flags
define_external_project_args(MSTK
                             TARGET mstk
                             DEPENDS ${MPI_PROJECT} HDF5 NetCDF ExodusII METIS Trilinos)

# add version version to the autogenerated tpl_versions.h file
jali_tpl_version_write(FILENAME ${TPL_VERSIONS_INCLUDE_FILE}
                         PREFIX MSTK
                         VERSION ${MSTK_VERSION_MAJOR} ${MSTK_VERSION_MINOR} ${MSTK_VERSION_PATCH})

# --- Patch the original code
#set(MSTK_patch_file mstk-findhdf5.patch)
#set(MSTK_sh_patch ${MSTK_prefix_dir}/mstk-patch-step.sh)
#configure_file(${SuperBuild_TEMPLATE_FILES_DIR}/mstk-patch-step.sh.in
#               ${MSTK_sh_patch}
#               @ONLY)
#
## configure the CMake patch step
#set(MSTK_cmake_patch ${MSTK_prefix_dir}/mstk-patch-step.cmake)
#configure_file(${SuperBuild_TEMPLATE_FILES_DIR}/mstk-patch-step.cmake.in
#               ${MSTK_cmake_patch}
#               @ONLY)
#
## set the patch command
#set(MSTK_PATCH_COMMAND ${CMAKE_COMMAND} -P ${MSTK_cmake_patch})

# --- Define the configure parameters
# compile flags
set(mstk_cflags_list -I${TPL_INSTALL_PREFIX}/include ${Jali_COMMON_CFLAGS})
build_whitespace_string(mstk_cflags ${mstk_cflags_list})

set(mstk_ldflags_list -L${TPL_INSTALL_PREFIX}/lib ${MPI_C_LIBRARIES})
build_whitespace_string(mstk_ldflags ${mstk_ldflags_list})


# The CMake cache args
set(MSTK_CMAKE_CACHE_ARGS
		    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
                    -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
                    -DCMAKE_C_FLAGS:STRING=${mstk_cflags}
                    -DCMAKE_EXE_LINKER_FLAGS:STRING=${mstk_ldflags}
		    -DPREFER_STATIC_LIBRARIES:BOOL=${PREFER_STATIC_LIBRARIES}
                    -DENABLE_PARALLEL:BOOL=TRUE
		    -DMSTK_USE_MARKERS:BOOL=FALSE  
                    -DENABLE_ExodusII:BOOL=TRUE
                    -DENABLE_ZOLTAN:BOOL=TRUE
                    -DENABLE_METIS:BOOL=TRUE
                    -DMETIS_MAJOR_VER:STRING=5
                    -DHDF5_ROOT:PATH=${TPL_INSTALL_PREFIX}
                    -DHDF5_NO_SYSTEM_PATHS:BOOL=TRUE
                    -DNetCDF_DIR:PATH=${TPL_INSTALL_PREFIX} 
                    -DExodusII_DIR:PATH=${TPL_INSTALL_PREFIX} 
                    -DZOLTAN_DIR:PATH=${Zoltan_INSTALL_PREFIX}
                    -DMetis_DIR:PATH=${METIS_DIR} 
                    -DMETIS_DIR:PATH=${METIS_DIR} 
                    -DMetis_LIB_DIR:PATH=${METIS_DIR}/lib 
                    -DMETIS_LIB_DIR:PATH=${METIS_DIR}/lib 
                    -DMetis_LIBRARY:PATH=${METIS_LIBRARIES}
                    -DMETIS_LIBRARY:PATH=${METIS_LIBRARIES}
                    -DMetis_INCLUDE_DIR:PATH=${METIS_DIR}/include 
                    -DMETIS_INCLUDE_DIR:PATH=${METIS_DIR}/include 
                    -DMetis_INCLUDE_DIRS:PATH=${METIS_DIR}/include
                    -DMETIS_INCLUDE_DIRS:PATH=${METIS_DIR}/include
                    -DENABLE_Tests:BOOL=FALSE
                    -DINSTALL_DIR:PATH=<INSTALL_DIR>
                    -DINSTALL_ADD_VERSION:BOOL=FALSE)

# --- Add external project build and tie to the MSTK build target
ExternalProject_Add(${MSTK_BUILD_TARGET}
                    DEPENDS   ${MSTK_PACKAGE_DEPENDS}             # Package dependency target
                    TMP_DIR   ${MSTK_tmp_dir}                     # Temporary files directory
                    STAMP_DIR ${MSTK_stamp_dir}                   # Timestamp and log directory
                    # -- Download and URL definitions
                    DOWNLOAD_DIR ${TPL_DOWNLOAD_DIR}              # Download directory
                    URL          ${MSTK_URL}                      # URL may be a web site OR a local file
                    URL_MD5      ${MSTK_MD5_SUM}                  # md5sum of the archive file
                    # -- Patch 
                    PATCH_COMMAND ${MSTK_PATCH_COMMAND}
                    # -- Configure
                    SOURCE_DIR       ${MSTK_source_dir}           # Source directory
                    CMAKE_ARGS       -Wno-dev
                    CMAKE_CACHE_ARGS ${JALI_CMAKE_CACHE_ARGS}   # Global definitions from root CMakeList
                                     ${MSTK_CMAKE_CACHE_ARGS}
                    # -- Build
                    BINARY_DIR        ${MSTK_build_dir}           # Build directory 
                    BUILD_COMMAND     $(MAKE)                     # $(MAKE) enables parallel builds through make
                    BUILD_IN_SOURCE   ${MSTK_BUILD_IN_SOURCE}     # Flag for in source builds
                    # -- Install
                    INSTALL_DIR      ${TPL_INSTALL_PREFIX}        # Install directory
                    # -- Output control
                    ${MSTK_logging_args})


# MSTK include and library install path
global_set(MSTK_INCLUDE_DIR "${TPL_INSTALL_PREFIX}/include")
global_set(MSTK_LIBRARY_DIR "${TPL_INSTALL_PREFIX}/lib")
