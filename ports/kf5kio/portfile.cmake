include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kio
    REF v5.51.0
    SHA512 a88bcc2d86cbc05b5249d66408771a4988138dd3e9d364c138e76563e56a5240695290b127736b3bdc1eaf2319909da4bb80cf5aff3783fa213addcbcad0e0eb
    HEAD_REF master
)

vcpkg_acquire_msys(MSYS_ROOT PACKAGES mingw-w64-i686-gettext)
set(GETTEXT_PATH ${MSYS_ROOT}/mingw32/bin)
vcpkg_add_to_path(${GETTEXT_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_HTML_DOCS=OFF
            -DBUILD_MAN_DOCS=OFF
            -DBUILD_QTHELP_DOCS=OFF
            -DBUILD_TESTING=OFF
            -DKDE_INSTALL_PLUGINDIR=plugins
            -DKDE_INSTALL_DATAROOTDIR=data
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5KIO)
vcpkg_copy_pdbs()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/kf5kio)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/protocoltojson.exe ${CURRENT_PACKAGES_DIR}/tools/kf5kio/protocoltojson.exe)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/kf5kio)
file(APPEND ${CURRENT_PACKAGES_DIR}/tools/kf5kio/qt.conf "Data = ${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/data")

file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/kcookiejar5.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/ktelnetservice5.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/ktrash5.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/kio_http_cache_cleaner.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/kioslave.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/kioexec.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/kiod5.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/kcookiejar5.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/ktelnetservice5.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/ktrash5.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/protocoltojson.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/kio_http_cache_cleaner.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/kioslave.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/kioexec.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/kiod5.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/kf5kio RENAME copyright)
