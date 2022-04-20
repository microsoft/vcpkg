vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gracicot/kangaru
    REF v4.3.0
    SHA512 7763d25eed203a033e0420abc0194531082223183ed9ec28d98f871e0dc619d28ec9053ff69b5bf54bac07bd99551f2dfaad9f29d51e8ebdd72d4929f9a8fb93
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKANGARU_EXPORT=OFF
        -DKANGARU_TEST=OFF
        -DKANGARU_REVERSE_DESTRUCTION=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/kangaru)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/lib"
    "${CURRENT_PACKAGES_DIR}/debug"
)

# Put the license file where vcpkg expects it
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
