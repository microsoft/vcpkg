# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/double-conversion-d4d68e4e788bec89d55a6a3e33af674087837c82)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/google/double-conversion/archive/d4d68e4e788bec89d55a6a3e33af674087837c82.zip"
    FILENAME "d4d68e4e788bec89d55a6a3e33af674087837c82.zip"
    SHA512 1406dc22b4ea71e1a2490f96cfed3230e122b97607c83ba106df4e90c7e4bfdcfc136c88741e7f1127237b38b4944d462ec5a4627a71f5ea3fe14afbcc64cd44
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/mscv_vers.patch
)

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/msvc/double-conversion.vcxproj
)

message(STATUS "Installing")
file(INSTALL
    ${SOURCE_PATH}/msvc/Debug/Win32/double-conversion.lib
    ${SOURCE_PATH}/msvc/Debug/Win32/double-conversion.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)
file(INSTALL
    ${SOURCE_PATH}/msvc/Release/Win32/double-conversion.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)

file(COPY ${SOURCE_PATH}/double-conversion DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_copy_pdbs()

message(STATUS "Installing done")

# Include files should not be duplicated into the /debug/include directory.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/doubleconversion)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/doubleconversion/LICENSE ${CURRENT_PACKAGES_DIR}/share/doubleconversion/copyright)

# Move the Release CMake files.
file(GLOB cacheFiles ${CURRENT_PACKAGES_DIR}/CMake/*.cmake)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/doubleconversion/release)
foreach(cacheFile ${cacheFiles})
    get_filename_component(filename ${cacheFile} NAME)
    file(RENAME ${cacheFile} ${CURRENT_PACKAGES_DIR}/share/doubleconversion/release/${filename})
endforeach()
# Remove the original directory.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/CMake)

# Move the Debug CMake files.
file(GLOB cacheFiles ${CURRENT_PACKAGES_DIR}/debug/CMake/*.cmake)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/doubleconversion/debug)
foreach(cacheFile ${cacheFiles})
    get_filename_component(filename ${cacheFile} NAME)
    file(RENAME ${cacheFile} ${CURRENT_PACKAGES_DIR}/share/doubleconversion/debug/${filename})
endforeach()
# Remove the original directory.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/CMake)

