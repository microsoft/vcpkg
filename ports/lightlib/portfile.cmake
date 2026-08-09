vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lev2p1/lightlib
    REF v0.1.4
    SHA512 f1ef42b92909e90622cce50a1c311909fb84485a2492e1358b8f2a3c818726d6ce15082c316765355bdbefcf575ba0254a060ffa00f87c96be0ed99711c7cf6e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/Light"
    OPTIONS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE 
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endif()

set(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")