# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taocpp/json
    REF 8520fca2a054be775e406eaec66f33f02a7076e3
    SHA512 44bfd0252ed42d2619ca65e92d0f483895fd735b98a81e7f844526f78893a8624133ba356ad41f8c691571bf9f56823f62bfc0f294394e6e0f780b44a0b085fd
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DTAOCPP_JSON_BUILD_TESTS=OFF
        -DTAOCPP_JSON_BUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/taocpp-json/cmake)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug
    ${CURRENT_PACKAGES_DIR}/share/doc
)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
file(COPY ${SOURCE_PATH}/LICENSE.double-conversion DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(COPY ${SOURCE_PATH}/LICENSE.itoa DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(COPY ${SOURCE_PATH}/LICENSE.ryu DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
