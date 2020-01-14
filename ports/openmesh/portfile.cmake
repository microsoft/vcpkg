include(vcpkg_common_functions)

set(VERSION 8.0)

# Note: upstream GitLab instance at https://graphics.rwth-aachen.de:9000 often goes down
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.openmesh.org/media/Releases/${VERSION}/OpenMesh-${VERSION}.tar.gz"
    FILENAME "OpenMesh-${VERSION}.tar.gz"
    SHA512 6c9cb323d83d48daca7ddefe51df67f611befd657655d8013c2c620ad53e0b8521e6b8e25ebf3f5321f94182252ae0c75795875ff7ac11585e4ffa79e16f8008
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF "${VERSION}"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DBUILD_APPS=OFF
    # [TODO]: add apps as feature, requires qt5 and freeglut
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/OpenMesh/Tools/VDPM/xpm)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openmesh RENAME copyright)
