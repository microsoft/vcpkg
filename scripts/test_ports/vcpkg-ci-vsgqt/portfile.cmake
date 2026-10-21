set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vsg-dev/vsgQt
    REF v0.4.0
    SHA512 0c753d573eeec77bdddab0f3499b7fbabc4c0840246501dd83ef1e3a96effacf9cd9a84d5c1c35b49462520a2840ddd02eeefa92c55b23dc44ce9fc285cbee3b
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        vsgxchange  USE_VSGXCHANGE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-DSOURCE_PATH=${SOURCE_PATH}"
        ${options}
)
vcpkg_cmake_build()
