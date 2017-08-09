set(OPENEXR_VERSION 2.2.0)
set(OPENEXR_HASH 017abbeeb6b814508180721bc8e8940094965c4c55b135a198c6bcb109a04bf7f72e4aee81ee72cb2185fe818a41d892b383e8d2d59f40c673198948cb79279a)

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/openexr-${OPENEXR_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "http://download.savannah.nongnu.org/releases/openexr/openexr-${OPENEXR_VERSION}.tar.gz"
    FILENAME "openexr-${OPENEXR_VERSION}.tar.gz"
    SHA512 ${OPENEXR_HASH})

vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/add-missing-export.patch)

# Ensure helper executables can run during build
set(ENV{PATH} "$ENV{PATH};${CURRENT_INSTALLED_DIR}/bin")

# In debug build buildsystem cannot locate IlmBase headers
set(VCPKG_C_FLAGS_DEBUG "${VCPKG_C_FLAGS_DEBUG}")
set(VCPKG_CXX_FLAGS_DEBUG "${VCPKG_CXX_FLAGS_DEBUG} -I\"${CURRENT_INSTALLED_DIR}/include/OpenExr\"")

vcpkg_configure_cmake(SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DILMBASE_PACKAGE_PREFIX=${CURRENT_INSTALLED_DIR}/debug
    OPTIONS_RELEASE
        -DILMBASE_PACKAGE_PREFIX=${CURRENT_INSTALLED_DIR})

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    foreach(SUBDIR "" "/debug")
        file(GLOB DLLS ${CURRENT_PACKAGES_DIR}${SUBDIR}/lib/*.dll)
        file(COPY ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}${SUBDIR}/bin)
        file(REMOVE ${DLLS})
    endforeach()
endif()

vcpkg_copy_pdbs()

file(READ ${CURRENT_PACKAGES_DIR}/include/OpenEXR/ImfExport.h HEADER_FILE)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    string(REPLACE "defined(OPENEXR_DLL)" "1" HEADER_FILE "${HEADER_FILE}")
else()
    string(REPLACE "defined(OPENEXR_DLL)" "0" HEADER_FILE "${HEADER_FILE}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/OpenEXR/ImfExport.h "${HEADER_FILE}")

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openexr)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/openexr/LICENSE ${CURRENT_PACKAGES_DIR}/share/openexr/copyright)
