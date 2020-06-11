vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ocornut/imgui
    REF 5503c0a12e0c929e84b3f61b2cb4bb9177ea3da1 # v1.76
    SHA512 5cafb4f1c76975c38ddda0316da96e1f29e652fbc5c8d0e5158c9b21b11c0acc45e4b84fbc53bde1d07c4f2002744e1407f900e92eb8146e0a843b8b4f4b58bd
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    bindings       IMGUI_COPY_BINDINGS # should only be copied once, at most
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_RELEASE
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DIMGUI_COPY_BINDINGS=OFF
        -DIMGUI_SKIP_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
