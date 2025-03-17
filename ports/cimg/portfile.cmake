set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO dtschump/CImg
    REF "v.${VERSION}"
    SHA512 dc079933bf68df7b0ae1a9498de952e4a32608e74da0df360b628056bdd82ab66f0428a5c94457fd6e9567772a544e9584f5d8f1f6debda6c146b45ea9b813fd
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
