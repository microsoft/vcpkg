
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "bkaradzic/bx"
    REF af9ccfdf566b2c30589fe00a7bd0f265ef1dbb61
    SHA512 275031d337db03d2509ec55ce9b776db8caa02ca7039cda50aa3625e007ce8f791efe6aee7b46e5ff27c71451acdff932603f31ca03f209ade0578a78d0e37b2
    HEAD_REF master
    PATCHES
        10-alloc.h-include.patch
)
file(COPY "${CURRENT_PORT_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_RELEASE -DBX_INSTALL_TOOLING=1
    OPTIONS_DEBUG -DBX_CONFIG_DEBUG=1 -DBX_DISABLE_HEADER_INSTALL=ON
)

vcpkg_install_cmake()
# Moves tools into the appropriate folder
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")

vcpkg_fixup_cmake_targets()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
