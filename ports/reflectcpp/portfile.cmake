vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO getml/reflect-cpp
    REF "v${VERSION}"
    SHA512 f3d1d3b8f69fc0f93268586ae2002ef5b2646c1459333ab976bad05cdc02f57395917ff859bd67cc00f71495dd8d705027bea6d1011e5cd48d4bd78f2f164f45
    HEAD_REF main
)

if("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static" OR "${VCPKG_TARGET_IS_WINDOWS}")
    set(REFLECTCPP_BUILD_SHARED OFF)
else()
    set(REFLECTCPP_BUILD_SHARED ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DREFLECTCPP_BUILD_TESTS=OFF
        -DREFLECTCPP_BUILD_SHARED=${REFLECTCPP_BUILD_SHARED}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/${PORT}"
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
