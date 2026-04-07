
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "ViliOrg/Vili"
    REF "6e97dde7ef7cfe95ef715640524210b6477ecfa1"
    SHA512 "a3c198df442a870f4075136d7eeb4f5241728cdd737ee002f7040e8f3c74e7216a0ebe0aab95ce4dc6e56ba84d3f43f4af2b9ec1116efb13d2b6f3977fcb1f33"
    HEAD_REF "master"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTS=OFF"
)

vcpkg_cmake_install()

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
