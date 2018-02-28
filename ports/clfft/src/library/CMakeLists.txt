# ########################################################################
# Copyright 2013 Advanced Micro Devices, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ########################################################################

# List the names of common files to compile across all platforms
set( clFFT.Source	transform.cpp
								accessors.cpp
								plan.cpp
								repo.cpp
								generator.stockham.cpp
								generator.transpose.gcn.cpp
								generator.transpose.cpp
								action.transpose.cpp
								generator.copy.cpp
								lifetime.cpp
								fft_binary_lookup.cpp
								md5sum.c
								enqueue.cpp
								stdafx.cpp )

# Windows only uses dllmain
if( MSVC )
	set( clFFT.Source ${clFFT.Source} dllmain.cpp )
endif( )

set( clFFT.Headers	private.h
					action.h
					repo.h
					plan.h
					lock.h
					mainpage.h
					generator.h
					generator.stockham.h
					generator.transpose.gcn.h
					generator.transpose.h
					action.transpose.h
					fft_binary_lookup.h
					md5sum.h
					../include/stdafx.h
					../include/unicode.compatibility.h
					../include/targetver.h
					../include/clAmdFft.h
					../include/clFFT.h )

set( clFFT.Files ${clFFT.Source} ${clFFT.Headers} )

# For a rainy day, add pre-compiled header support
#if( MSVC )
#	if (USE_MSVC_PCH)

#		set_source_files_properties(LungAnalysisPCH.cxx
#			PROPERTIES
#			COMPILE_FLAGS "/YcLungAnalysisPCH.h"
#			)
#		foreach( src_file ${UPMC_LA_SRCS} )
#			set_source_files_properties(
#				${src_file}
#				PROPERTIES
#				COMPILE_FLAGS "/YuLungAnalysisPCH.h"
#				)
#		endforeach( src_file ${UPMC_LA_SRCS} )

#		list(APPEND UPMC_LA_SRCS LungAnalysisPCH.cxx)
#		list(APPEND UPMC_LA_HDRS LungAnalysisPCH.h)

#	endif(USE_MSVC_PCH)
#endif (MSVC)

#	add_definitions( ${Boost_LIB_DIAGNOSTIC_DEFINITIONS} )
add_definitions( "/DCLFFT_EXPORTS" )

# Include standard OpenCL headers
include_directories( ${OpenCL_INCLUDE_DIRS} ${PROJECT_BINARY_DIR}/include ../include )
message(STATUS "OpenCL_INCLUDE_DIRS: ${OpenCL_INCLUDE_DIRS}")

add_library( clFFT ${clFFT.Files} )
target_link_libraries( clFFT ${OpenCL_LIBRARIES} ${CMAKE_DL_LIBS} )

set_target_properties( clFFT PROPERTIES VERSION ${CLFFT_VERSION} )
set_target_properties( clFFT PROPERTIES SOVERSION ${CLFFT_SOVERSION} )
set_target_properties( clFFT PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/staging" )
set_target_properties( clFFT PROPERTIES INTERFACE_INCLUDE_DIRECTORIES $<INSTALL_INTERFACE:include> )

if( CMAKE_COMPILER_IS_GNUCC )
    configure_file( ${CMAKE_CURRENT_SOURCE_DIR}/clFFT.pc.in
                    ${CMAKE_CURRENT_BINARY_DIR}/clFFT.pc @ONLY )

    install( FILES ${CMAKE_CURRENT_BINARY_DIR}/clFFT.pc
             DESTINATION lib${SUFFIX_LIB}/pkgconfig )
endif( )

# CPack configuration; include the executable into the package
install( TARGETS clFFT
        EXPORT Library
        RUNTIME DESTINATION bin${SUFFIX_BIN}
        LIBRARY DESTINATION lib${SUFFIX_LIB}
        ARCHIVE DESTINATION lib${SUFFIX_LIB}
        )
