vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ogdf/ogdf
    REF  8a103cf3a7dfff87fe8b7534575604bc53c0870c
    SHA512 264e8586be7a18640f253eb7b289dd99f1f2fc42c4d2304ab12f7c6aa9c5754b710642e7296038aea0cd9368d732d0106501fefed800743b403adafff7e3f0b2
    HEAD_REF master
    PATCHES fix-c4723.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCOIN_INSTALL_LIBRARY_DIR:STRING=lib
        -DCOIN_INSTALL_CMAKE_DIR:STRING=lib/cmake/OGDF
        -DOGDF_INSTALL_LIBRARY_DIR:STRING=lib
        -DOGDF_INSTALL_CMAKE_DIR:STRING=lib/cmake/OGDF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/OGDF)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/minisat/doc ${CURRENT_PACKAGES_DIR}/include/ogdf/lib/minisat/doc)
