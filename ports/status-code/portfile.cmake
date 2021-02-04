vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ned14/status-code
    REF 46dc13f83a6927d5fcbff4fdc81072d0c85510b5
    SHA512 ea8e5bc0db315428e29b706a8003f333d42cb078c758420766a99a4756cb3c757e5801697b3b3aca6ff93885990db813a1d280e9144f33c0e3c435c4d25e46c5
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
