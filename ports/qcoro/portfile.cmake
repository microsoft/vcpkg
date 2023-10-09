vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO danvratil/qcoro
    REF "v${VERSION}"
    SHA512 f708e1a82861c39434d6934172246c3280864e933b333b56c0471f1a629f9da65554d1508af4291ac2257ad8df2040655394ae5525d728710de5bd83cef8fbee
    HEAD_REF main
    PATCHES 0001-qt6-deprecated-qwebsocket-error.patch
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
        -DUSE_QT_VERSION=6
        -DBUILD_TESTING=OFF
        -DQCORO_BUILD_EXAMPLES=OFF
        ${EXTRA_OPTIONS}
)

vcpkg_cmake_install()

if (QCORO_WITH_QTDBUS)
    vcpkg_cmake_config_fixup(PACKAGE_NAME QCoro6DBus DO_NOT_DELETE_PARENT_CONFIG_PATH CONFIG_PATH lib/cmake/QCoro6DBus)
endif()
if (QCORO_WITH_QTNETWORK)
    vcpkg_cmake_config_fixup(PACKAGE_NAME QCoro6Network DO_NOT_DELETE_PARENT_CONFIG_PATH CONFIG_PATH lib/cmake/QCoro6Network)
endif()
if (QCORO_WITH_QTWEBSOCKETS)
    vcpkg_cmake_config_fixup(PACKAGE_NAME QCoro6WebSockets DO_NOT_DELETE_PARENT_CONFIG_PATH CONFIG_PATH lib/cmake/QCoro6WebSockets)
endif()
if (QCORO_WITH_QTQUICK)
    vcpkg_cmake_config_fixup(PACKAGE_NAME QCoro6Quick DO_NOT_DELETE_PARENT_CONFIG_PATH CONFIG_PATH lib/cmake/QCoro6Quick)
endif()
if (QCORO_WITH_QML)
    vcpkg_cmake_config_fixup(PACKAGE_NAME QCoro6Qml DO_NOT_DELETE_PARENT_CONFIG_PATH CONFIG_PATH lib/cmake/QCoro6Qml)
endif()
if (QCORO_WITH_QTTEST)
    vcpkg_cmake_config_fixup(PACKAGE_NAME QCoro6Test DO_NOT_DELETE_PARENT_CONFIG_PATH CONFIG_PATH lib/cmake/QCoro6Test)
endif()
vcpkg_cmake_config_fixup(PACKAGE_NAME QCoro6Coro DO_NOT_DELETE_PARENT_CONFIG_PATH CONFIG_PATH lib/cmake/QCoro6Coro)
vcpkg_cmake_config_fixup(PACKAGE_NAME QCoro6 DO_NOT_DELETE_PARENT_CONFIG_PATH CONFIG_PATH lib/cmake/QCoro6)
vcpkg_cmake_config_fixup(PACKAGE_NAME QCoro6Core CONFIG_PATH lib/cmake/QCoro6Core)

# Remove debug includes and CMake macros
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
