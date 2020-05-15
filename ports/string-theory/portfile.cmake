vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zrax/string_theory
    REF 3.2
    SHA512 6706d22d7892b76c27f72e583556f88038cf462c309e4a0d9dbb28f7c8128a456eb74cb9181b02ecaed00a076cd4f7d1f5189898756011ab3e4d712c9865013b
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/string_theory)

file(RENAME ${CURRENT_PACKAGES_DIR}/share/string-theory ${CURRENT_PACKAGES_DIR}/share/string_theory)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/string-theory)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/string-theory/LICENSE ${CURRENT_PACKAGES_DIR}/share/string-theory/copyright)
file(COPY ${CURRENT_PACKAGES_DIR}/share/string-theory/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/string_theory/copyright)
