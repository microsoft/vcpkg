vcpkg_fail_port_install(ON_TARGET "uwp")

set(FONTCONFIG_VERSION 2.12.4)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.freedesktop.org/software/fontconfig/release/fontconfig-${FONTCONFIG_VERSION}.tar.gz"
    FILENAME "fontconfig-${FONTCONFIG_VERSION}.tar.gz"
    SHA512 2be3ee0e8e0e3b62571135a3cae06e456c289dd1ad40ef2a7c780406418ee5efce863a833eca5a8ef55bc737a0ea04ef562bba6fd27e174ae43e42131b52810d
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${FONTCONFIG_VERSION}
    PATCHES fcobjtypehash.patch
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

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-fontconfig TARGET_PATH share/unofficial-fontconfig)

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    foreach(HEADER fcfreetype.h fontconfig.h)
        if(VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP)
            vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/fontconfig/${HEADER}
               "#define FcPublic"
               "#define FcPublic __declspec(dllimport)"
            )
        else()
            vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/fontconfig/${HEADER}
               "#define FcPublic"
               "#define FcPublic __attribute__((visibility(\"default\")))"
            )
        endif()
    endforeach()
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

