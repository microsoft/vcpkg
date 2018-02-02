include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/kealib-1.4.7)
vcpkg_download_distfile(ARCHIVE
    URLS "https://bitbucket.org/chchrsc/kealib/downloads/kealib-1.4.7.tar.gz"
    FILENAME "kealib-1.4.7.tar.gz"
    SHA512 2d58d7d08943d028e19a24f3ad3316a13b4db59be8697cebf30ee621e6bf0a6a47bf61abadd972d6ea7af1c8eed28bba7edf40fb8709fcccc1effbc90ae6e244
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-cmake.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED_LIBS)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/trunk
    PREFER_NINJA
    OPTIONS -DBUILD_SHARED_LIBS=${ENABLE_SHARED_LIBS} -DLIBKEA_WITH_GDAL=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/kealib RENAME copyright)
