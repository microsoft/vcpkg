include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO septag/sx
    REF 161d7d77a3bdcc8a55846e2dd1791773888fce24
    SHA512 198476793c921d8859f5f5b9ffe8915a7bc4b1d9d518e6772b3d90ccd03a7f5debe5bde32d7d5164f64a0beda53c5dcd06849814e7df447bccb93aa13bbca8b0
    HEAD_REF master
    PATCHES
        win32-sharedlib.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SX_SHARED_LIB)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DSX_BUILD_TESTS=OFF
        -DSX_SHARED_LIB=${SX_SHARED_LIB}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/sx/config.h
        "define SX_CONFIG_SHARED_LIB 0"
        "define SX_CONFIG_SHARED_LIB 1"
    )
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
