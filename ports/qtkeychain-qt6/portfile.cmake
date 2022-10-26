message(WARNING "qtkeychain is a third-party extension to Qt and is not affiliated with The Qt Company")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO frankosterfeld/qtkeychain
    # 0.13.2 plus some commits, for a CMake export target fix and Android support
    REF 8506d57e5df5ae2419a711f93bf93793776e5a11
    SHA512 22e8efe326613eaa8d7cb80aaa92739416f64d6559a48240ad5eb7dea42078d4bfef5ff64c99b294b339e5f36571b15ce8f456e4f6cf20e9ce213abdfa463d77
    HEAD_REF master
)

if(VCPKG_CROSSCOMPILING)
   list(APPEND QTKEYCHAIN_OPTIONS -DQT_HOST_PATH=${CURRENT_HOST_INSTALLED_DIR})
   list(APPEND QTKEYCHAIN_OPTIONS -DQT_HOST_PATH_CMAKE_DIR:PATH=${CURRENT_HOST_INSTALLED_DIR}/share)
   # remove when https://github.com/microsoft/vcpkg/pull/16111 is merged
   if(VCPKG_TARGET_ARCHITECTURE STREQUAL arm64 AND VCPKG_TARGET_IS_WINDOWS)
       list(APPEND QTKEYCHAIN_OPTIONS -DCMAKE_CROSSCOMPILING=ON -DCMAKE_SYSTEM_PROCESSOR:STRING=ARM64 -DCMAKE_SYSTEM_NAME:STRING=Windows)
   endif()
endif()

list(APPEND QTKEYCHAIN_OPTIONS -DBUILD_TEST_APPLICATION:BOOL=OFF)

vcpkg_cmake_configure(
    DISABLE_PARALLEL_CONFIGURE
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_WITH_QT6=ON
         ${QTKEYCHAIN_OPTIONS}
)
vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Qt6Keychain PACKAGE_NAME Qt6Keychain)

# Remove unneeded dirs
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
