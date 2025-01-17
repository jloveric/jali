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
# 
#  
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
# Jali METIS Find Module
#
# Usage:
#    Control the search through METIS_DIR or setting environment variable
#    METIS_ROOT to the METIS installation prefix.
#
#    This module does not search default paths! 
#
#    Following variables are set:
#    METIS_FOUND            (BOOL)       Flag indicating if METIS was found
#    METIS_INCLUDE_DIR      (PATH)       Path to the METIS include file
#    METIS_INCLUDE_DIRS     (LIST)       List of all required include files
#    METIS_LIBRARY_DIR      (PATH)       Path to the METIS library
#    METIS_LIBRARY          (FILE)       METIS library
#    METIS_LIBRARIES        (LIST)       List of all required METIS libraries
#
# #############################################################################

# Standard CMake modules see CMAKE_ROOT/Modules
include(FindPackageHandleStandardArgs)

# Jali CMake functions see <root>/tools/cmake for source
include(PrintVariable)

if ( METIS_LIBRARIES AND METIS_INCLUDE_DIRS )

    # Do nothing. Variables are set. No need to search again

else(METIS_LIBRARIES AND METIS_INCLUDE_DIRS)

    # Cache variables
    if(METIS_DIR)
        set(METIS_DIR "${METIS_DIR}" CACHE PATH "Path to search for METIS include and library files")
    endif()

    if(METIS_INCLUDE_DIR)
        set(METIS_INCLUDE_DIR "${METIS_INCLUDE_DIR}" CACHE PATH "Path to search for METIS include files")
    endif()

    if(METIS_LIBRARY_DIR)
        set(METIS_LIBRARY_DIR "${METIS_LIBRARY_DIR}" CACHE PATH "Path to search for METIS library files")
    endif()

    
    # Search for include files
    # Search order preference:
    #  (1) METIS_INCLUDE_DIR - check existence of path AND if the include files exist
    #  (2) METIS_DIR/<include>
    #  (3) Default CMake paths See cmake --html-help=out.html file for more information.
    #
    set(metis_inc_names "metis.h")
    if (METIS_INCLUDE_DIR)

        if (EXISTS "${METIS_INCLUDE_DIR}")

            find_path(metis_test_include_path
                      NAMES ${metis_inc_names}
                      HINTS ${METIS_INCLUDE_DIR}
                      NO_DEFAULT_PATH)
            if(NOT metis_test_include_path)
                message(SEND_ERROR "Can not locate ${metis_inc_names} in ${METIS_INCLUDE_DIR}")
            endif()
            set(METIS_INCLUDE_DIR "${metis_test_include_path}")

        else()
            message(SEND_ERROR "METIS_INCLUDE_DIR=${METIS_INCLUDE_DIR} does not exist")
            set(METIS_INCLUDE_DIR "METIS_INCLUDE_DIR-NOTFOUND")
        endif()

   else() 

        set(metis_inc_suffixes "include")
        if(METIS_DIR)

            if (EXISTS "${METIS_DIR}" )

                find_path(METIS_INCLUDE_DIR
                          NAMES ${metis_inc_names}
                          HINTS ${METIS_DIR}
                          PATH_SUFFIXES ${metis_inc_suffixes}
                          NO_DEFAULT_PATH)

            else()
                 message(SEND_ERROR "METIS_DIR=${METIS_DIR} does not exist")
                 set(METIS_INCLUDE_DIR "METIS_INCLUDE_DIR-NOTFOUND")
            endif()    


        else()

            find_path(METIS_INCLUDE_DIR
                      NAMES ${metis_inc_names}
                      PATH_SUFFIXES ${metis_inc_suffixes})

        endif()

    endif()

    if ( NOT METIS_INCLUDE_DIR )
        message(SEND_ERROR "Can not locate METIS include directory")
    endif()

    # Search for libraries 
    # Search order preference:
    #  (1) METIS_LIBRARY_DIR - check existence of path AND if the library file exists
    #  (2) METIS_DIR/<lib,Lib>
    #  (3) Default CMake paths See cmake --html-help=out.html file for more information.
    #
    set(metis_lib_names "metis")
    if (METIS_LIBRARY_DIR)

        if (EXISTS "${METIS_LIBRARY_DIR}")

            find_library(METIS_LIBRARY
                         NAMES ${metis_lib_names}
                         HINTS ${METIS_LIBRARY_DIR}
                         NO_DEFAULT_PATH)
        else()
            message(SEND_ERROR "METIS_LIBRARY_DIR=${METIS_LIBRARY_DIR} does not exist")
            set(METIS_LIBRARY "METIS_LIBRARY-NOTFOUND")
        endif()

    else() 

        list(APPEND metis_lib_suffixes "lib" "Lib")
        if(METIS_DIR)

            if (EXISTS "${METIS_DIR}" )

                find_library(METIS_LIBRARY
                             NAMES ${metis_lib_names}
                             HINTS ${METIS_DIR}
                             PATH_SUFFIXES ${metis_lib_suffixes}
                             NO_DEFAULT_PATH)

            else()
                 message(SEND_ERROR "METIS_DIR=${METIS_DIR} does not exist")
                 set(METISLIBRARY "METIS_LIBRARY-NOTFOUND")
            endif()    


        else()

            find_library(METIS_LIBRARY
                         NAMES ${metis_lib_names}
                         PATH_SUFFIXES ${metis_lib_suffixes})

        endif()

    endif()

    if ( NOT METIS_LIBRARY )
        message(SEND_ERROR "Can not locate METIS library")
    endif()    

   
    # Define prerequisite packages
    set(METIS_INCLUDE_DIRS ${METIS_INCLUDE_DIR})
    set(METIS_LIBRARIES    ${METIS_LIBRARY})

   
endif(METIS_LIBRARIES AND METIS_INCLUDE_DIRS )    

# Send useful message if everything is found
find_package_handle_standard_args(METIS DEFAULT_MSG
                                  METIS_LIBRARIES
                                  METIS_INCLUDE_DIRS)

# find_package_handle_standard_args should set METIS_FOUND but it does not!
if ( METIS_LIBRARIES AND METIS_INCLUDE_DIRS)
    set(METIS_FOUND TRUE)
else()
    set(METIS_FOUND FALSE)
endif()

# Define the version

mark_as_advanced(
  METIS_INCLUDE_DIR
  METIS_INCLUDE_DIRS
  METIS_LIBRARY
  METIS_LIBRARIES
  METIS_LIBRARY_DIR
)
