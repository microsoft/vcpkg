#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO USCiLab/cereal
    REF v1.3.2
    SHA512 98d306d6292789129675f1c5c5aedcb90cfcc1029c4482893a8f9b23f3c9755e5ed4762d7a528f215345cae6392e87cd8d89467115b6f031b41c8673d6b4b109
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DJUST_INSTALL_CEREAL=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/cereal)

# Clean
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
file(COPY "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
