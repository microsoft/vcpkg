vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libuvc/libuvc
    REF c612d4509eb0ff19ce414abc3dca18d0f6263a84
    SHA512 df3f23463728e8ffd69dc52e251ea2610ea8df32b02f6d26dd2a6910cf217650245bb1a11e67be61df875c6992d592c9cb17675d914997bd72c9fe7eb5b65c32
    HEAD_REF master
    PATCHES build_fix.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(BUILD_TARGET "Shared")
else()
    set(BUILD_TARGET "Static")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DCMAKE_BUILD_TARGET=${BUILD_TARGET}
        -DBUILD_EXAMPLE=OFF
)
vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME libuvc CONFIG_PATH lib/cmake/libuvc)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
