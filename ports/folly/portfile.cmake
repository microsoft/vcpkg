if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
  message(FATAL_ERROR "Folly only supports the x64 architecture.")
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)

# Required to run build/generate_escape_tables.py et al.
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PYTHON3_DIR}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/folly
    REF v2017.11.27.00
    SHA512 738bb00047a7cbd807f2dccd64031763df80bbebca73f1ae9500b750dcad156dde84e47f4eda7af1bcd7abfae10c973da47515f2e111929979d1637869cf06ee
    HEAD_REF master
)

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(MSVC_USE_STATIC_RUNTIME ON)
else()
    set(MSVC_USE_STATIC_RUNTIME OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DMSVC_USE_STATIC_RUNTIME=${MSVC_USE_STATIC_RUNTIME}
)

# Folly runs built executables during the build, so they need access to the installed DLLs.
set(ENV{PATH} "$ENV{PATH};${CURRENT_INSTALLED_DIR}/bin;${CURRENT_INSTALLED_DIR}/debug/bin")

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets()

# changes target search path
file(READ ${CURRENT_PACKAGES_DIR}/share/folly/folly-targets.cmake FOLLY_MODULE)
string(REPLACE "${CURRENT_INSTALLED_DIR}/lib/" "" FOLLY_MODULE "${FOLLY_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/folly/folly-targets.cmake "${FOLLY_MODULE}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/folly)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/folly/LICENSE ${CURRENT_PACKAGES_DIR}/share/folly/copyright)
