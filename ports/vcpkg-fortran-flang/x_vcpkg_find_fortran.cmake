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


function(x_vcpkg_find_fortran out_var)
    if("${ARGC}" GREATER "1")
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra args: ${ARGN}")
    endif()

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
                set(extra_uwp_flags "-Wl,/NODEFAULTLIB")
                set(exta_uwp_link_flags "-DCMAKE_SHARED_LINKER_FLAGS_INIT:STRING=-Wl,/APPCONTAINER")
            endif()
            if(VCPKG_CRT_LINKAGE STREQUAL "static")
            endif()
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
            #-noFlangLibs -fno-fortran-main
            vcpkg_list(APPEND additional_cmake_args
                "-DCMAKE_Fortran_COMPILER=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang/bin/flang.exe"
                "-DCMAKE_C_COMPILER=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/llvm-flang/bin/clang-cl.exe"
                #"-DCMAKE_Fortran_COMPILER_ID=Flang"
                #-DCMAKE_Fortran_COMPILER_WORKS=1
                #-DCMAKE_Fortran_ABI_COMPILED=0
                #-DCMAKE_Fortran_COMPILER_SUPPORTS_F90=1
                #"-DMSVC_VERSION=1930"
                #"-DCMAKE_C_COMPILER_VERSION=19.30"
                #"-DCMAKE_CXX_COMPILER_VERSION=19.30"
                "-DCMAKE_EXE_LINKER_FLAGS:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/lib ${flangmainlibname}"
                "-DCMAKE_EXE_LINKER_FLAGS_DEBUG:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib"
                "-DCMAKE_EXE_LINKER_FLAGS_RELEASE:STRING=/LIBPATH:${CURRENT_INSTALLED_DIR}/lib"
                "-DCMAKE_Fortran_FLAGS:STRING=-Xflang -noFlangLibs -static-flang-libs ${extra_uwp_flags}"
                "-DTIME_FUNC=EXT_ETIME"
                "-DCMAKE_Fortran_FLAGS_RELEASE:STRING=-Xflang -noFlangLibs -static-flang-libs -Wl,/LIBPATH:${CURRENT_INSTALLED_DIR}/lib"
                "-DCMAKE_Fortran_FLAGS_DEBUG:STRING=-Xflang -noFlangLibs -static-flang-libs -Wl,/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib"
                "-DCMAKE_Fortran_STANDARD_LIBRARIES_INIT=${flanglibname} ${flangrtilibname} ${pgmathlibname} ${omplibname}"
                "-DCMAKE_Fortran_LINKER_FLAGS=/LIBPATH:${CURRENT_INSTALLED_DIR}/lib ${flanglibname} ${flangrtilibname} ${pgmathlibname} ${omplibname}"
                "-DCMAKE_Fortran_LINKER_FLAGS_RELEASE=-Wl,/LIBPATH:${CURRENT_INSTALLED_DIR}/lib ${flanglibname} ${flangrtilibname} ${pgmathlibname} ${omplibname}"
                "-DCMAKE_Fortran_LINKER_FLAGS_DEBUG=-Wl,/LIBPATH:${CURRENT_INSTALLED_DIR}/debug/lib ${flanglibname} ${flangrtilibname} ${pgmathlibname} ${omplibname}"
                #"-DCMAKE_Fortran_LINK_EXECUTABLE=\\\\\"\\\\\${_CMAKE_VS_LINK_EXE}<CMAKE_LINKER> \\\\\${CMAKE_CL_NOLOGO} <OBJECTS> \\\\\${CMAKE_START_TEMP_FILE} /out:<TARGET> /implib:<TARGET_IMPLIB> /pdb:<TARGET_PDB> /version:<TARGET_VERSION_MAJOR>.<TARGET_VERSION_MINOR>${_PLATFORM_LINK_FLAGS} <CMAKE_Fortran_LINK_FLAGS> <LINK_FLAGS> <LINK_LIBRARIES>\\\\\${CMAKE_END_TEMP_FILE}\\\\\""
                "${exta_uwp_link_flags}")
            set(VCPKG_USE_INTERNAL_Fortran TRUE CACHE INTERNAL "")
        else()
            message(FATAL_ERROR "Unable to find a Fortran compiler using 'CMakeDetermineFortranCompiler'. Please install one (e.g. gfortran) and make it available on the PATH!")
        endif()
    endif()
    set("${out_var}" "${additional_cmake_args}" PARENT_SCOPE)
endfunction()
