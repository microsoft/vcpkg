get_property( _CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE )
if(NOT _CMAKE_IN_TRY_COMPILE)

    if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        set(VCPKG_CRT_LINK_FLAG_PREFIX "/MD")
    elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(VCPKG_CRT_LINK_FLAG_PREFIX "/MT")
    else()
        message(FATAL_ERROR "Invalid setting for VCPKG_CRT_LINKAGE: \"${VCPKG_CRT_LINKAGE}\". It must be \"static\" or \"dynamic\"")
    endif()

    set(CHARSET_FLAG "/utf-8")
    if(VCPKG_PLATFORM_TOOLSET MATCHES "v120")
        # VS 2013 does not support /utf-8
        set(CHARSET_FLAG)
    endif()

    if(VCPKG_FORTRAN_ENABLED AND DEFINED VCPKG_FORTRAN_COMPILER AND VCPKG_FORTRAN_COMPILER STREQUAL Intel)
        # Make sure the name mangling of Intel Fortran generated symbols is all lowercase with underscore suffix
        # because this is assumed by many libraries (that e.g. consume BLAS/LAPACK)
        set(ENV{FFLAGS} "$ENV{FFLAGS} /names:lowercase /assume:underscore")

        # When using the Intel and VS2017 command line environments together there is a bug when
        # using cl and some standard headers are included (e.g. stdint.h). This is because Intel does
        # not handle the changed directory structure of the runtime headers between VS2015 and VS2017 correctly.
        # The following code works around those issues. This is true as of Intel 2017.4 and VS2017.3.
        if(VCPKG_PLATFORM_TOOLSET STREQUAL "v141")
            file(TO_CMAKE_PATH "$ENV{VCToolsInstallDir}" VCToolsInstallDir)
            string(APPEND VCPKG_CXX_FLAGS " /D__MS_VC_INSTALL_PATH=\"${VCToolsInstallDir}\"")
            string(APPEND VCPKG_C_FLAGS " /D__MS_VC_INSTALL_PATH=\"${VCToolsInstallDir}\"")
        endif()
    endif()
    
    if(VCPKG_FORTRAN_ENABLED AND DEFINED VCPKG_FORTRAN_COMPILER AND VCPKG_FORTRAN_COMPILER STREQUAL Flang)
        # Make sure that CMake uses the correct compilers:
        # while we want to use flang as Fortran compiler we want to keep cl for C and C++
        set(CMAKE_Fortran_COMPILER "flang" CACHE STRING "")
        set(CMAKE_C_COMPILER "cl" CACHE STRING "")
        set(CMAKE_CXX_COMPILER "cl" CACHE STRING "")
    endif()

    # When using GNU gfortran as Fortran compiler CMake requires to use gcc and g++ as C and C++ compilers
    # so we should not set all the other C and C++ compiler flags
    if(VCPKG_FORTRAN_ENABLED AND DEFINED VCPKG_FORTRAN_COMPILER AND VCPKG_FORTRAN_COMPILER STREQUAL GNU)
        set(CMAKE_GNUtoMS "ON" CACHE STRING "")
    else()
        set(CMAKE_CXX_FLAGS " /DWIN32 /D_WINDOWS /W3 ${CHARSET_FLAG} /GR /EHsc /MP ${VCPKG_CXX_FLAGS}" CACHE STRING "")
        set(CMAKE_C_FLAGS " /DWIN32 /D_WINDOWS /W3 ${CHARSET_FLAG} /MP ${VCPKG_C_FLAGS}" CACHE STRING "")
        set(CMAKE_RC_FLAGS "-c65001 /DWIN32" CACHE STRING "")

        unset(CHARSET_FLAG)

        set(CMAKE_CXX_FLAGS_DEBUG "/D_DEBUG ${VCPKG_CRT_LINK_FLAG_PREFIX}d /Z7 /Ob0 /Od /RTC1 ${VCPKG_CXX_FLAGS_DEBUG}" CACHE STRING "")
        set(CMAKE_C_FLAGS_DEBUG "/D_DEBUG ${VCPKG_CRT_LINK_FLAG_PREFIX}d /Z7 /Ob0 /Od /RTC1 ${VCPKG_C_FLAGS_DEBUG}" CACHE STRING "")
        set(CMAKE_CXX_FLAGS_RELEASE "${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /Oi /Gy /DNDEBUG /Z7 ${VCPKG_CXX_FLAGS_RELEASE}" CACHE STRING "")
        set(CMAKE_C_FLAGS_RELEASE "${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /Oi /Gy /DNDEBUG /Z7 ${VCPKG_C_FLAGS_RELEASE}" CACHE STRING "")

        set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "/DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS}" CACHE STRING "")
        set(CMAKE_EXE_LINKER_FLAGS_RELEASE "/DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS}" CACHE STRING "")
    endif()

endif()
