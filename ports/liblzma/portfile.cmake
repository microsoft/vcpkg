include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xz-mirror/xz
    REF v5.2.3
    SHA512 d126666e58c6536aa7ae6aa6aac480f421e25aa61c4b5e7adb3de7b99423275a94d583ceaf0b15d559eaf9bc9be18f381cd46e49b1f8cb238c1d715876731063
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/v5.2.3-b3437cea7b
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/enable-uwp-builds.patch"
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DLIBLZMA_SKIP_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_apply_patches(
        SOURCE_PATH ${CURRENT_PACKAGES_DIR}/include
        PATCHES
            ${CMAKE_CURRENT_LIST_DIR}/auto-define-lzma-api-static.patch)
endif()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblzma)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/liblzma/COPYING ${CURRENT_PACKAGES_DIR}/share/liblzma/copyright)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblzma)
