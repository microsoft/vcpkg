vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kio
    REF "v${VERSION}"
    SHA512 085eaf467cb70630b1a2fe5024bd45aebe47f15c397388ebd562d0c0fbfd6700c8cc50d2ec136988d9575173aa01a5a73a1550c1b7cbb93d6909941909a31db7
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        designer-plugin     BUILD_DESIGNERPLUGIN
        kf5notifications    VCPKG_LOCK_FIND_PACKAGE_KF5Notifications
        kf5wallet           VCPKG_LOCK_FIND_PACKAGE_KF5Wallet
        qml                 VCPKG_LOCK_FIND_PACKAGE_Qt5Qml
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_FIND_PACKAGE_TARGETS_GLOBAL=ON
        -DCMAKE_JOB_POOL_LINK=console # Serialize linking to avoid OOM
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_ACL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_GSSAPI=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_KDED=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_KF5DocTools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_SwitcherooControl=ON
        -DKF6_COMPAT_BUILD=ON
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        VCPKG_LOCK_FIND_PACKAGE_KF5Notifications
        VCPKG_LOCK_FIND_PACKAGE_KF5Wallet

)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5KIO)
vcpkg_copy_pdbs()

vcpkg_copy_tools(
    TOOL_NAMES kcookiejar5 ktelnetservice5 ktrash5 protocoltojson kio_http_cache_cleaner kiod5 kioexec kioslave5
    AUTO_CLEAN
)
if(NOT VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_ANDROID)
    vcpkg_copy_tools(TOOL_NAMES kpac_dhcp_helper AUTO_CLEAN)
endif()

file(APPEND "${CURRENT_PACKAGES_DIR}/tools/${PORT}/qt.conf" "Data = ../../share")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
