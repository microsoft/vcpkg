vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pantor/inja
    REF b2276440be8334aeba9cd5d628c2731d0f6a5809 # v3.4.0
    SHA512 80f760668f72b9e0a54e1c74d169f98a99fdfffe6bacc56043681e48a4af21a2331a94ab5cb27b6e5a838d7d7fe5d8a806597bfb913f0f3aecb30755a23a4cf8
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DINJA_USE_EMBEDDED_JSON=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_BENCHMARK=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/inja")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Don't need built-in nlohmann-json as this package depends on nlohmann-json
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/inja/json")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
