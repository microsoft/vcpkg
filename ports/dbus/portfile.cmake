vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dbus/dbus
    REF c91ca6edad658274607323a438eea7c7c6c5e392 #1.13.18
    SHA512  4dd4d369152591040ebe9f474a0ba8911d8a91546d64b1d6f7335b7fd8026bd99a8a4fe1c78b80eb2e31e9e58324d432857e2a7af1d1cb950d22b4430cc0f7ac
    HEAD_REF master # branch name
    PATCHES 
        cmake.dep.patch #patch name
        rt_pc_link.patch
) 

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DDBUS_BUILD_TESTS=OFF
        -DDBUS_ENABLE_XML_DOCS=OFF
        -DDBUS_INSTALL_SYSTEM_LIBS=OFF
        #-DDBUS_SERVICE=ON
        -DDBUS_WITH_GLIB=ON
        -DXSLTPROC_EXECUTABLE=FALSE
        -DENABLE_SYSTEMD=ON
        "-DCMAKE_INSTALL_SYSCONFDIR=${CURRENT_PACKAGES_DIR}/etc/${PORT}"
        "-DWITH_SYSTEMD_SYSTEMUNITDIR=lib/systemd/system"
        "-DWITH_SYSTEMD_USERUNITDIR=lib/systemd/user"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/DBus1")
vcpkg_fixup_pkgconfig() 

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE     "${CURRENT_PACKAGES_DIR}/debug/var/"
                        "${CURRENT_PACKAGES_DIR}/var"
                        "${CURRENT_PACKAGES_DIR}/share/dbus-1/services"
                        "${CURRENT_PACKAGES_DIR}/share/dbus-1/session.d"
                        "${CURRENT_PACKAGES_DIR}/share/dbus-1/system-services"
                        "${CURRENT_PACKAGES_DIR}/share/dbus-1/system.d")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
set(TOOLS daemon launch monitor run-session send test-tool update-activation-environment)
if(NOT VCPKG_TARGET_IS_WINDOWS)
    list(APPEND TOOLS cleanup-sockets uuidgen)
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/bin/dbus-env.bat" "${CURRENT_PACKAGES_DIR}" "%~dp0/..")
endif()
list(TRANSFORM TOOLS PREPEND "dbus-" )
vcpkg_copy_tools(TOOL_NAMES ${TOOLS} AUTO_CLEAN)


if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
