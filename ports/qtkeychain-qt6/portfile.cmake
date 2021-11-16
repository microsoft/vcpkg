message(WARNING "qtkeychain is a third-party extension to Qt and is not affiliated with The Qt Company")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO frankosterfeld/qtkeychain
    REF v0.13.1
    SHA512 552c1632a81f64b91dacdb0f5eb4122b4ddef53ba6621561db6c4fce9f3692761dbc4b452e578023e2882e049874148be1de014397675ce443cfc93fe96f6f70
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
# TODO: remove after next release since https://github.com/frankosterfeld/qtkeychain/pull/204 was merged
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND QTKEYCHAIN_OPTIONS -DQTKEYCHAIN_STATIC:BOOL=ON)
else()
    list(APPEND QTKEYCHAIN_OPTIONS -DQTKEYCHAIN_STATIC:BOOL=OFF)
endif()

# FIXME: Why does build translations fail on arm64-windows?
if (VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL arm64)
     list(APPEND QTKEYCHAIN_OPTIONS -DBUILD_TRANSLATIONS:BOOL=OFF)
else()
     list(APPEND QTKEYCHAIN_OPTIONS -DBUILD_TRANSLATIONS:BOOL=ON)
endif()

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
