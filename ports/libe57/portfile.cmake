set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/E57RefImpl_src-1.1.312)
vcpkg_download_distfile(ARCHIVE
    URLS "https://downloads.sourceforge.net/project/e57-3d-imgfmt/E57Refimpl-src/E57RefImpl_src-1.1.312.zip"
    FILENAME "E57RefImpl_src-1.1.312.zip"
    SHA512 c729cc3094131f115ddf9b8c24a9420c4ab9d16a4343acfefb42f997f4bf25247cd5563126271df2af95f103093b7f6b360dbade52c9e66ec39dd2f06e041eb7
)

vcpkg_extract_source_archive_ex(
  OUT_SOURCE_PATH SOURCE_PATH
  ARCHIVE ${ARCHIVE}
  PATCHES 
    "0001_cmake.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/share/libe57)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
vcpkg_copy_pdbs()

vcpkg_copy_tools(
    TOOL_NAMES e57fields e57unpack e57validate e57xmldump las2e57
    AUTO_CLEAN
)
    
file(INSTALL ${SOURCE_PATH}/README.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/src/refimpl/E57RefImplConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/e57refimpl/)

file(INSTALL ${SOURCE_PATH}/include/E57Simple.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/e57)
file(INSTALL ${SOURCE_PATH}/include/LASReader.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/e57)
file(INSTALL ${SOURCE_PATH}/include/time_conversion/time_conversion.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/e57/time_conversion)
file(INSTALL ${SOURCE_PATH}/include/time_conversion/basictypes.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/e57/time_conversion)
file(INSTALL ${SOURCE_PATH}/include/time_conversion/constants.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/e57/time_conversion)
file(INSTALL ${SOURCE_PATH}/include/time_conversion/gnss_error.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/e57/time_conversion)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)

file(REMOVE ${CURRENT_PACKAGES_DIR}/CHANGES.TXT)
file(REMOVE ${CURRENT_PACKAGES_DIR}/E57RefImplConfig.cmake)
file(REMOVE ${CURRENT_PACKAGES_DIR}/README.TXT)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/CHANGES.TXT)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/E57RefImplConfig.cmake)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/README.TXT)