vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO frankosterfeld/qtkeychain
    REF v0.12.0
    SHA512 ad8f7b3e8f59894a09892aeb78118f5ed93aa4593eece782c1879a4f3c37d9d63e8d40ad4b2e6a2e286e0da39f45cd4ed46181a1a05c078a59134114b2456a03
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    qt5 QT5
    qt6 QT6
)

# Force the user to explicitly specify whether they want to link Qt5 or Qt6 rather
# than setting a default because accidentally pulling in the wrong dependency could waste
# a lot of time building.
if(NOT QT5 AND NOT QT6)
  message(FATAL_ERROR "Either qt5 or qt6 feature must be selected for qtkeychain.")
endif()

if(QT5 AND QT6)
  message(FATAL_ERROR "qt5 and qt6 features cannot both be enabled for qtkeychain. Pick one or the other.")
endif()

list(APPEND QTKEYCHAIN_OPTIONS -DBUILD_TEST_APPLICATION:BOOL=OFF)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND QTKEYCHAIN_OPTIONS -DQTKEYCHAIN_STATIC:BOOL=ON)
else()
    list(APPEND QTKEYCHAIN_OPTIONS -DQTKEYCHAIN_STATIC:BOOL=OFF)
endif()

if (CMAKE_HOST_WIN32)
    list(APPEND QTKEYCHAIN_OPTIONS -DBUILD_TRANSLATIONS:BOOL=ON)
else()
    list(APPEND QTKEYCHAIN_OPTIONS -DBUILD_TRANSLATIONS:BOOL=OFF)
endif()

if(QT6)
    list(APPEND QTKEYCHAIN_OPTIONS -DBUILD_WITH_QT6:BOOL=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
	OPTIONS ${QTKEYCHAIN_OPTIONS}
)
vcpkg_cmake_install()

vcpkg_copy_pdbs()

if (QT5)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Qt5Keychain)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Qt6Keychain)
endif()
# Remove unneeded dirs
file(REMOVE_RECURSE 
	${CURRENT_PACKAGES_DIR}/debug/include
      ${CURRENT_PACKAGES_DIR}/debug/share
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
