vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ned14/status-code
    REF 0cca391ad9168581641b569e031f25c7ee1673b3
    SHA512 5fdf3e268d0a4a388202547ceac271832642648fdc50824a8f26d86bad1d45c93394ff6651e50232dde534e057dfadaf7a7436b893dd7b182a75bcd57e24fc9d
    HEAD_REF master
)

# Because status-code's deployed files are header-only, the debug build is not necessary
set(VCPKG_BUILD_TYPE release)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DPROJECT_IS_DEPENDENCY=On
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/status-code)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(RENAME "${CURRENT_PACKAGES_DIR}/include" "${CURRENT_PACKAGES_DIR}/include2")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/include2" "${CURRENT_PACKAGES_DIR}/include/status-code")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/Licence.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
