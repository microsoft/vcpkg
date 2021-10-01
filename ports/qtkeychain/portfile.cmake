vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO frankosterfeld/qtkeychain
    REF 6743abd98586fbabd01da9839f53f61ccfb7f83c # v0.11.1
    SHA512 0ad6b82b972ca1cc5f1f8318899637ce0a6786f912b7f9efc1b7eea132ccefbe9a5dc0eb82d0dc9a020bcd55cd538d9e962fc40eb5c828142a7f2186b19633b1
    HEAD_REF master
)

list(APPEND QTKEYCHAIN_OPTIONS -DCMAKE_DEBUG_POSTFIX=d)
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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	OPTIONS ${QTKEYCHAIN_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Qt5Keychain TARGET_PATH share/Qt5Keychain)
# Remove unneeded dirs
file(REMOVE_RECURSE 
	${CURRENT_PACKAGES_DIR}/debug/include
      ${CURRENT_PACKAGES_DIR}/debug/share
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
