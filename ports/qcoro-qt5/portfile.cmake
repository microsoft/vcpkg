vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO danvratil/qcoro
    REF "v0.9.0"
    SHA512 f708e1a82861c39434d6934172246c3280864e933b333b56c0471f1a629f9da65554d1508af4291ac2257ad8df2040655394ae5525d728710de5bd83cef8fbee
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS EXTRA_OPTIONS
    FEATURES
        dbus        QCORO_WITH_QTDBUS
        network     QCORO_WITH_QTNETWORK
        websockets  QCORO_WITH_QTWEBSOCKETS
        quick       QCORO_WITH_QTQUICK
        qml         QCORO_WITH_QML
        test        QCORO_WITH_QTTEST
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUSE_QT_VERSION=5
        -DBUILD_TESTING=OFF
        -DQCORO_BUILD_EXAMPLES=OFF
        ${EXTRA_OPTIONS}
)

vcpkg_cmake_install()

if (QCORO_WITH_QTDBUS)
    vcpkg_cmake_config_fixup(PACKAGE_NAME QCoro5DBus DO_NOT_DELETE_PARENT_CONFIG_PATH CONFIG_PATH lib/cmake/QCoro5DBus)
endif()
if (QCORO_WITH_QTNETWORK)
    vcpkg_cmake_config_fixup(PACKAGE_NAME QCoro5Network DO_NOT_DELETE_PARENT_CONFIG_PATH CONFIG_PATH lib/cmake/QCoro5Network)
endif()
if (QCORO_WITH_QTWEBSOCKETS)
    vcpkg_cmake_config_fixup(PACKAGE_NAME QCoro5WebSockets DO_NOT_DELETE_PARENT_CONFIG_PATH CONFIG_PATH lib/cmake/QCoro5WebSockets)
endif()
if (QCORO_WITH_QTQUICK)
    vcpkg_cmake_config_fixup(PACKAGE_NAME QCoro5Quick DO_NOT_DELETE_PARENT_CONFIG_PATH CONFIG_PATH lib/cmake/QCoro5Quick)
endif()
if (QCORO_WITH_QML)
    vcpkg_cmake_config_fixup(PACKAGE_NAME QCoro5Qml DO_NOT_DELETE_PARENT_CONFIG_PATH CONFIG_PATH lib/cmake/QCoro5Qml)
endif()
if (QCORO_WITH_QTTEST)
    vcpkg_cmake_config_fixup(PACKAGE_NAME QCoro5Test DO_NOT_DELETE_PARENT_CONFIG_PATH CONFIG_PATH lib/cmake/QCoro5Test)
endif()
vcpkg_cmake_config_fixup(PACKAGE_NAME QCoro5 DO_NOT_DELETE_PARENT_CONFIG_PATH CONFIG_PATH lib/cmake/QCoro5)
vcpkg_cmake_config_fixup(PACKAGE_NAME QCoro5Core CONFIG_PATH lib/cmake/QCoro5Core)

# Remove debug includes
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
# Remove mkspec files (not needed here and they would conflict with QCoro6 mkspecs)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/mkspecs")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/mkspecs")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
