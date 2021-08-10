vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO catchorg/Catch2
    REF 5c88067bd339465513af4aec606bd2292f1b594a # v2.13.6
    SHA512 62ab120ef9cbbcf7320a96654bda60c766dbbcc0d9cbb2b0b36dd04e828315b627caf51e390dcea915efa266655fe0f28058b972c0d6e0e3e457c565d26e1fd3
    HEAD_REF master
    PATCHES fix-install-path.patch
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

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/include/catch2/catch.hpp")
    message(FATAL_ERROR "Main includes have moved. Please update the forwarder.")
endif()

file(WRITE "${CURRENT_PACKAGES_DIR}/include/catch.hpp" "#include <catch2/catch.hpp>")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
