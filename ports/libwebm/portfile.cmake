include(vcpkg_common_functions)

set(LIBWEBM_VERSION 1.0.0.27)
set(LIBWEBM_HASH 15650b8b121b226654a5abed45a3586ddaf785dee8dac7c72df3f3f9aef76af4e561b75a2ef05328af8dfcfde21948b2edb59cd884dad08b8919cab4ee5a8596)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libwebm-libwebm-${LIBWEBM_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/webmproject/libwebm/archive/libwebm-${LIBWEBM_VERSION}.tar.gz"
    FILENAME "libwebm-${LIBWEBM_VERSION}.tar.gz"
    SHA512 ${LIBWEBM_HASH}
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/0001-fix-cmake.patch")   

if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(LIBWEBM_CRT_LINKAGE -DMSVC_RUNTIME=dll)
else()
    set(LIBWEBM_CRT_LINKAGE -DMSVC_RUNTIME=static)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${LIBWEBM_CRT_LINKAGE})

vcpkg_build_cmake()
vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/libwebm)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libwebm/LICENSE.TXT ${CURRENT_PACKAGES_DIR}/share/libwebm/copyright)
