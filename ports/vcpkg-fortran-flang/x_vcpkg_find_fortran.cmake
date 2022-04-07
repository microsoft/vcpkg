#[===[.md:
# x_vcpkg_find_fortran

Checks if a Fortran compiler can be found.
Windows(x86/x64) Only: If not it will search and enable Intel
                       ifort compiler if available. 

## Usage
```cmake
x_vcpkg_find_fortran(<out_var>)
```

## Example
```cmake
x_vcpkg_find_fortran(fortran_args)
# ...
vcpkg_configure_cmake(...
    OPTIONS
        ${fortran_args}
)
```
#]===]


function(x_vcpkg_find_fortran)
    
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "OUT_OPTIONS;OUT_OPTIONS_RELEASE;OUT_OPTIONS_DEBUG" "")

    vcpkg_list(SET additional_cmake_args)

    set(CMAKE_BINARY_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
    set(CMAKE_CURRENT_BINARY_DIR "${CMAKE_BINARY_DIR}")
    set(CMAKE_PLATFORM_INFO_DIR "${CMAKE_BINARY_DIR}/Platform")
    include(CMakeDetermineFortranCompiler)

    if(NOT CMAKE_Fortran_COMPILER AND "${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}" STREQUAL "")
        # If a user uses their own VCPKG_CHAINLOAD_TOOLCHAIN_FILE, they _must_ figure out Fortran on their own. 
        if(WIN32)
            message(STATUS "No Fortran compiler found on the PATH. Trying to use classic flang!")
            if(VCPKG_TARGET_IS_UWP)
                set(extra_uwp_flags "-Wl,/NODEFAULTLIB:libcmt -Wl,/NODEFAULTLIB:libcmtd -Wl,/NODEFAULTLIB:msvcrt -Wl,/NODEFAULTLIB:msvcrtd")
                set(exta_uwp_link_flags "-DCMAKE_SHARED_LINKER_FLAGS_INIT:STRING=-Wl,/APPCONTAINER")
            endif()

            z_vcpkg_get_cmake_vars(cmake_vars_file)
            include("${cmake_vars_file}")

            find_library(PGMATH NAMES libpgmath pgmath PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATHS)
            cmake_path(GET PGMATH FILENAME pgmathlibname)
            find_library(flanglib NAMES libflang flang PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATHS)
            cmake_path(GET flanglib FILENAME flanglibname)
            find_library(flangrtilib NAMES libflangrti flangrti PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATHS)
            cmake_path(GET flangrtilib FILENAME flangrtilibname)
            if(VCPKG_OPENMP)
                find_library(omplib NAMES libomp omp PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATHS)
                cmake_path(GET omplib FILENAME omplibname)
            else()
                find_library(omplib NAMES libompstub ompstub PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATHS)
                cmake_path(GET omplib FILENAME omplibname)
            endif()
            find_library(flangmainlib NAMES libflangmain flangmain PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATHS)
            cmake_path(GET flangmainlib FILENAME flangmainlibname)

            vcpkg_list(SET flang_compile_libs "")
            vcpkg_list(SET flang_link_lib "${flanglibname} ${flangrtilibname} ${pgmathlibname} ${omplibname}")
            vcpkg_list(SET flang_link_default_lib "/DEFAULTLIB:${flanglibname} /DEFAULTLIB:${flangrtilibname} /DEFAULTLIB:${pgmathlibname} /DEFAULTLIB:${omplibname}")

            set(static_flang "")
            if("${pgmathlibname}" STREQUAL "libpgmath.lib")
                set(static_flang "-static-flang-libs ")
            endif()
            #-noFlangLibs -fno-fortran-main
            #-Wno-unused-command-line-argument
            vcpkg_list(APPEND additional_cmake_args 
                "-DCMAKE_C_COMPILER=${VCPKG_DETECTED_CMAKE_C_COMPILER}"
                "-DCMAKE_Fortran_COMPILER=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang/bin/flang.exe"
                "-DCMAKE_EXE_LINKER_FLAGS_DEBUG_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib"
                "-DCMAKE_EXE_LINKER_FLAGS_RELEASE_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/lib"
                "-DCMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib"
                "-DCMAKE_SHARED_LINKER_FLAGS_RELEASE_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/lib"
                "-DCMAKE_STATIC_LINKER_FLAGS_DEBUG_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib"
                "-DCMAKE_STATIC_LINKER_FLAGS_RELEASE_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/lib"
                "-DCMAKE_Fortran_FLAGS_DEBUG_INIT:STRING=-O0 -Wl,/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib"
                "-DCMAKE_Fortran_FLAGS_RELEASE_INIT:STRING=-O3 -Wl,/LIBPATH:${CURRENT_INSTALLED_DIR}/lib"
                "-DCMAKE_Fortran_STANDARD_LIBRARIES_INIT=${flang_link_lib}"
                "-DCMAKE_Fortran_LINKER_FLAGS_RELEASE_INIT=/LIBPATH:${CURRENT_INSTALLED_DIR}/lib ${flang_link_default_lib}"
                "-DCMAKE_Fortran_LINKER_FLAGS_DEBUG_INIT=/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib ${flang_link_default_lib}"
                "-DCMAKE_REQUIRED_LINK_OPTIONS:STRING=-LIBPATH:${CURRENT_INSTALLED_DIR}/\$$<\$$<CONFIG:DEBUG>:debug/>lib/"
                #"-DCMAKE_Fortran_LINK_EXECUTABLE=\\\\\"\\\\\${_CMAKE_VS_LINK_EXE}<CMAKE_LINKER> \\\\\${CMAKE_CL_NOLOGO} <OBJECTS> \\\\\${CMAKE_START_TEMP_FILE} /out:<TARGET> /implib:<TARGET_IMPLIB> /pdb:<TARGET_PDB> /version:<TARGET_VERSION_MAJOR>.<TARGET_VERSION_MINOR>${_PLATFORM_LINK_FLAGS} <CMAKE_Fortran_LINK_FLAGS> <LINK_FLAGS> <LINK_LIBRARIES>\\\\\${CMAKE_END_TEMP_FILE}\\\\\""
                "${exta_uwp_link_flags}")
            vcpkg_list(APPEND additional_cmake_args_rel
                "-DCMAKE_EXE_LINKER_FLAGS_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/lib ${flangmainlibname} ${flang_link_default_lib}"
                "-DCMAKE_SHARED_LINKER_FLAGS_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/lib ${flang_link_default_lib}"
                "-DCMAKE_STATIC_LINKER_FLAGS_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/lib ${flang_link_default_lib}"
                "-DCMAKE_Fortran_FLAGS_INIT:STRING=${static_flang}${flang_compile_libs} -Wl,/LIBPATH:${CURRENT_INSTALLED_DIR}/lib ${extra_uwp_flags}"
                "-DCMAKE_Fortran_LINKER_FLAGS_INIT=/LIBPATH:${CURRENT_INSTALLED_DIR}/lib ${flang_link_default_lib}"
                )
            vcpkg_list(APPEND additional_cmake_args_dbg
                "-DCMAKE_EXE_LINKER_FLAGS_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib ${flangmainlibname} ${flang_link_default_lib}"
                "-DCMAKE_SHARED_LINKER_FLAGS_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib ${flang_link_default_lib}"
                "-DCMAKE_STATIC_LINKER_FLAGS_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib ${flang_link_default_lib}"
                "-DCMAKE_Fortran_FLAGS_INIT:STRING=${static_flang}${flang_compile_libs} -Wl,/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib ${extra_uwp_flags}"
                "-DCMAKE_Fortran_LINKER_FLAGS_INIT=/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib ${flang_link_default_lib}"
                )
            set(VCPKG_USE_INTERNAL_Fortran TRUE CACHE INTERNAL "")
        else()
            message(FATAL_ERROR "Unable to find a Fortran compiler using 'CMakeDetermineFortranCompiler'. Please install one (e.g. gfortran) and make it available on the PATH!")
        endif()
    endif()
    set("${arg_OUT_OPTIONS}" "${additional_cmake_args}" PARENT_SCOPE)
    set("${arg_OUT_OPTIONS_RELEASE}" "${additional_cmake_args_rel}" PARENT_SCOPE)
    set("${arg_OUT_OPTIONS_DEBUG}" "${additional_cmake_args_dbg}" PARENT_SCOPE)
endfunction()
