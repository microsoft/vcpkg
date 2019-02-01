include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QuantStack/xeus
    REF 7541d476e054bf2f22f76a443e19a248e758ca48
    SHA512 87d49f42067b07871f9365966b00d70f15b9597aa14b2b9fdd266f5755ad7303a307354434be37db0dfd62f3edd97726a3e1a33c9e7e16577c8ebad6468b7876
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DDOWNLOAD_GTEST=OFF
        -DXEUS_USE_SHARED_CRYPTOPP=OFF # `cryptopp` port currently only supports static linkage.
        -DDISABLE_ARCH_NATIVE=OFF
)

vcpkg_install_cmake()

#vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
#configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
#vcpkg_test_cmake(PACKAGE_NAME ${PORT})
