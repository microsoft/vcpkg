set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO dtschump/CImg
    REF "v.${VERSION}"
    SHA512 7b5c31a5a88c06fb2ec16332851e9a828ff1dcec6e1d3a34f1bfe0424c2df47079328c8f06b84a363a5eaf7affb3edc40a4bad0ab93d378598851e91e8160f1d
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/Licence_CeCILL-C_V1-en.txt"
        "${SOURCE_PATH}/Licence_CeCILL_V2-en.txt"
)
