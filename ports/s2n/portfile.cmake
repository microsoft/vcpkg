vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aws/s2n-tls
    REF "v${VERSION}"
    SHA512 cfdfcdaa9d57427211e896845358da85d7498fa0478b6916dd34f36c755100c0421c07ccd624ed2d4baf9fcfe0dde6629159769619ac22e9ef1535ba20bf8979
    PATCHES
        remove-trycompile.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tests   BUILD_TESTING
)

set(EXTRA_ARGS)
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "wasm32")
    set(EXTRA_ARGS "-DS2N_NO_PQ=TRUE")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${EXTRA_ARGS}
        ${FEATURE_OPTIONS}
        -DUNSAFE_TREAT_WARNINGS_AS_ERRORS=OFF
)

vcpkg_cmake_install()

string(REPLACE "dynamic" "shared" subdir "${VCPKG_LIBRARY_LINKAGE}")
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/${PORT}/cmake/${subdir}" DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/${PORT}/cmake")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake" [[/${type}/]] "/")

file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/include"
        "${CURRENT_PACKAGES_DIR}/debug/lib/${PORT}"
        "${CURRENT_PACKAGES_DIR}/debug/share"
        "${CURRENT_PACKAGES_DIR}/lib/${PORT}"
        )

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
