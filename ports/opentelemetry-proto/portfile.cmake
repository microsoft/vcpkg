vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-telemetry/opentelemetry-PROTO
    REF "v${VERSION}"
    SHA512 0ea22ccc4f13530754e722bc56f1a7f2bcba176da8c414bedbdc0ac281b18c1fb0ed2c74473bd7d1d6c7f59017fc64435c1c23a2428b6fdab6a44d98a157fff4
    HEAD_REF main
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/tools.cmake" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        otlp-grpc WITH_OTLP_GRPC
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWITH_ABSEIL=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

# Remove the duplicated header files in the debug directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
