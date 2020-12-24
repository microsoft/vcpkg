vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO onqtam/doctest
    REF 1c8da00c978c19e00a434b2b1f854fcffc9fba35 #version 2.4.0
    SHA512 aa0d10a0fbd6d3b9f89c3d909bce332804610390a310c3f6ac89c44c76a07f00a8770d30d6481627572bdbd9dabccfe6c6f9f7b5fb6b323bf5120ec623dd358f
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DDOCTEST_WITH_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/doctest)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)