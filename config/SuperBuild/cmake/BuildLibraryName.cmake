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
# BUILD_LIBRARY_NAME
#
# Usage:
# BUILD_LIBRARY_NAME(library output_name [SHARED|STATIC])
#
# Given a library target name, return the full filename
# of the library with correct suffix and prefix.
# If STATIC or SHARED IS NOT set then the then suffix
# and prefix are defined by BUILD_SHARED_LIBS flag.
# Default is static.
include(CMakeParseArguments)
include(PrintVariable)
function(BUILD_LIBRARY_NAME library output_name)

  set(options "SHARED;STATIC")
  set(oneValue "APPEND_PATH")
  set(multiValue "")
  cmake_parse_arguments(PARSE "${options}" "${oneValue}" "${multiValue}" ${ARGN})

  if ( PARSE_SHARED AND PARSE_STATIC ) 
    message(FATAL_ERROR "Can not ask for STATIC and SHARED library names")
  endif()

  # Set teh suffix and prefix
  set(lib_suffix)
  set(lib_prefix)
  if (PARSE_SHARED OR BUILD_SHARED_LIBS)
    set(lib_suffix ${CMAKE_SHARED_LIBRARY_SUFFIX})
    set(lib_prefix ${CMAKE_SHARED_LIBRARY_PREFIX})
  else ()  
    set(lib_suffix ${CMAKE_STATIC_LIBRARY_SUFFIX})
    set(lib_prefix ${CMAKE_STATIC_LIBRARY_PREFIX})
  endif()

  if ( PARSE_APPEND_PATH )
    set(${output_name} "${PARSE_APPEND_PATH}/${lib_prefix}${library}${lib_suffix}" PARENT_SCOPE)
  else()  
    set(${output_name} "${lib_prefix}${library}${lib_suffix}" PARENT_SCOPE)
  endif()  


endfunction(BUILD_LIBRARY_NAME)
                     
