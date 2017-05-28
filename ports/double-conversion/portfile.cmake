# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    # This is due to a bug in CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS on arm
    message(STATUS "DLLs on arm aren't currently supported. Building static libs instead.")
    set(VCPKG_LIBRARY_LINKAGE "static")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/double-conversion
    REF d4d68e4e788bec89d55a6a3e33af674087837c82
    SHA512 200b2f5ff1dfe4591f3c168e465ed154993469b7adf22b5bb2ae707d60d360ac45b51385f2d09d2a8358a914db01a790050cd9d9b78645f5ea5159410ce1de17
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/001-fix-arm.patch
)

set(OPTIONS)
if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(OPTIONS -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=True)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${OPTIONS}
)

vcpkg_install_cmake()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(RENAME ${CURRENT_PACKAGES_DIR}/CMake ${CURRENT_PACKAGES_DIR}/share/double-conversion)
file(READ ${CURRENT_PACKAGES_DIR}/debug/CMake/double-conversionLibraryDepends-debug.cmake DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" DEBUG_MODULE "${DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/double-conversion/double-conversionLibraryDepends-debug.cmake "${DEBUG_MODULE}")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/CMake)

vcpkg_copy_pdbs()

# Include files should not be duplicated into the /debug/include directory.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/double-conversion)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/double-conversion/LICENSE ${CURRENT_PACKAGES_DIR}/share/double-conversion/copyright)
