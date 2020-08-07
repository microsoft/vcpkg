## # vcpkg_find_fortran
##
## Checks if a Fortran compiler can be found.
## Windows(x86/x64) Only: If not it will switch/enable MinGW gfortran 
##                        and return required cmake args for building. 
##
## ## Usage
## ```cmake
## vcpkg_find_fortran(<additional_cmake_args_out>
## )
## ```

function(vcpkg_find_fortran additional_cmake_args_out)
    set(ARGS_OUT)
    set(CMAKE_BINARY_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
    set(CMAKE_CURRENT_BINARY_DIR "${CMAKE_BINARY_DIR}")
    set(CMAKE_PLATFORM_INFO_DIR "${CMAKE_BINARY_DIR}/Platform")
    include(CMakeDetermineFortranCompiler)
    if(NOT CMAKE_Fortran_COMPILER AND NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
    # This intentionally breaks users with a custom toolchain which do not have a Fortran compiler setup
    # because they either need to use a port-overlay (for e.g. lapack), remove the toolchain for the port using fortran
    # or setup fortran in their VCPKG_CHAINLOAD_TOOLCHAIN_FILE themselfs!
        if(WIN32)
            message(STATUS "No Fortran compiler found on the PATH. Using MinGW gfortran!")
            # If no Fortran compiler is on the path we switch to use gfortan from MinGW within vcpkg
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/mingw.cmake") # Switching to mingw toolchain
            if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
                set(MINGW_PATH mingw32)
                set(MSYS_TARGET i686)
                set(MACHINE_FLAG -m32)
            elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
                set(MINGW_PATH mingw64)
                set(MSYS_TARGET x86_64)
                set(MACHINE_FLAG -m64)
            else()
                message(FATAL_ERROR "Unknown architecture '${VCPKG_TARGET_ARCHITECTURE}' for MinGW Fortran build!")
            endif()
            vcpkg_acquire_msys(MSYS_ROOT "mingw-w64-${MSYS_TARGET}-gcc-fortran")
            set(MINGW_BIN "${MSYS_ROOT}/${MINGW_PATH}/bin")
            vcpkg_add_to_path(PREPEND "${MINGW_BIN}")
            list(APPEND ARGS_OUT -DCMAKE_GNUtoMS=ON
                                 "-DCMAKE_Fortran_COMPILER=${MINGW_BIN}/gfortran.exe"
                                 "-DCMAKE_C_COMPILER=${MINGW_BIN}/gcc.exe"
                                 "-DCMAKE_Fortran_FLAGS_INIT:STRING= -mabi=ms ${MACHINE_FLAG} ${VCPKG_Fortran_FLAGS}")
            set(VCPKG_USE_INTERNAL_Fortran TRUE PARENT_SCOPE)
            set(VCPKG_POLICY_SKIP_DUMPBIN_CHECKS enabled PARENT_SCOPE)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/mingw.cmake" PARENT_SCOPE) # Switching to MinGW toolchain for Fortran
            if(VCPKG_CRT_LINKAGE STREQUAL "static")
                set(VCPKG_CRT_LINKAGE dynamic PARENT_SCOPE)
                message(STATUS "VCPKG_CRT_LINKAGE linkage for ${PORT} using vcpkg's internal gfortran cannot be static due to linking against MinGW libraries. Forcing dynamic CRT linkage")
            endif()
            if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
                set(VCPKG_LIBRARY_LINKAGE dynamic PARENT_SCOPE)
                message(STATUS "VCPKG_LIBRARY_LINKAGE linkage for ${PORT} using vcpkg's internal gfortran cannot be static due to linking against MinGW libraries. Forcing dynamic library linkage")
            endif()
        else()
            message(FATAL_ERROR "Unable to find a Fortran compiler using 'CMakeDetermineFortranCompiler'. Please install one (e.g. gfortran) and make it available on the PATH!")
        endif()
    endif()
    set(${additional_cmake_args_out} ${ARGS_OUT} PARENT_SCOPE)
endfunction()