vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emoon/minifb
    REF 1e087f1e9fe5bd33cdb2210b8e92d513ff7dc339 # 2023-02-03
    SHA512 482bdcdb81d9f163ac7ff1224297331bfee68e53778a9170bfec52c8150c840445cb1338250bfc3e780aef011e3e95e7df3d7134183e59df947f69109a27108a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMINIFB_BUILD_EXAMPLES=FALSE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
