include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO catchorg/Catch2
    REF v2.11.0
    SHA512 0a7843931118a1b64c14bf7e3061662a68e804e93a17a956532356e319dcaeb9f1f71d0338a7e980701443dbdb4c3ed044a271e3d1faf3a6bfd942eae3f39498
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
