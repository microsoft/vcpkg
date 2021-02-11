vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pantor/inja
    REF 15b0b7f5e33e9fb1471d35218d2f66511f1ec4b7 # v3.2.0
    SHA512 3eb6c0583b8fe84269649dadc5f3651b571af773a30e4292e56f36e979a70eea2391eb226a48c5eeae70a6e3933a663c74e94128c80e5e14c153dd6fc37c45b8
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
