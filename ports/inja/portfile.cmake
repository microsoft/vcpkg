vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pantor/inja
    REF 02394683b151cdb520c8fb636f3bda77ed4f965d # v3.0.0
    SHA512 52c4fa84ada673f517036ec41b64afbd12a14a6da256d3eeacb26ba3c65c1e3c79217d523a5f628bf1ffdddef7d42de2983c2e00ddbd0af2000d671a2a9d72f0
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DINJA_USE_EMBEDDED_JSON=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_BENCHMARK=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/inja)
vcpkg_copy_pdbs()

# Inja is a header-only library
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
# Don't need built-in nlohmann-json as this package depends on nlohmann-json
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/inja/json")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
