vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simbody/simbody
    REF a8f49c84e98ccf3b7e6f05db55a29520e5f9c176
    SHA512 85493e00286163ed8ac6aa71edf8d34701d62ac5e5f472f654faa8852eb7fd569ffc0d76fd2e88bebcd3f79df9e35fc702a029890defb8b0d84d0d0512268960
    HEAD_REF master
    PATCHES
        "0001-Use-vcpkg-deps.patch"
        "0002-Use-same-install-dir.patch"
        "0003-Fix-static.patch"
)
file(REMOVE_RECURSE "${SOURCE_PATH}/Platform/Windows")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBRARIES)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_DYNAMIC_LIBRARIES)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_MD)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_DYNAMIC_LIBRARIES=${BUILD_DYNAMIC_LIBRARIES}
        -DBUILD_STATIC_LIBRARIES=${BUILD_STATIC_LIBRARIES}
        -DBUILD_MD=${BUILD_MD}
        -DINSTALL_DOCS=OFF
        -DBUILD_VISUALIZER=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
