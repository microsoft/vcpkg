vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ndevilla/iniparser
    REF f858275f7f307eecba84c2f5429483f9f28007f8
    SHA512 48c80b2163f86d8ca0f3253128d8528214e2f0680b4bceb686180c01b29cd2a0c3b9d6e7156a8e28649b14bc1d8a51b34c2d3d258013b35f69aaf6c3ded9ecdc
    HEAD_REF master
    PATCHES
        win32_ssize_t.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-${PORT} TARGET_PATH share/unofficial-${PORT})

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_fixup_pkgconfig()
