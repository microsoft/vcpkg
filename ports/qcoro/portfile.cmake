vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qcoro/qcoro
    REF "v${VERSION}"
    SHA512 BDE5C5CD9F3C038E6B5EC5A6ADAE5AE2218EDD9DF350E75FC5D8DB31D9339484E92CC88FDC37FA0539E0CDF1F53731418EBFA73B94564E993D7B02168988771B
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
