vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uchardet/uchardet
    REF 6f38ab95f55afd45ee6ccefcb92d21034b4a2521
    SHA512 a2e655d6e1eb6934cf93d99d27dfebc382eb01b6e62021f56b3fa71d269a851e7d68fe57536d40470e0329b3aa035467a9cdd9e11698f8ff76f06611ea7a58d1
    HEAD_REF master
    PATCHES fix-uwp-build.patch
)


vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tool BUILD_BINARY
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DBUILD_BINARY=OFF
    OPTIONS_RELEASE
        ${FEATURE_OPTIONS}
    OPTIONS
        -DBUILD_STATIC=${BUILD_STATIC}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

if(tool IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES uchardet AUTO_CLEAN)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/man"
)

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
