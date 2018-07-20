
include(vcpkg_common_functions)
set(FONTCONFIG_VERSION 2.12.4)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/fontconfig-${FONTCONFIG_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.freedesktop.org/software/fontconfig/release/fontconfig-${FONTCONFIG_VERSION}.tar.gz"
    FILENAME "fontconfig-${FONTCONFIG_VERSION}.tar.gz"
    SHA512 2be3ee0e8e0e3b62571135a3cae06e456c289dd1ad40ef2a7c780406418ee5efce863a833eca5a8ef55bc737a0ea04ef562bba6fd27e174ae43e42131b52810d)

vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/fcobjtypehash.patch"
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFC_INCLUDE_DIR=${CMAKE_CURRENT_LIST_DIR}/include
    OPTIONS_DEBUG
        -DFC_SKIP_TOOLS=ON
        -DFC_SKIP_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    foreach(HEADER fcfreetype.h fontconfig.h)
        file(READ ${CURRENT_PACKAGES_DIR}/include/fontconfig/${HEADER} FC_HEADER)
        string(REPLACE "#define FcPublic" "#define FcPublic __declspec(dllimport)" FC_HEADER "${FC_HEADER}")
        file(WRITE ${CURRENT_PACKAGES_DIR}/include/fontconfig/${HEADER} "${FC_HEADER}")
    endforeach()
endif()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/fontconfig)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/fontconfig/COPYING ${CURRENT_PACKAGES_DIR}/share/fontconfig/copyright)
