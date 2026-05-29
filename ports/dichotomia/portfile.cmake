vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO zem-invictus/dichotomia
        REF v1.0.1
        SHA512 5c61e6405302a25af47d64896754546df1a7b761fada6e8d77315aaf1c1e683dbd5488b3d4057e764de7a328c7e8fbb3e2311af44df1b32b49c42cc7552efbab
        HEAD_REF main
)

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
        -DDICHOTOMIA_BUILD_TESTING=OFF
        -DDICHOTOMIA_BUILD_PYTHON_BINDINGS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
        PACKAGE_NAME dichotomia
        CONFIG_PATH lib/cmake/dichotomia
)

file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug"
        "${CURRENT_PACKAGES_DIR}/lib"
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)