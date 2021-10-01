vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mobius3/font-chef
    REF v1.0.1
    SHA512 0d73d095a2f6346cde5fc58a07be7cbe2c180ab5c83a4af21f765a6be1e9dcc5a403fa1d4c64f71dad5609eb72c8b05df8606b4035fceadca74fe6a87bb8efef 
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
