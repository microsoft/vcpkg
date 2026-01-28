vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tbeu/matio
    REF "v${VERSION}"
    SHA512 170a97fa639f16f1290c1fa7b15f4b10296db216a35d901ebd75141c462db9cf4243b4fffa6aa823eed0a33aa8c5a927f562487a1558867c53f11f343d673f10
    HEAD_REF master
    PATCHES
        cmake-config.diff
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        extended-sparse MATIO_EXTENDED_SPARSE
        mat73           MATIO_WITH_HDF5
        mat73           MATIO_MAT73
        mat73           VCPKG_LOCK_FIND_PACKAGE_HDF5
        zlib            MATIO_WITH_ZLIB
        zlib            VCPKG_LOCK_FIND_PACKAGE_ZLIB
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DMATIO_BUILD_TESTING=OFF
        -DMATIO_PIC=OFF  # Flags provided by the toolchain
        -DMATIO_SHARED=${BUILD_SHARED}
        -DMATIO_USE_CONAN=OFF
    MAYBE_UNUSED_VARIABLES
        VCPKG_LOCK_FIND_PACKAGE_HDF5
        VCPKG_LOCK_FIND_PACKAGE_ZLIB
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

set(prefix "${CURRENT_INSTALLED_DIR}")
set(exec_prefix [[${prefix}]])
set(libdir [[${prefix}/lib]])
set(includedir [[${prefix}/include]])
configure_file("${SOURCE_PATH}/matio.pc.in" "${SOURCE_PATH}/matio.pc" @ONLY)
file(INSTALL "${SOURCE_PATH}/matio.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
if(NOT VCPKG_BUILD_TYPE)
    set(includedir [[${prefix}/../include]])
    file(INSTALL "${SOURCE_PATH}/matio.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
endif()
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES matdump AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
