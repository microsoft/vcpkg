include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO civetweb/civetweb
    REF 2c1caa6e690bfe3b435a10c372ab2dcd14b872e8
    SHA512 bfd37906f85c10649108f83e755f28f058c0c27b0d597e6eb82f097db7fa043f6014984f1735c904d0e01c8a5e0dc45f1c57c1fb45b08bce78f42539e19160d6
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    ssl CIVETWEB_ENABLE_SSL
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCIVETWEB_BUILD_TESTING=OFF
        -DCIVETWEB_ENABLE_ASAN=OFF
        -DCIVETWEB_ENABLE_CXX=ON
        -DCIVETWEB_ENABLE_IPV6=ON
        -DCIVETWEB_ENABLE_SERVER_EXECUTABLE=OFF
        -DCIVETWEB_ENABLE_SSL_DYNAMIC_LOADING=OFF
        -DCIVETWEB_ENABLE_WEBSOCKETS=ON
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/civetweb)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/civetweb/copyright COPYONLY)

vcpkg_copy_pdbs()
