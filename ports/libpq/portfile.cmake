# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/postgresql-9.6.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.postgresql.org/pub/source/v9.6.1/postgresql-9.6.1.tar.bz2"
    FILENAME "postgresql-9.6.1.tar.bz2"
    SHA512 f27af67f9a96f6327150330bf091a803e10eabbac4e488cf5e4d72907e2eb1dbde7282fe0b89fd75711fd8bdcdb3688b5a9eac1e4d6871f4e8681c9c8b0e7c45
)
vcpkg_extract_source_archive(${ARCHIVE})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    OPTIONS_DEBUG -DINSTALL_INCLUDES=OFF
)

vcpkg_install_cmake()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/libpq)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libpq/COPYRIGHT ${CURRENT_PACKAGES_DIR}/share/libpq/copyright)

vcpkg_copy_pdbs()
