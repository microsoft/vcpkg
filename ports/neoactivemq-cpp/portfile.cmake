vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO blackb1rd/neoactivemq-cpp
    REF "v${VERSION}"
    SHA512 db1eb2aa5bdfbc42c92dec9536e36503ca93d6e2d5f9002bba49f7f873ce75c21c5ea5bd7c58950d27d3be7cf54383b61117492cdbf2c6c543cfa47be40ca1cd
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl AMQCPP_USE_SSL
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" AMQCPP_SHARED_LIB)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DAMQCPP_BUILD_EXAMPLES=OFF
        -DWITH_TESTS=OFF
        -DAMQCPP_SHARED_LIB=${AMQCPP_SHARED_LIB}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/neoactivemq-cpp)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
