vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dbus/dbus
    REF ed866a94889e13c83dc873d8b5f86a907f908456 #1.15.2
    SHA512  eca9bfabfa6e8a3bf82ecc3c36dbd038c2450aded539a6d405a2709e876ccbf5002391802f6d538a5bbc16723f0d51f059f03cb6d226b400bc032b3bbe59cf10
    HEAD_REF master
    PATCHES 
        cmake.dep.patch
        pkgconfig.patch
        getpeereid.patch # missing check from configure.ac
) 

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        x11     DBUS_BUILD_X11
        x11     CMAKE_REQUIRE_FIND_PACKAGE_X11
)

unset(ENV{DBUSDIR})

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDBUS_BUILD_TESTS=OFF
        -DDBUS_ENABLE_DOXYGEN_DOCS=OFF
        -DDBUS_ENABLE_XML_DOCS=OFF
        -DDBUS_INSTALL_SYSTEM_LIBS=OFF
        #-DDBUS_SERVICE=ON
        -DDBUS_WITH_GLIB=OFF
        -DENABLE_SYSTEMD=ON
        -DTHREADS_PREFER_PTHREAD_FLAG=ON
        -DXSLTPROC_EXECUTABLE=FALSE
        "-DCMAKE_INSTALL_SYSCONFDIR=${CURRENT_PACKAGES_DIR}/etc/${PORT}"
        "-DWITH_SYSTEMD_SYSTEMUNITDIR=lib/systemd/system"
        "-DWITH_SYSTEMD_USERUNITDIR=lib/systemd/user"
    OPTIONS_RELEASE
        -DDBUS_DISABLE_ASSERT=OFF
        -DDBUS_ENABLE_STATS=OFF
        -DDBUS_ENABLE_VERBOSE_MODE=OFF
    MAYBE_UNUSED_VARIABLES
        DBUS_BUILD_X11
        DBUS_WITH_GLIB
        ENABLE_SYSTEMD
        THREADS_PREFER_PTHREAD_FLAG
        WITH_SYSTEMD_SYSTEMUNITDIR
        WITH_SYSTEMD_USERUNITDIR
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME "DBus1" CONFIG_PATH "lib/cmake/DBus1")
vcpkg_fixup_pkgconfig() 

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/var/"
    "${CURRENT_PACKAGES_DIR}/etc"
    "${CURRENT_PACKAGES_DIR}/share/dbus-1/services"
    "${CURRENT_PACKAGES_DIR}/share/dbus-1/session.d"
    "${CURRENT_PACKAGES_DIR}/share/dbus-1/system-services"
    "${CURRENT_PACKAGES_DIR}/share/dbus-1/system.d"
    "${CURRENT_PACKAGES_DIR}/share/dbus-1/system.conf"
    "${CURRENT_PACKAGES_DIR}/share/dbus-1/system.conf"
    "${CURRENT_PACKAGES_DIR}/share/doc"
    "${CURRENT_PACKAGES_DIR}/var"
)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/dbus-1/session.conf" "<include ignore_missing=\"yes\">${CURRENT_PACKAGES_DIR}/etc/dbus/dbus-1/session.conf</include>" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/dbus-1/session.conf" "<includedir>${CURRENT_PACKAGES_DIR}/etc/dbus/dbus-1/session.d</includedir>" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/dbus-1/session.conf" "<include ignore_missing=\"yes\">${CURRENT_PACKAGES_DIR}/etc/dbus/dbus-1/session-local.conf</include>" "")

set(TOOLS daemon launch monitor run-session send test-tool update-activation-environment)
if(VCPKG_TARGET_IS_WINDOWS)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/dbus-env.bat" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/dbus-env.bat")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/dbus-env.bat" "${CURRENT_PACKAGES_DIR}" "%~dp0/../..")
else()
    list(APPEND TOOLS cleanup-sockets uuidgen)
endif()
list(TRANSFORM TOOLS PREPEND "dbus-" )
vcpkg_copy_tools(TOOL_NAMES ${TOOLS} AUTO_CLEAN)

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
