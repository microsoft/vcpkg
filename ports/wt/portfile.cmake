include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/wt-3.3.6)

vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/kdeforche/wt/archive/3.3.6.tar.gz"
    FILENAME "wt-3.3.6.tar.gz"
    SHA512 d6135713d300bcd3956a4fd673af73be0561eb5d6aa91c47255b966950ddb411217e6a826c1d11c0d941dbb6d006c9926231d7334b21de6256cca331066e18a6
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
vcpkg_configure_cmake(
SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DSHARED_LIBS=ON
        -DENABLE_SSL=ON
        -DBUILD_EXAMPLES=OFF
        -DENABLE_POSTGRES=OFF
        -DENABLE_FIREBIRD=OFF
        -DENABLE_MYSQL=OFF
        -DENABLE_QT4=OFF
        -DBOOST_DYNAMIC=ON
)
vcpkg_install_cmake()

# There is no way to suppress installation of the headers and resource files in debug build.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/wt RENAME copyright)
vcpkg_copy_pdbs()
