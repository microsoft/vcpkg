vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lev2p1/lightlib
    REF v0.1.4
    SHA512 f707dddc26321c2aedf38acf17d2609c84d9c6151b690eefcee7d7dd94318fb781f4dc2a7f27743764fb5343fd060f11b1c8619cb1cc2e1e968367f60cb7771e
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