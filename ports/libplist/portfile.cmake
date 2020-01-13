vcpkg_check_linkage(ONLY_DYNAMIC_CRT ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libplist
    REF f1b85c037693b5749a38473aa6c013ca45a663bf # v1.2.137
    SHA512 b38d6dc3f4d480d35d847afeab4c90f90edf249fe506c95a30af40acfb7ecbd978334fa5557cf1421716054db748f6d1d540f2405001b9b597cd56cfbfe2c671
    HEAD_REF msvc-master
    PATCHES dllexport.patch
)

configure_file(${CURRENT_PORT_DIR}/CMakeLists.txt ${SOURCE_PATH}/CMakeLists.txt COPYONLY)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
