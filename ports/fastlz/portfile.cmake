vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ariya/FastLZ
    REF b1342dabcf5257ab303743c9332fe75e9147a011 #2024-08-02
    SHA512 a9c440c60e0d4fd9535a5438f3227e626c27ccd26cdcc9787c0dda5011b980c12ef46c7ddd2f197f6cc3bcef39755341d34214be9a508871ee3e1a24631a87b5
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.MIT")
