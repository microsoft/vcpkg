include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/breakpad
    REF 6bb6c9b26afd9844b9e35fcaa39fb24893e7abb5
    SHA512 a6a786c2cabb1fd2749d79215c7a3024ae6d1a894166060b22869cd3ee3010edb3e0613c0aeea254580554f402d919ed630ee088c53a1f218e01a7280ad29fec
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-breakpad TARGET_PATH share/unofficial-breakpad)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/breakpad RENAME copyright)
