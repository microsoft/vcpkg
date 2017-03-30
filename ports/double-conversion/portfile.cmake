# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/double-conversion-d4d68e4e788bec89d55a6a3e33af674087837c82)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/google/double-conversion/archive/d4d68e4e788bec89d55a6a3e33af674087837c82.zip"
    FILENAME "d4d68e4e788bec89d55a6a3e33af674087837c82.zip"
    SHA512 1406dc22b4ea71e1a2490f96cfed3230e122b97607c83ba106df4e90c7e4bfdcfc136c88741e7f1127237b38b4944d462ec5a4627a71f5ea3fe14afbcc64cd44
)
vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_configure_cmake(SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=True
    OPTIONS_DEBUG -DCMAKE_DEBUG_POSTFIX=d)
vcpkg_install_cmake()
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(RENAME ${CURRENT_PACKAGES_DIR}/CMake ${CURRENT_PACKAGES_DIR}/share/double-conversion)
file(READ ${CURRENT_PACKAGES_DIR}/debug/CMake/double-conversionLibraryDepends-debug.cmake DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" DEBUG_MODULE "${DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/double-conversion/double-conversionLibraryDepends-debug.cmake "${DEBUG_MODULE}")
#file(COPY ${SOURCE_PATH}/double-conversion DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/CMake)
vcpkg_copy_pdbs()

message(STATUS "Installing done")

# Include files should not be duplicated into the /debug/include directory.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/double-conversion)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/double-conversion/LICENSE ${CURRENT_PACKAGES_DIR}/share/double-conversion/copyright)
