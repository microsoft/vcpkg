#[===[.md:
# x_vcpkg_find_fortran

Checks if a Fortran compiler can be found.
Windows only: If not it will try to use one internal to vcpkg

## Usage
```cmake
x_vcpkg_find_fortran(OUT_OPTIONS <var>
                     OUT_OPTIONS_RELEASE <var_rel>
                     OUT_OPTIONS_DEBUG <var_dbg>
                    )
```

## Example
```cmake
x_vcpkg_find_fortran(OUT_OPTIONS fortran_args
                     OUT_OPTIONS_RELEASE fortran_args_rel
                     OUT_OPTIONS_DEBUG fortran_args_dbg
                    )
# ...
vcpkg_configure_cmake(...
    OPTIONS
        ${fortran_args}
    OPTIONS_RELEASE
        ${fortran_args_rel}
    OPTIONS_DEBUG
        ${fortran_args_dbg}
)
```
#]===]
function(x_vcpkg_find_fortran)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "OUT_OPTIONS;OUT_OPTIONS_RELEASE;OUT_OPTIONS_DEBUG" "")

    vcpkg_list(SET additional_cmake_args)
    vcpkg_cmake_get_vars(cmake_vars_file OPTIONS "-DVCPKG_LANGUAGES=C;CXX;Fortran")
    include("${cmake_vars_file}")

    if(NOT VCPKG_DETECTED_CMAKE_Fortran_COMPILER)
        if(WIN32)
            message(STATUS "No Fortran compiler found on the PATH. Trying to use classic flang!")
            # if(VCPKG_TARGET_IS_UWP) # UWP not working. Missing libomp to build flang-fortran-runtime
            #    set(extra_uwp_flags "-Wl,/NODEFAULTLIB:libcmt -Wl,/NODEFAULTLIB:libcmtd -Wl,/NODEFAULTLIB:msvcrt -Wl,/NODEFAULTLIB:msvcrtd")
            #    set(exta_uwp_link_flags "-DCMAKE_SHARED_LINKER_FLAGS_INIT:STRING=-Wl,/APPCONTAINER")
            # endif()

            if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
                set(ARCH X86)
            elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
                set(ARCH ARM)
            endif()
            vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang-classic/bin/${ARCH}")

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
            if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
                set(arch_flag "--target=aarch64-win32-msvc")
            endif()
            #-noFlangLibs -fno-fortran-main
            #-Wno-unused-command-line-argument
            vcpkg_list(APPEND additional_cmake_args 
"-DCMAKE_TRY_COMPILE_PLATFORM_VARIABLES=CMAKE_Fortran_FLAGS;CMAKE_Fortran_FLAGS_RELEASE;CMAKE_Fortran_FLAGS_DEBUG;CMAKE_Fortran_STANDARD_LIBRARIES;CMAKE_EXE_LINKER_FLAGS;CMAKE_EXE_LINKER_FLAGS_RELEASE;CMAKE_EXE_LINKER_FLAGS_DEBUG;CMAKE_STATIC_LINKER_FLAGS;CMAKE_STATIC_LINKER_FLAGS_DEBUG;CMAKE_STATIC_LINKER_FLAGS_RELEASE;CMAKE_SHARED_LINKER_FLAGS;CMAKE_SHARED_LINKER_FLAGS_RELEASE;CMAKE_SHARED_LINKER_FLAGS_DEBUG;CMAKE_REQUIRED_LINK_OPTIONS"
                "-DCMAKE_POLICY_DEFAULT_CMP0065=NEW"
                "-DCMAKE_POLICY_DEFAULT_CMP0067=NEW"
                "-DCMAKE_POLICY_DEFAULT_CMP0083=NEW"
                "-DCMAKE_C_COMPILER=${VCPKG_DETECTED_CMAKE_C_COMPILER}" # Need to pass C compiler if only Fortran is enabled.
                "-DCMAKE_Fortran_COMPILER=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang-classic/bin/flang.exe"
                "-DCMAKE_EXE_LINKER_FLAGS_DEBUG_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib"
                "-DCMAKE_EXE_LINKER_FLAGS_RELEASE_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/lib"
                "-DCMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib"
                "-DCMAKE_SHARED_LINKER_FLAGS_RELEASE_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/lib"
                "-DCMAKE_STATIC_LINKER_FLAGS_DEBUG_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib"
                "-DCMAKE_STATIC_LINKER_FLAGS_RELEASE_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/lib"
                "-DCMAKE_Fortran_FLAGS_DEBUG_INIT:STRING=-O0 -Wl,/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib"
                "-DCMAKE_Fortran_FLAGS_RELEASE_INIT:STRING=-O3 -Wl,/LIBPATH:${CURRENT_INSTALLED_DIR}/lib"
                "-DCMAKE_Fortran_STANDARD_LIBRARIES_INIT=${flang_link_lib}"
                #"-DCMAKE_Fortran_LINKER_FLAGS_RELEASE_INIT=/LIBPATH:${CURRENT_INSTALLED_DIR}/lib ${flang_link_default_lib}"
                #"-DCMAKE_Fortran_LINKER_FLAGS_DEBUG_INIT=/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib ${flang_link_default_lib}"
                "-DCMAKE_REQUIRED_LINK_OPTIONS:STRING=-LIBPATH:${CURRENT_INSTALLED_DIR}/\$$<\$$<CONFIG:DEBUG>:debug/>lib/"
                #"-DCMAKE_Fortran_LINK_EXECUTABLE=\\\\\"\\\\\${_CMAKE_VS_LINK_EXE}<CMAKE_LINKER> \\\\\${CMAKE_CL_NOLOGO} <OBJECTS> \\\\\${CMAKE_START_TEMP_FILE} /out:<TARGET> /implib:<TARGET_IMPLIB> /pdb:<TARGET_PDB> /version:<TARGET_VERSION_MAJOR>.<TARGET_VERSION_MINOR>${_PLATFORM_LINK_FLAGS} <CMAKE_Fortran_LINK_FLAGS> <LINK_FLAGS> <LINK_LIBRARIES>\\\\\${CMAKE_END_TEMP_FILE}\\\\\""
                "${exta_uwp_link_flags}")
            vcpkg_list(APPEND additional_cmake_args_rel
                "-DCMAKE_EXE_LINKER_FLAGS_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/lib ${flangmainlibname} ${flang_link_default_lib}"
                "-DCMAKE_SHARED_LINKER_FLAGS_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/lib ${flang_link_default_lib}"
                "-DCMAKE_STATIC_LINKER_FLAGS_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/lib ${flang_link_default_lib}"
                "-DCMAKE_Fortran_FLAGS_INIT:STRING=${arch_flag} -Mreentrant -I ${CURRENT_INSTALLED_DIR}/include ${static_flang}${flang_compile_libs} -Wl,/LIBPATH:${CURRENT_INSTALLED_DIR}/lib ${extra_uwp_flags}"
                #"-DCMAKE_Fortran_LINKER_FLAGS_INIT=/LIBPATH:${CURRENT_INSTALLED_DIR}/lib ${flang_link_default_lib}"
                )
            vcpkg_list(APPEND additional_cmake_args_dbg
                "-DCMAKE_EXE_LINKER_FLAGS_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib ${flangmainlibname} ${flang_link_default_lib}"
                "-DCMAKE_SHARED_LINKER_FLAGS_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib ${flang_link_default_lib}"
                "-DCMAKE_STATIC_LINKER_FLAGS_INIT:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib ${flang_link_default_lib}"
                "-DCMAKE_Fortran_FLAGS_INIT:STRING=${arch_flag} -Mreentrant -I ${CURRENT_INSTALLED_DIR}/include ${static_flang}${flang_compile_libs} -Wl,/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib ${extra_uwp_flags}"
                #"-DCMAKE_Fortran_LINKER_FLAGS_INIT=/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib ${flang_link_default_lib}"
                )
            set(Z_VCPKG_USE_INTERNAL_Fortran TRUE CACHE INTERNAL "")
            set(Z_VCPKG_IS_INTERNAL_Fortran_Flang TRUE CACHE INTERNAL "")
        else()
            message(FATAL_ERROR "Unable to find a Fortran compiler using CMake. Please install one (e.g. gfortran) and make it available for CMake!")
        endif()
    endif()
    set("${arg_OUT_OPTIONS}" "${additional_cmake_args}" PARENT_SCOPE)
    set("${arg_OUT_OPTIONS_RELEASE}" "${additional_cmake_args_rel}" PARENT_SCOPE)
    set("${arg_OUT_OPTIONS_DEBUG}" "${additional_cmake_args_dbg}" PARENT_SCOPE)
endfunction()
