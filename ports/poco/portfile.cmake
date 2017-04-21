include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/poco-poco-1.7.8-release)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/pocoproject/poco/archive/poco-1.7.8-release.tar.gz"
    FILENAME "poco-poco-1.7.8-release.tar.gz"
    SHA512 50a47e6f69491859f48b72e3695c380ec871f7d5249d938216e3be41579d752675e5d746a150720d93122f87f585ebeea24dc9660c81642a12e70f761b9d2502
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/config_h.patch
        ${CMAKE_CURRENT_LIST_DIR}/find_pcre.patch
        ${CMAKE_CURRENT_LIST_DIR}/foundation-public-include-pcre.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(POCO_STATIC ON)
else()
    set(POCO_STATIC OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPOCO_STATIC=${POCO_STATIC}
        -DENABLE_SEVENZIP=ON
        -DENABLE_TESTS=OFF
        -DPOCO_UNBUNDLED=ON # OFF means: using internal copy of sqlite, libz, pcre, expat, ...
)

vcpkg_install_cmake()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/cpspc.exe ${CURRENT_PACKAGES_DIR}/tools/cpspc.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/f2cpsp.exe ${CURRENT_PACKAGES_DIR}/tools/f2cpsp.exe)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE 
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    file(REMOVE 
        ${CURRENT_PACKAGES_DIR}/bin/cpspc.pdb
        ${CURRENT_PACKAGES_DIR}/bin/f2cpsp.pdb
        ${CURRENT_PACKAGES_DIR}/debug/bin/cpspc.exe
        ${CURRENT_PACKAGES_DIR}/debug/bin/cpspc.pdb
        ${CURRENT_PACKAGES_DIR}/debug/bin/f2cpsp.exe
        ${CURRENT_PACKAGES_DIR}/debug/bin/f2cpsp.pdb)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

# copy license
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/poco)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/poco/LICENSE ${CURRENT_PACKAGES_DIR}/share/poco/copyright)
