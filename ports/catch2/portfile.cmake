vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO catchorg/Catch2
    REF 255aa5f2afe1a622c97422f65ace6ca915be0d8d # v2.11.3
    SHA512 e46d14105928fb43cd041bd4d797d255233d302d87f06823f7ae49f95b1e9a2fae321de4812f6e9ce3028a904cbd668cdf0ad3e6673bc5297f29d1fb1c46f130
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
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
