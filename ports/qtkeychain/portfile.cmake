include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO frankosterfeld/qtkeychain
    REF v0.9.1
    SHA512    c80bd25a5b72c175d0d4a985b952924c807bf67be33eeb89e2b83757727e642c10d8d737cea9744d2faad74c50c1b55d82b306135559c35c91a088c3b198b33a
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

# Remove unneeded dirs
file(REMOVE_RECURSE 
	${CURRENT_PACKAGES_DIR}/debug/include
	${CURRENT_PACKAGES_DIR}/debug/lib/cmake
	${CURRENT_PACKAGES_DIR}/lib/cmake
)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/qtkeychain)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/qtkeychain/COPYING ${CURRENT_PACKAGES_DIR}/share/qtkeychain/copyright)
