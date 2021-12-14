vcpkg_fail_port_install(ON_TARGET "Windows")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/s2geometry
    REF v0.9.0
    SHA512 854ec84a54aff036b3092a6233be0f5fc0e4846ac5f882326bbb3f2b9ce88bd5c866a80ae352d8e7d5ae00b9c9a8ab1cff6a95412f990b7bc1fdc5ca3d632b9c

    HEAD_REF main
      PATCHES
       config.patch
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
    MAYBE_UNUSED_VARIABLES BUILD_TESTING
)

vcpkg_install_cmake()
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")


file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

