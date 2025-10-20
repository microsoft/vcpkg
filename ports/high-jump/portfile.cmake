include(vcpkg_common_functions)

vcpkg_from_hasharchive(
    NAME high-jump
    FILENAME high-jump-source-v${CURRENT_PACKAGES_VERSION}.tar.gz
    URL https://github.com/hanjingo/high-jump/releases/download/v${CURRENT_PACKAGES_VERSION}/high-jump-source-v${CURRENT_PACKAGES_VERSION}.tar.gz
    SHA512 584886e5d8e574f6eaaed00bf9d8a3d4fef9fb6c55b8e94d7d04b8418da66156756471dbe64eeadde5e856964b91f53d78418fce3c6852d9799a7acca1745519
)

set(VCPKG_CMAKE_SYSTEM_NAME "")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
      -DBUILD_LIB=ON
      -DBUILD_EXAMPLE=OFF
      -DBUILD_TEST=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
