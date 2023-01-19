vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO "rollbear/strong_type"
    REF "v8"
    SHA512 "d9bd43c090aac6d36183f70f6cc066484357e997b1b2081114ecb459f80cd990ad31c9141948bf2a9d12ac504da77331a470f2f0eaadc57fbfc9bec6c4de6464"
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "strong_type" CONFIG_PATH "lib/cmake/strong_type")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
