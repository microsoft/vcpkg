# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SergiusTheBest/plog
    REF 1.1.9
    SHA512 d979fdf0011ef9bb94a2271da5d17058dbab5bc47438a13769d084fdebe5e169e7c05a043d69acceb752896df7cdae4433f32bfbcc81e055dffd9c701be88003
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH} OPTIONS -DPLOG_BUILD_SAMPLES=OFF)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Copy usage file
file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Put the licence file where vcpkg expects it
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
