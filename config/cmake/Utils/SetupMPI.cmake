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
# SetupMPI.cmake
#
# This macro will set the following variables
# 
#  MPI_WRAPPERS_IN_USE           TRUE if the CMAKE_<language>_COMPILER definitions are wrappers
#  MPI_FOUND                     TRUE if MPI is located
#  MPI_EXEC                      MPI parallel executable launcher
#  MPI_EXEC_NUMPROC_FLAG         MPI_EXEC option that sets number of MPI ranks
#  MPI_EXEC_PREFLAGS             MPI_EXEC 
#  MPI_EXEC_POSTFLAGS
# 
#  If CMake VERSION is greater than 2.8.2 the following variables are also
#  set. See cmake --help-module FindMPI for more information.
#
#  MPI_<lanuage>_COMPILER        MPI <language> compiler wrapper
#  MPI_<language>_COMPILE_FLAGS  MPI <language> compile flags
#  MPI_<language>_INCLUDE_PATH   MPI <language> include path
#  MPI_<language>_LINK_FLAGS     MPI <language> link flags
#  MPI_<language>_LIBRARIES      MPI <language libraries
include(CheckMPISourceCompiles)
include(PrintVariable)

macro(SETUP_MPI)

  # First check if the CMAKE_<lang>_COMPILER definitions are wrappers
  check_mpi_source_compiles(MPI_WRAPPERS_IN_USE)

  # The FindMPI changed to something useful after the 2.8.4 version
  if ( "${CMAKE_VERSION}" VERSION_GREATER 2.8.4 )

    # Call FindMPI
    if ( MPI_WRAPPERS_IN_USE )

      # Although we are using wrappers we still need the MPIEXEC from FindMPI

      # Set these so FindMPI works!
      set(MPI_C_COMPILER       ${CMAKE_C_COMPILER})
      set(MPI_CXX_COMPILER     ${CMAKE_CXX_COMPILER})
      set(MPI_Fortran_COMPILER ${CMAKE_Fortran_COMPILER})
  
      # Quiet search since we know wrappers are active
      find_package(MPI QUIET)

    else(MPI_WRAPPERS_IN_USE)

      # WARN the user that links will fail since MPI is not included in most library defs
      message(WARNING "At this time, most of the Jali libraries will fail to link if"
                      " the CMAKE_*_COMPILER definitions are not wrappers. If the build"
                      " fails, delete the top-level CMakeCache.txt file and re-run cmake"
                      " with MPI compiler wrappers.")

      # Attempt to locate compiler wrappers
      message(STATUS "Search for MPI compiler wrappers")

      # Use MPI_PREFIX to set wrapper names
      if ( MPI_PREFIX )
        set(MPI_C_COMPILER       ${MPI_PREFIX}/bin/mpicc)
        set(MPI_CXX_COMPILER     ${MPI_PREFIX}/bin/mpicxx)
        set(MPI_Fortran_COMPILER ${MPI_PREFIX}/bin/mpif90)
      endif()

      find_package(MPI REQUIRED)

      if ( (MPI_C_FOUND) AND (MPI_CXX_FOUND) AND (MPI_Fortran_FOUND) )

        # Located wrappers and now need to define include paths, and libraries
        # to the compile without error
        message(STATUS "Search for MPI compiler wrappers - success")

        # Set the compile flags, build a list for include paths
        set(mpi_include_paths)
        foreach( lang "C;CXX;Fortran" )
          set(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} ${MPI_${lang}_COMPILE_FLAGS}")
          list(APPEND APPEND mpi_include_paths ${MPI_${lang}_INCLUDE_PATHS})
        endforeach()

        include_directories(${mpi_include_paths})



      else()   
        message(STATUS "Search for MPI compiler wrappers - failed")
        message(FATAL_ERROR "Can not locate MPI installation with MPI wrappers."
                            " Please define CMAKE_*_COMPILER as MPI compiler wrappers"
                            " or set MPI_PREFIX to an MPI installation"
                            " with compiler wrappers.")
      endif()

    endif(MPI_WRAPPERS_IN_USE)    

  else("${CMAKE_VERSION}" VERSION_GREATER 2.8.4)

      # The FindMPI module for versions less than 2.8.4 is worthless. Will not
      # attempt to adjust the compile or link flags if not using wrappers.
      if ( NOT MPI_WRAPPERS_IN_USE )
        message(FATAL_ERROR " CMAKE_*_COMPILER definitions are NOT MPI compiler wrappers."
                            " Set CMAKE_*_COMPILER parameters to MPI compiler wrappers and"
                            " re-run cmake.")
      endif()  

      # Search for MPI to define MPI_EXEC* variables
      # For later versions of FindMPI need to set MPI_COMPILER to search
      # in the correct location.
      set(MPI_COMPILER "${CMAKE_C_COMPILER}"
          CACHE FILEPATH "MPI C compiler wrapper" FORCE)
      find_package(MPI)

  endif( "${CMAKE_VERSION}" VERSION_GREATER 2.8.4 )  

  # Now set MPIEXEC_* to the Jali MPI_EXEC values. We do not
  # want to override these values if alread set. See Cray XT
  if ( MPI_FOUND )

    if ( NOT MPI_EXEC )
      set(MPI_EXEC "${MPIEXEC}")
    endif()

    if ( NOT MPI_EXEC_NUMPROC_FLAG )
      set(MPI_EXEC_NUMPROC_FLAG "${MPI_EXEC_NUMPROC_FLAG}")
    endif()  

    if ( NOT MPI_EXEC_PREFLAGS )
      set(MPI_EXEC_PREFLAGS "${MPI_EXEC_PREFLAGS}")
    endif()  

    if ( NOT MPI_EXEC_POSTFLAGS )
      set(MPI_EXEC_POSTFLAGS "${MPI_EXEC_POSTFLAGS}")
    endif() 

  endif()



endmacro(SETUP_MPI)  

