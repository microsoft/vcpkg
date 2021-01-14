include(${CURRENT_PORT_DIR}/dependency_quickcpplib.cmake)
include(${CURRENT_PORT_DIR}/dependency_status_code.cmake)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ned14/outcome
    REF all_tests_passed_ac552d1c69ef556a1327393a0c56092517ff92db
    SHA512 30111a6526297ff21ddaf04910b831aa38161f884a84dab52daf1200d66f3de89dc30aef15a74f5ba0cbba097313e3bd37e9fcc675254d8ca24f98b43cb47025
    HEAD_REF develop
)
# Dependencies
download_quickcpplib("${SOURCE_PATH}/quickcpplib/repo/")
download_status_code("${SOURCE_PATH}/include/outcome/experimental/status-code/")

# Use Outcome's own build process, skipping examples and tests, bundling the embedded quickcpplib
# instead of git cloning from latest quickcpplib.
vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DPROJECT_IS_DEPENDENCY=On
        -DOUTCOME_BUNDLE_EMBEDDED_QUICKCPPLIB=On
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/quickcpplib TARGET_PATH share/quickcpplib DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/outcome)

file(RENAME "${CURRENT_PACKAGES_DIR}/share/cmakelib" "${CURRENT_PACKAGES_DIR}/share/quickcpplib/cmakelib")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/scripts" "${CURRENT_PACKAGES_DIR}/share/quickcpplib/scripts")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Fix find dependency quickcpplib
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/outcome/outcomeConfig.cmake"
    "CONFIG_MODE)\n"
    "CONFIG_MODE)\ninclude(CMakeFindDependencyMacro)\nfind_dependency(quickcpplib CONFIG)\n"
)

file(INSTALL "${SOURCE_PATH}/Licence.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
