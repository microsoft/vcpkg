vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "SpiriMirror/fTetwild"
    REF "${VERSION}"
    SHA512 856c7284f10d050cf868ab256e491d39531d5716109f1fd96e9883f7b7614ca29c3da3fd78496444bbfd9f34d326a383fbfedd374d9fdca7bc3197e41e3487e5
    HEAD_REF mini20
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.MPL2")
