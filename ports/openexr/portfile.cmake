set(OPENEXR_VERSION 2.2.1)
set(OPENEXR_HASH 192100c6ac47534f3a93c55327d2ab90b07a8265156855086b326184328c257dcde12991b3f3f1831e2df4226fe884adcfe481c2f02a157c715aee665e89a480)

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/openexr-${OPENEXR_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "http://download.savannah.nongnu.org/releases/openexr/openexr-${OPENEXR_VERSION}.tar.gz"
    FILENAME "openexr-${OPENEXR_VERSION}.tar.gz"
    SHA512 ${OPENEXR_HASH})

vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH}
    PATCHES
    "${CMAKE_CURRENT_LIST_DIR}/add-missing-export.patch"
    "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt.patch"
    "${CMAKE_CURRENT_LIST_DIR}/fix-static-linking.patch"
)

# Ensure helper executables can run during build
set(ENV{PATH} "$ENV{PATH};${CURRENT_INSTALLED_DIR}/bin")

# In debug build buildsystem cannot locate IlmBase headers
set(VCPKG_C_FLAGS_DEBUG "${VCPKG_C_FLAGS_DEBUG}")
set(VCPKG_CXX_FLAGS_DEBUG "${VCPKG_CXX_FLAGS_DEBUG} -I\"${CURRENT_INSTALLED_DIR}/include/OpenEXR\"")

vcpkg_configure_cmake(SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DILMBASE_PACKAGE_PREFIX=${CURRENT_INSTALLED_DIR}/debug
    OPTIONS_RELEASE
        -DILMBASE_PACKAGE_PREFIX=${CURRENT_INSTALLED_DIR})

vcpkg_install_cmake()

# if you need to have OpenEXR tools, edit CMakeLists.txt.patch and remove the part that disables building executables,
# then remove the following line which deletes them and finally use vcpkg_copy_tool_dependencies() to save them
# (may require additional patching to the OpenEXR toolchain which is really broken)
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

file(COPY ${CMAKE_CURRENT_LIST_DIR}/FindOpenEXR.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/openexr)
