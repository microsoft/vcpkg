vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO blackb1rd/neoactivemq-cpp
    REF "v${VERSION}"
    SHA512 e1f9af9c134c2f8a499ff837e11a54f8a1700defc994c37a3e088cef5d38c13aaa71d37d4ef71c16a760206f9303fe83521f1f40675e3a5f5de8f90d7949040f
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
        -DAMQCPP_BUILD_TESTS=OFF
        -DAMQCPP_SHARED_LIB=${AMQCPP_SHARED_LIB}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/neoactivemq-cpp)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
