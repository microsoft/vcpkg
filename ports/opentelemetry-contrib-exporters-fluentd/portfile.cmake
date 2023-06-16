if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-telemetry/opentelemetry-cpp-contrib
    REF 05b20a304ef17f13185bfe3639f94c36eff7ceb6  # Roughly maps to 1.2.0
    HEAD_REF main
    SHA512 51bd9514d08296784bb55015956851d436493d93539caf49a2664848b480ce86086f0e891ac0c07a285ff56fbcfcd4eeeb5343a36d7a05587a6f74b9f05b5306
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/exporters/fluentd"
    OPTIONS
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_POSITION_INDEPENDENT_CODE=TRUE
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
