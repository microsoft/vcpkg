vcpkg_fail_port_install(ON_ARCH "arm" "arm64")
vcpkg_fail_port_install(ON_TARGET "linux" "uwp" "osx")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux
    REF 4636183159f74f350238e6ee59583b34f7e7aca9 # v1.4.1
    SHA512 319cd15c73ca469849cbc364635d7147cfa3fed57d6043b0cb2b52d504a253645518ec6254ddba51fc8cc32cc89e345458530628b331629cabce5b64d8723a6a
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
