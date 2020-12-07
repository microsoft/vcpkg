vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://gitlab.freedesktop.org/uchardet/uchardet
    REF 8681fc060ea07f646434cd2d324e4a5aa7c495c4
    SHA512 4fe974b8ec2ffe27050cbf39a0abe2aed0ebb97a2df75680f385014137aad24a29c899e5ea3e8168004978c571e8b375ea02908b0b0de0e59cf9fbb83c397792
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tool BUILD_BINARY
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

if(VCPKG_TARGET_IS_UWP)
    # uchardet calls `fopen` and `strdup`, which makes UWP unhappy.
    set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_DEPRECATE")
    set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_DEPRECATE")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DBUILD_BINARY=OFF
    OPTIONS_RELEASE
        ${FEATURE_OPTIONS}
    OPTIONS
        -DBUILD_STATIC=${BUILD_STATIC}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()


if("tool" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES uchardet AUTO_CLEAN)
endif()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/share/man
)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
