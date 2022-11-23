vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectX-Headers
    REF v1.606.4
    SHA512 3fb4142f8ceedd8484f5f7dae5804a7a0012951de344936fbf22991d6ae659d4e5093e1627bfe51c3cb0859340b13171c4f6aa68377ec26ac05038acaad8c540
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DDXHEADERS_BUILD_TEST=OFF -DDXHEADERS_BUILD_GOOGLE_TEST=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/directx-headers/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
