include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/log4cplus-REL_1_1_3-RC7)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/log4cplus/log4cplus/archive/REL_1_1_3-RC7.zip"
    FILENAME "REL_1_1_3-RC7.zip"
    SHA512 06320cb2ab6e18e91c6d79a943c9fdcd82b984e8e908e232f0e0e8eca69496f1f3845913107218bc2be356473315f8dfb822a5993bab8efcadfc4819532da823
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DLOG4CPLUS_BUILD_TESTING=OFF -DLOG4CPLUS_BUILD_LOGGINGSERVER=OFF -DWITH_UNIT_TESTS=OFF
)

vcpkg_build_cmake()
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/log4cplus)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/log4cplus/LICENSE ${CURRENT_PACKAGES_DIR}/share/log4cplus/copyright)
