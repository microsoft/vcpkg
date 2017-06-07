###

set(MAGNUM_HASH c8416ca4c3e9b68ba62acc9f73de235526cb3d6e)

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/magnum-${MAGNUM_HASH})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/mosra/magnum/archive/${MAGNUM_HASH}.zip"
    FILENAME "magnum-${MAGNUM_HASH}.zip"
    SHA512 1248efaba22568a753396192624690a478c69946cdbbffe83e34cb85d54ec65756b693e025bf477fc192e6fecce56dc1b68631e1a763986267b83d6530af6ef4
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DWITH_SDL2APPLICATION=ON
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)


# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/magnum)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/magnum/COPYING ${CURRENT_PACKAGES_DIR}/share/magnum/copyright)

vcpkg_copy_pdbs()