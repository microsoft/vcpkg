vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO likle/cwalk
    REF v1.2.5
    SHA512 904e095e375d0c98dedbb17ddf805397387f8f473a708b310ba3086bbd4445bde7d0a037fbe9caed97c9cc793219a3d976cef010d76a32812c4fe2b3b7cde575
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/cwalk)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
