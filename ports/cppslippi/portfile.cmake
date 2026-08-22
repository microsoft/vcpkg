vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            cppslippi
    FILENAME        "CppSlippi-${VERSION}.zip"
    SHA512          8bd20b485ce15fbd184d48dd8f58d20d448ea081efd97ae613cbb78a8c9fa0b8f9b643b16a6e25317e9582b86a968eac2ec1ee6b6b6749b8cc79a8b9a9f6de9b
    NO_REMOVE_ONE_LEVEL
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTING=False
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/CppSlippi)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
