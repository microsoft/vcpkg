vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO codeplea/genann
    REF v${VERSION}
    SHA512 69c186d10a5bf484cb13c469571a84480a755719ed64050480d3a5906dcacd23b9b30db971ff695e9d85b0958dcd0b10cff347c2c4c0cd5d1dbfc7745f57dd32
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_RELEASE -DINSTALL_HEADERS=ON
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
