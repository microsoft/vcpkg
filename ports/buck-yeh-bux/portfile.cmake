vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "linux" "uwp" "osx")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux
    REF 4e64bc28c482df45a2e15afd8fea928d82897783 # v1.6.2
    SHA512 b409cddc15116e4c1f6142f5d07449bfc44e4c7386bde6884ca232e30a7057a04144cd5564c4c9fb86e74160b9c52d097185f63ebbd751cfe8e7520e8181f404
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
