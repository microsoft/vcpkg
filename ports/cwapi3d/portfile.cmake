vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cwapi3d/cwapi3dcpp
    REF fb4d65818da9cd0fc319fe7c38e4de1e9bc15cd7
    SHA512 f87a57f514532bdf94001378d3b9a545f83a6022f7640d5fd5b0f8ccb63faa1e0157b8aac34290586de3e53510c13f21dda843143d54a341b3b305a36722c22b
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/CwAPI3D)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
