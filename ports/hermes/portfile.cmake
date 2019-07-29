include(vcpkg_common_functions)

#Find Python and add it to the path
vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_EXE_PATH ${PYTHON2} DIRECTORY)
vcpkg_add_to_path("${PYTHON2_EXE_PATH}")

#Find GIT and add it to the path
find_program(GIT NAMES git git.cmd)
get_filename_component(GIT_EXE_PATH ${GIT} DIRECTORY)
vcpkg_add_to_path("${GIT_EXE_PATH}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mganandraj/Hermes
    REF 83d11fc7a9c0c22f46274c397c8615de89434293
    SHA512 06580f1cea77074cb996ee99fab065630203410b0e49174de6f3a2c7c2cabbdbfa0f02147093f78d99b6939609b806e10c83aa27884aadf8a2438af514cfebb5
)

set(HERMES_SOURCE_PATH ${SOURCE_PATH})
message(STATUS "HERMES_SOURCE_PATH: ${HERMES_SOURCE_PATH}")

set(LLVM_SOURCE_RELATIVE_PATH llvm)
set(LLVM_BUILD_RELATIVE_PATH llvm_build_${VCPKG_TARGET_ARCHITECTURE})

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    SET(BUILD_ARCH "Win32")
ELSE()
    SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

set(BUILD_LLVM_CMAKE_FLAGS -Thost=x64\ -A\ ${BUILD_ARCH})
set(BUILD_LLVM_FLAGS --build-system "Visual Studio 16 2019" --configure-only)
set(WINDOWS_CROSSCOMPILE_TO_ARM OFF)

#if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
#    set(BUILD_LLVM_CMAKE_FLAGS ${BUILD_LLVM_CMAKE_FLAGS}\ -A\ Win32)
#    set(BUILD_LLVM_FLAGS ${BUILD_LLVM_FLAGS} --32-bit)
#elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
#    set(BUILD_LLVM_CMAKE_FLAGS ${BUILD_LLVM_CMAKE_FLAGS}\ -A\ x64)
#elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
#    set(BUILD_LLVM_CMAKE_FLAGS ${BUILD_LLVM_CMAKE_FLAGS}\ -A\ ARM)
#elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
#    set(BUILD_LLVM_CMAKE_FLAGS ${BUILD_LLVM_CMAKE_FLAGS}\ -A\ ARM64)
#else()
#    message(FATAL_ERROR "Unsupported architecture")
#endif()

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    # https://github.com/llvm/llvm-project/blob/master/llvm/docs/HowToCrossCompileLLVM.rst
    set(BUILD_LLVM_CMAKE_FLAGS ${BUILD_LLVM_CMAKE_FLAGS}\ -DLLVM_INCLUDE_BENCHMARKS=OFF\ -DLLVM_INCLUDE_TESTS=OFF\ -DLLVM_INCLUDE_TOOLS=OFF\ -DLLVM_INCLUDE_UTILS=OFF)
    set(BUILD_LLVM_CMAKE_FLAGS ${BUILD_LLVM_CMAKE_FLAGS}\ -DLLVM_TARGET_ARCH=ARM\ -DLLVM_TARGETS_TO_BUILD=ARM)
    
    set (LLVM_TABLEGEN ${HERMES_SOURCE_PATH}/llvm_build_x86/Release/bin/llvm-tblgen.exe)
    if(NOT EXISTS "${LLVM_TABLEGEN}")
        message(FATAL_ERROR "${LLVM_TABLEGEN} is not available. x86 arch should be build before cross compiling to ARM")
    endif()

    set(BUILD_LLVM_CMAKE_FLAGS ${BUILD_LLVM_CMAKE_FLAGS}\ -DLLVM_TABLEGEN=${LLVM_TABLEGEN})
    set(WINDOWS_CROSSCOMPILE_TO_ARM ON)
endif()

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(BUILD_LLVM_FLAGS ${BUILD_LLVM_FLAGS} --32-bit)
endif()

message(STATUS "BUILD_LLVM_CMAKE_FLAGS: ${BUILD_LLVM_CMAKE_FLAGS}")
message(STATUS "BUILD_LLVM_FLAGS: ${BUILD_LLVM_FLAGS}")

set (BUILD_LLVM_COMMAND ${PYTHON2} ${HERMES_SOURCE_PATH}/utils/build_llvm.py ${BUILD_LLVM_FLAGS} --cmake-flags ${BUILD_LLVM_CMAKE_FLAGS} ${LLVM_SOURCE_RELATIVE_PATH} ${LLVM_BUILD_RELATIVE_PATH})
message(STATUS "BUILD_LLVM_COMMAND: ${BUILD_LLVM_COMMAND}")

# Confugure LLVM
# Ref: https://cmake.org/cmake/help/latest/generator/Visual%20Studio%2016%202019.html
vcpkg_execute_required_process(
   COMMAND ${BUILD_LLVM_COMMAND}
   WORKING_DIRECTORY ${HERMES_SOURCE_PATH}
   LOGNAME build_llvm_${TARGET_TRIPLET}
)

# A more proper way to create paths ?
set(LLVM_SOURCE_PATH ${HERMES_SOURCE_PATH}/${LLVM_SOURCE_RELATIVE_PATH})
set(LLVM_BUILD_PATH ${HERMES_SOURCE_PATH}/${LLVM_BUILD_RELATIVE_PATH})

# default linkage.
set(VCPKG_LIBRARY_LINKAGE static)

# TODO::vcpkg_build_cmake.cmake needs to be fixes so that other release configs (such as MinSize..) can be used.
vcpkg_build_msbuild(
    PROJECT_PATH ${LLVM_BUILD_PATH}/LLVM.sln
    PLATFORM ${BUILD_ARCH}
    RELEASE_CONFIGURATION Release
)

vcpkg_configure_cmake(
    SOURCE_PATH ${HERMES_SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    GENERATOR "Visual Studio 16 2019"
    OPTIONS -Thost=x64 -A ${BUILD_ARCH} -DLLVM_SRC_DIR=${LLVM_SOURCE_PATH} -DLLVM_BUILD_DIR=${LLVM_BUILD_PATH} -DLLVM_ENABLE_LTO=OFF -DWINDOWS_CROSSCOMPILE_TO_ARM=${WINDOWS_CROSSCOMPILE_TO_ARM}
)

# default linkage. We were force to set the library linkage to static for building the LLVM. But, VcPkg policy disallows publishing dynamic libs in that setting.
# Resetting back to dynamic linkage so that VcPkg lets us install dlls.
set(VCPKG_LIBRARY_LINKAGE dynamic)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/hermes RENAME copyright)

# Include files should not be duplicated. A VcPkg policy!
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# There should be no bin\ directory in the distribution. A VcPkg policy!
    file(GLOB_RECURSE EXECUTABLES
    ${CURRENT_PACKAGES_DIR}/bin/*.exe
    ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe
)

file(REMOVE ${EXECUTABLES})