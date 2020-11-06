vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kplotting
    REF v5.75.0
    SHA512 1eb2320006a21b0d8a3b4fb557458954a1d82427f8b91339d606e5405ef2820f408f257d833fb4af0c5f737eacff0f0371db54b5e6f63b68093e30a8249f17bf
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_HTML_DOCS=OFF
            -DBUILD_MAN_DOCS=OFF
            -DBUILD_QTHELP_DOCS=OFF
            -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5Plotting)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/plugins ${CURRENT_PACKAGES_DIR}/debug/plugins)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/plugins ${CURRENT_PACKAGES_DIR}/plugins)

file(INSTALL ${SOURCE_PATH}/LICENSES/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
