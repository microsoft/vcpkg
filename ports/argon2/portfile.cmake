vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO P-H-C/phc-winner-argon2
    REF f57e61e19229e23c4445b85494dbf7c07de721cb
    SHA512 5a964b31613141424c65eef57f9e26ac5279b72d9c2f2b8cba9bb1fbf484e177183e7fe66700f10dc290e6f55f0a5dfff40235a9714d8d84d807cf5fa07cf7d4
    HEAD_REF master
    PATCHES
        visibility.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION  "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/argon2.pc.in" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        hwopt     OPTIMIZATIONS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DARGON2_SKIP_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_fixup_pkgconfig()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
