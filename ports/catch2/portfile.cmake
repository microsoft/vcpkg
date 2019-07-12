include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO catchorg/Catch2
    REF 2f631bb8087a0355d2b23a75a28d936ce237659d
    SHA512 1f5f41e1918524919c970f78f9f2e5a736c1f091cdbf974d549eadde7a7e3eef78d1ed72a4cbd7fc0026cabd9d4d63d0ffc86d51a1b6aa86a476da657a774d20
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCATCH_BUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Catch2)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

if(NOT EXISTS ${CURRENT_PACKAGES_DIR}/include/catch2/catch.hpp)
    message(FATAL_ERROR "Main includes have moved. Please update the forwarder.")
endif()

file(WRITE ${CURRENT_PACKAGES_DIR}/include/catch.hpp "#include <catch2/catch.hpp>")
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/catch2 RENAME copyright)
