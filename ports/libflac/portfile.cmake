vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/flac
    REF 1151c93e992bb8c7c6394e04aa880d711c531c7f #1.3.4
    SHA512 ebf8de3dbd8fc2153af2f4a05ecc04817570233c30e0ec1fbdbc99f810860801b951248ca6404152cba4038f5839985f4076bcee477c00fd23bd583a45b89b17
    HEAD_REF master
    PATCHES
        uwp-library-console.patch
        uwp-createfile2.patch
        fix-compile-options.patch
)

if(VCPKG_TARGET_IS_MINGW)
    set(WITH_STACK_PROTECTOR OFF)
    string(APPEND VCPKG_C_FLAGS " -D_FORTIFY_SOURCE=0")
    string(APPEND VCPKG_CXX_FLAGS " -D_FORTIFY_SOURCE=0")
else()
    set(WITH_STACK_PROTECTOR ON)
endif()

if("asm" IN_LIST FEATURES)
    VCPKG_FIND_ACQUIRE_PROGRAM(NASM)
    GET_FILENAME_COMPONENT(NASM_PATH "${NASM}" DIRECTORY)
    vcpkg_add_to_path("${NASM_PATH}")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        asm WITH_ASM
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_PROGRAMS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_DOCS=OFF
        -DBUILD_TESTING=OFF
        -DWITH_STACK_PROTECTOR=${WITH_STACK_PROTECTOR}
        -DINSTALL_MANPAGES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME FLAC CONFIG_PATH share/FLAC/cmake)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE "${CURRENT_PACKAGES_DIR}/share/LICENSE")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/FLAC/export.h"
        "#if defined(FLAC__NO_DLL)"
        "#if 0"
    )
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/FLAC++/export.h"
        "#if defined(FLAC__NO_DLL)"
        "#if 0"
    )
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/FLAC/export.h"
        "#if defined(FLAC__NO_DLL)"
        "#if 1"
    )
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/FLAC++/export.h"
        "#if defined(FLAC__NO_DLL)"
        "#if 1"
    )
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/flac.pc" " -lm" "")

    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/flac.pc")
       vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/flac.pc" " -lm" "")
    endif()
endif()

vcpkg_fixup_pkgconfig()

# This license (BSD) is relevant only for library - if someone would want to install
# FLAC cmd line tools as well additional license (GPL) should be included
file(INSTALL "${SOURCE_PATH}/COPYING.Xiph" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
