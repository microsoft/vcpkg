vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mborgerding/kissfft
    REF 3f3fc6ab55da8610aba7fe89dcda09cf3a31f4e6
    SHA512 5d3781a82d067cebd0a20c6b35a2d806598ba66f3bbf282c49a2ac9a6d09e1307dca1f8bc5fcc4c5955dc2f66aa94ca4dcfe00e6b31ea4694aa9d507f194554e
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/exports.def DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DKF_INSTALL_HEADERS=OFF
    OPTIONS_RELEASE
        -DKF_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(
    CONFIG_PATH lib/cmake/unofficial-${PORT}
    TARGET_PATH share/unofficial-${PORT}
)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
