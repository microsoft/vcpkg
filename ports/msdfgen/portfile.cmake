vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Chlumsky/msdfgen
    REF 9af250c7d6780a41dcaf536c05e3e1987a1bdcd7
    SHA512 6b1dadd386aedf1e2de927dc83fe1f7fd7e053b0e9829ea0609a193ab8d9f92ecf08d2a6225b76a4f7bf9344b2935f38bbd00c4cc0c6627c1d95f67d2db728fe
    HEAD_REF master
    PATCHES
        remove_pragma.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/msdfgen)

# move exe to tools
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(INSTALL "${CURRENT_PACKAGES_DIR}/bin" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/" RENAME msdfgen)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# cleanup
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# license
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
