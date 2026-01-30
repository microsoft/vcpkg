vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO blackb1rd/neoactivemq-cpp
    REF "v${VERSION}"
    SHA512 f7b14a5a62aefd8d08fe70a6bf31e441042bf0457eb66de45a0816c504cae54f9c57e5240167a802686e5fa655a325ca3ffa974e563ff0ee1f69b39bf08a38ce
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
