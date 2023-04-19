vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO projectchrono/chrono
    REF ${VERSION}
    SHA512 379609b5a968b56faf48d2e848b0bb85d95f266a4fea48d457f2242fad580fee88ae5974e1021e31e56ebdb7a49fcddba681eff4d56605c94fbe30032dc5906c
    PATCHES
        fix_dependencies.patch
        find_package_required.patch
)

file(REMOVE "${SOURCE_PATH}/cmake/FindTBB.cmake")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS
        FEATURE_OPTIONS
    FEATURES
        irrlicht    ENABLE_MODULE_IRRLICHT
        vehicle     ENABLE_MODULE_VEHICLE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_MODULE_POSTPROCESS=ON
        -DBUILD_DEMOS=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_BENCHMARKING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(
        CONFIG_PATH cmake
    )
else()
    vcpkg_cmake_config_fixup(
        CONFIG_PATH lib/cmake/Chrono
    )
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/include/chrono_thirdparty/chpf"
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
