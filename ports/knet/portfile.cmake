vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kibaamor/knet
    REF efca99a03d3dc13d2e70fb81f497b55f467dce09
    SHA512 75ccbcf0305311cc448a292b2be3dc83be984a18eba827012f094e88d8aa7d0d1978cf5fa1e23b17199b3786582c65be0d5e5478629666d1b445514963a5946c
    HEAD_REF dev
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DKNET_BUILD_EXAMPLE:BOOL=OFF
        -DKNET_BUILD_TEST:BOOL=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/knet TARGET_PATH share/knet)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
