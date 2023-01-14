vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rdiankov/collada-dom
    REF d37ae7532e350b87c88712e9f6ab4b1f440d20cd
    SHA512 cb923d296219765096f5246cc7a2b69712931f58171ae885dbdbd215fca86d911c34d12748d3304d6a5a350dc737ff0caead2495acac488af5431b437cbacc7d
    HEAD_REF v2.5.0
    PATCHES
        vs-version-detection.patch
        use-uriparser.patch
        use-vcpkg-minizip.patch
        fix-shared-keyword.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/collada_dom-2.5)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/licenses/license_e.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_fixup_pkgconfig()
