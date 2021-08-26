vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mobius3/tweeny
    REF v3.2.0
    SHA512 809b8250f7df6c3e9d27e9967c586d1ca4be29e3b551b57285da1060a6928c91e0afa6b3ef6b546cae48035383939f19d67889b632dd60a2fbb0a22aafaabe89
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "/lib/cmake/Tweeny/")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake/Tweeny)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
