vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cliquot22/TheiaMCR_C
    REF "v${VERSION}"
    SHA512 <your-current-hash>
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        python ENABLE_PYTHON_BINDINGS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/TheiaMCR_C)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin"
                        "${CURRENT_PACKAGES_DIR}/bin")
endif()

file(INSTALL "${SOURCE_PATH}/license"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_copy_pdbs()