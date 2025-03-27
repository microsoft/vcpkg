if(VCPKG_TARGET_IS_LINUX)
    MESSAGE(WARNING "${PORT} requires libbluetooth-dev from the system package manager.\nTry: 'sudo yum install libbluetooth-dev ' (or sudo apt-get install libbluetooth-dev)")
endif()

vcpkg_download_distfile(REMOVE_OPENSSL_DEPENDENCIES_PATCH
    URLS https://github.com/robotraconteur/robotraconteur/commit/0fe6efd8c448f68ae6c33c261b9df734b372ee47.patch?full_index=1
    FILENAME robotraconteur-openssl-dependencies-0fe6efd8c448f68ae6c33c261b9df734b372ee47.patch
    SHA512 38769c15dfe98ee71f6cefd643f104d653cd38e1a590202d942e6a781bc5080f063b3e50e927089fa0aed85fe8345541fd7424ccf2f353e245a27f200b8cf024
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO robotraconteur/robotraconteur
    REF "v${VERSION}"
    SHA512 d73621ff888ae8cfc9d6ac5a71b75920552948fb15ffe2fa13fb31a238fc92f6a271ea1653eed855ba04f371686dff6fdf46285f24a471a3147d7744563b4d0b
    HEAD_REF master
    PATCHES
        rr_boost_1_87_patch.diff
        "${REMOVE_OPENSSL_DEPENDENCIES_PATCH}"
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_GEN=ON
        -DBUILD_TESTING=OFF
        -DCMAKE_CXX_STANDARD=11
)

vcpkg_cmake_install()

vcpkg_copy_tools(TOOL_NAMES RobotRaconteurGen AUTO_CLEAN)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/robotraconteur)

vcpkg_cmake_config_fixup(
    PACKAGE_NAME RobotRaconteur
    CONFIG_PATH "lib/cmake/RobotRaconteur"
)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

