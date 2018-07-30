include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO catchorg/Catch2
    REF v2.3.0
    SHA512 e9a089b504c339e87bda0fb1a4040d9d19c932a4bc7dca41bdad6edfcf8c428f4152ff1e0c898dfdf6b20bd5d901c343bed00ad89351fa5182f3c106e0fb4b03
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

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Catch2 TARGET_PATH share/catch2)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

if(NOT EXISTS ${CURRENT_PACKAGES_DIR}/include/catch2/catch.hpp)
    message(FATAL_ERROR "Main includes have moved. Please update the forwarder.")
endif()

file(WRITE ${CURRENT_PACKAGES_DIR}/include/catch.hpp "#include <catch2/catch.hpp>")
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/catch2 RENAME copyright)
