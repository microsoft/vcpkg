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
    REF 924a72bbe8ad6a8915d9e06d2993d1badf5a8fb7
    SHA512 b479eabeb73dda5cf719956fe4b16eac9fa30ecc3202ddce37a896a54bda35caf0e90c492b4dea35988e22f81d5e2403b40805384d9b1134ea2139ccaeba8c5c
)

set(HERMES_SOURCE_PATH ${SOURCE_PATH})
message(STATUS "HERMES_SOURCE_PATH: ${HERMES_SOURCE_PATH}")

set(LLVM_SOURCE_RELATIVE_PATH llvm)
set(LLVM_BUILD_RELATIVE_PATH llvm_build_${VCPKG_TARGET_ARCHITECTURE})

set(BUILD_LLVM_CMAKE_FLAGS -Thost=x64)
set(BUILD_LLVM_FLAGS --build-system "Visual Studio 16 2019" --configure-only)

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(BUILD_LLVM_CMAKE_FLAGS ${BUILD_LLVM_CMAKE_FLAGS}\ -A\ Win32)
    set(BUILD_LLVM_FLAGS ${BUILD_LLVM_FLAGS} --32-bit)
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(BUILD_LLVM_CMAKE_FLAGS ${BUILD_LLVM_CMAKE_FLAGS}\ -A\ x64)
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(BUILD_LLVM_CMAKE_FLAGS ${BUILD_LLVM_CMAKE_FLAGS}\ -A\ ARM)
    set(BUILD_LLVM_FLAGS ${BUILD_LLVM_FLAGS} --32-bit)
elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(BUILD_LLVM_CMAKE_FLAGS ${BUILD_LLVM_CMAKE_FLAGS}\ -A\ ARM64)
else()
    message(FATAL_ERROR "Unsupported architecture")
endif()

message(STATUS "BUILD_LLVM_CMAKE_FLAGS: ${BUILD_LLVM_CMAKE_FLAGS}")
message(STATUS "BUILD_LLVM_FLAGS: ${BUILD_LLVM_FLAGS}")

set (BUILD_LLVM_COMMAND ${PYTHON2} ${HERMES_SOURCE_PATH}/utils/build_llvm.py ${BUILD_LLVM_FLAGS} --cmake-flags ${BUILD_LLVM_CMAKE_FLAGS} ${LLVM_SOURCE_RELATIVE_PATH} ${LLVM_BUILD_RELATIVE_PATH})
message(STATUS "BUILD_LLVM_COMMAND: ${BUILD_LLVM_COMMAND}")

# Confugure LLVM
# https://cmake.org/cmake/help/latest/generator/Visual%20Studio%2016%202019.html
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

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    SET(BUILD_ARCH "Win32")
ELSE()
    SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

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
    OPTIONS -Thost=x64 -DLLVM_SRC_DIR=${LLVM_SOURCE_PATH} -DLLVM_BUILD_DIR=${LLVM_BUILD_PATH} -DLLVM_ENABLE_LTO=OFF 
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/hermes RENAME copyright)

# Include files should not be duplicated
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# There should be no bin\ directory in a static build. A VcPkg policy
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/*.exe ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
endif()