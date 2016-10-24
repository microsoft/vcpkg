include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libzmq-1a02b1b3f2fde6288579cbb0ff9a0b1f195e1812)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/zeromq/libzmq/archive/1a02b1b3f2fde6288579cbb0ff9a0b1f195e1812.zip"
    FILENAME "zeromq-1a02b1b3f2fde6288579cbb0ff9a0b1f195e1812.zip"
    SHA512 64a5cfb23dd2daa99c9c5a5e2b0693458658e34102b07169a43c63c159af88181ec36caaaa2c780303c4ceba3c4b901e409baebaf12106bdf6a14c5832dfa219
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/builds/msvc/vs2015/libzmq/libzmq.vcxproj
    RELEASE_CONFIGURATION ReleaseDLL
    DEBUG_CONFIGURATION DebugDLL
)

file(INSTALL
    ${SOURCE_PATH}/bin/Win32/Debug/v140/dynamic/libzmq.dll
    ${SOURCE_PATH}/bin/Win32/Debug/v140/dynamic/libzmq.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
)
file(INSTALL
    ${SOURCE_PATH}/bin/Win32/Release/v140/dynamic/libzmq.dll
    ${SOURCE_PATH}/bin/Win32/Release/v140/dynamic/libzmq.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin
)
file(INSTALL
    ${SOURCE_PATH}/bin/Win32/Debug/v140/dynamic/libzmq.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)
file(INSTALL
    ${SOURCE_PATH}/bin/Win32/Release/v140/dynamic/libzmq.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)
file(INSTALL
    ${SOURCE_PATH}/include/
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/zeromq)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/zeromq/COPYING ${CURRENT_PACKAGES_DIR}/share/zeromq/copyright)

vcpkg_copy_pdbs()
