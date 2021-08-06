vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO catchorg/Catch2
    REF c4e3767e265808590986d5db6ca1b5532a7f3d13 # v2.13.7
    SHA512 38ee9580acdc9cf24d3d64d9195347b90fa2e8a4c4d2214cc0b0ca41ddde435df1dfd663d202e294b0f6d0ab6b65084e53c529d6807d4d5e64926504d13d1140
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC) 

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCATCH_BUILD_EXAMPLES=OFF
        -DCATCH_BUILD_STATIC_LIBRARY=${BUILD_STATIC}
)

vcpkg_cmake_install()

file(RENAME "${CURRENT_PACKAGES_DIR}/share/Catch2" "${CURRENT_PACKAGES_DIR}/share/catch2_")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/catch2_" "${CURRENT_PACKAGES_DIR}/share/catch2")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/Catch2" "${CURRENT_PACKAGES_DIR}/debug/share/catch2_")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/catch2_" "${CURRENT_PACKAGES_DIR}/debug/share/catch2")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Catch2)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
else()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/include/catch2/catch.hpp")
    message(FATAL_ERROR "Main includes have moved. Please update the forwarder.")
endif()

file(WRITE "${CURRENT_PACKAGES_DIR}/include/catch.hpp" "#include <catch2/catch.hpp>")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
