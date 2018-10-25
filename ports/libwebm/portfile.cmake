include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO webmproject/libwebm
    REF libwebm-1.0.0.27
    SHA512 15650b8b121b226654a5abed45a3586ddaf785dee8dac7c72df3f3f9aef76af4e561b75a2ef05328af8dfcfde21948b2edb59cd884dad08b8919cab4ee5a8596
    HEAD_REF master
    PATCHES
        0001-fix-cmake.patch
        no-samples.patch
)

if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    set(LIBWEBM_CRT_LINKAGE -DMSVC_RUNTIME=dll)
else()
    set(LIBWEBM_CRT_LINKAGE -DMSVC_RUNTIME=static)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${LIBWEBM_CRT_LINKAGE}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/libwebm)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libwebm/LICENSE.TXT ${CURRENT_PACKAGES_DIR}/share/libwebm/copyright)
