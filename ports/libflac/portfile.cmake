vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/flac
    REF b32e5cbf9818ca23dd22aaa75522042c16ea7d17 #1.4.2
    SHA512 911891203f3064b39058e209b62fc3fac8940ed01cc3c3d75c9e3e6f94b5cc5905efde94304a6aafa453adde2da2f9bafea9fb5297e6231562133a8acac2ea47
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

vcpkg_cmake_config_fixup(PACKAGE_NAME FLAC CONFIG_PATH lib/cmake/FLAC)

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
