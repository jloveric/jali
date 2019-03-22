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
# Build TPL: NetCDF 
# 

# --- Define all the directories and common external project flags
define_external_project_args(NetCDF 
                             TARGET netcdf
                             DEPENDS HDF5)

# add version version to the autogenerated tpl_versions.h file
Jali_tpl_version_write(FILENAME ${TPL_VERSIONS_INCLUDE_FILE}
  PREFIX NetCDF
  VERSION ${NetCDF_VERSION_MAJOR} ${NetCDF_VERSION_MINOR} ${NetCDF_VERSION_PATCH})

# --- Patch the original code
set(NetCDF_patch_file netcdf-cmake.patch)
set(NetCDF_sh_patch ${NetCDF_prefix_dir}/netcdf-patch-step.sh)
configure_file(${SuperBuild_TEMPLATE_FILES_DIR}/netcdf-patch-step.sh.in
               ${NetCDF_sh_patch}
               @ONLY)

# configure the CMake patch step
set(NetCDF_cmake_patch ${NetCDF_prefix_dir}/netcdf-patch-step.cmake)
configure_file(${SuperBuild_TEMPLATE_FILES_DIR}/netcdf-patch-step.cmake.in
               ${NetCDF_cmake_patch}
               @ONLY)

# configure the CMake command file
set(NetCDF_PATCH_COMMAND ${CMAKE_COMMAND} -P ${NetCDF_cmake_patch})     

# --- Define the configure command
set(NetCDF_CMAKE_CACHE_ARGS "-DCMAKE_INSTALL_PREFIX:FILEPATH=${TPL_INSTALL_PREFIX}")
list(APPEND NetCDF_CMAKE_CACHE_ARGS "-DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}")
list(APPEND NetCDF_CMAKE_CACHE_ARGS "-DCMAKE_INSTALL_LIBDIR:FILEPATH=${TPL_INSTALL_PREFIX}/lib")
list(APPEND NetCDF_CMAKE_CACHE_ARGS "-DCMAKE_INSTALL_BINDIR:FILEPATH=${TPL_INSTALL_PREFIX}/bin")
list(APPEND NetCDF_CMAKE_CACHE_ARGS "-DENABLE_DAP:BOOL=FALSE")
list(APPEND NetCDF_CMAKE_CACHE_ARGS "-DENABLE_PARALLEL4:BOOL=TRUE")
list(APPEND NetCDF_CMAKE_CACHE_ARGS "-DHDF5_PARALLEL:BOOL=TRUE")
list(APPEND NetCDF_CMAKE_CACHE_ARGS "-DHDF5_C_LIBRARY:FILEPATH=${HDF5_C_LIBRARY}")
list(APPEND NetCDF_CMAKE_CACHE_ARGS "-DHDF5_HL_LIBRARY:FILEPATH=${HDF5_HL_LIBRARY}")
list(APPEND NetCDF_CMAKE_CACHE_ARGS "-DHDF5_INCLUDE_DIR:PATH=${HDF5_INCLUDE_DIRS}")

# specify preferable search path 
list(APPEND NetCDF_CMAKE_CACHE_ARGS "-DCMAKE_PREFIX_PATH:PATH=${TPL_INSTALL_PREFIX}")

# Default is to build with NetCDF4 which depends on HDF5
option(ENABLE_NetCDF4 "Enable netCDF4 build" TRUE)
if (ENABLE_NetCDF4)

  list(APPEND NetCDF_PACKAGE_DEPENDS ${HDF5_BUILD_TARGET})
  list(APPEND NetCDF_CMAKE_CACHE_ARGS "-DENABLE_NETCDF_4:BOOL=TRUE")
endif() 

# share libraries -- disabled by default
list(APPEND NetCDF_CMAKE_CACHE_ARGS "-DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}")

# --- Add external project build 
ExternalProject_Add(${NetCDF_BUILD_TARGET}
                    DEPENDS   ${NetCDF_PACKAGE_DEPENDS}             # Package dependency target
                    TMP_DIR   ${NetCDF_tmp_dir}                     # Temporary files directory
                    STAMP_DIR ${NetCDF_stamp_dir}                   # Timestamp and log directory
                    # -- Download and URL definitions
                    DOWNLOAD_DIR ${TPL_DOWNLOAD_DIR}      # Download directory
                    URL          ${NetCDF_URL}            # URL may be a web site OR a local file
                    URL_MD5      ${NetCDF_MD5_SUM}        # md5sum of the archive file
                    DOWNLOAD_NAME ${NetCDF_SAVEAS_FILE}   # file name to store (if not end of URL)
                    # -- Patch 
                    PATCH_COMMAND ${NetCDF_PATCH_COMMAND}
                    # -- Configure
                    SOURCE_DIR       ${NetCDF_source_dir}
                    CMAKE_CACHE_ARGS ${JALI_CMAKE_CACHE_ARGS}  # Global definitions from root CMakeList
                                     ${NetCDF_CMAKE_CACHE_ARGS}
                                     -DCMAKE_C_FLAGS:STRING=${Jali_COMMON_CFLAGS}  # Ensure uniform build
                                     -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
                                     -DCMAKE_CXX_FLAGS:STRING=${Jali_COMMON_CXXFLAGS}
                                     -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
                    # -- Build
                    BINARY_DIR        ${NetCDF_build_dir}           # Build directory 
                    BUILD_COMMAND     $(MAKE)                     # $(MAKE) enables parallel builds through make
                    BUILD_IN_SOURCE   ${NetCDF_BUILD_IN_SOURCE}     # Flag for in source builds
                    # -- Install
                    INSTALL_DIR      ${TPL_INSTALL_PREFIX}      
                    # -- Output control
                    ${NetCDF_logging_args})

# --- Useful variables for packages that depend on NetCDF (Trilinos, ExodusII)
include(BuildLibraryName)
build_library_name(netcdf NetCDF_C_LIBRARY APPEND_PATH ${TPL_INSTALL_PREFIX}/lib)
build_library_name(netcdf_c++ NetCDF_CXX_LIBRARY APPEND_PATH ${TPL_INSTALL_PREFIX}/lib)
set(NetCDF_INCLUDE_DIRS ${TPL_INSTALL_PREFIX}/include)
set(NetCDF_C_LIBRARIES ${NetCDF_C_LIBRARY})
if ( ENABLE_NetCDF4 )
  list(APPEND NetCDF_C_LIBRARIES ${HDF5_LIBRARIES})
  list(APPEND NetCDF_INCLUDE_DIRS ${HDF5_INCLUDE_DIRS})
  list(REMOVE_DUPLICATES NetCDF_INCLUDE_DIRS)
endif()
  

