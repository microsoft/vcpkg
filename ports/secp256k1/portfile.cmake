vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "bitcoin-core/secp256k1"
    REF "0b7024185045a49a1a6a4c5615bf31c94f63d9c4"
    SHA512 54e0c446ae63105800dfaf23dc934734f196c91f275db0455e58a36926c29ecc51a13d9b1eb2e45bc86199120c3c472ec7b39086787a49ce388a4df462a870bc
)

file(COPY ${CURRENT_PORT_DIR}/libsecp256k1-config.h DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-${PORT} TARGET_PATH share/unofficial-${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
configure_file(${CMAKE_CURRENT_LIST_DIR}/secp256k1-config.cmake ${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-secp256k1-config.cmake @ONLY)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
