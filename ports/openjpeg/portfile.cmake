include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/openjpeg-2.1.2)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/uclouvain/openjpeg/archive/v2.1.2.zip"
    FILENAME "openjpeg-2.1.2.zip"
    SHA512 45518b92b2a8e7218ab3efdebe1acf0437c01ab2e4d5769da17103a76ba38a7305fb36d0ceeca0576d53c071a3482d2d3f01d6e48a569191290bfba9274ef7b4
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DBUILD_CODEC:BOOL=OFF
            -DOPENJPEG_INSTALL_PACKAGE_DIR=share/openjpeg
)

vcpkg_build_cmake()
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle debug cmake config files (see https://github.com/Microsoft/vcpkg/issues/77)
file(READ ${CURRENT_PACKAGES_DIR}/debug/share/openjpeg/OpenJPEGTargets-debug.cmake OPENJPEG_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" OPENJPEG_DEBUG_MODULE "${OPENJPEG_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/openjpeg/OpenJPEGTargets-debug.cmake  "${OPENJPEG_DEBUG_MODULE}")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Cleanup bin directories in static builds
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Cleanup Visual C++ Redistributable runtime
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/msvcp140.dll)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/vcruntime140.dll)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/msvcp140.dll)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/vcruntime140.dll)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openjpeg)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/openjpeg/LICENSE ${CURRENT_PACKAGES_DIR}/share/openjpeg/copyright)

vcpkg_copy_pdbs()