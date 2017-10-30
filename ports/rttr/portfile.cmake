if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  message("Rttr only supports dynamic library linkage")
  set(VCPKG_LIBRARY_LINKAGE "dynamic")
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/rttr-0.9.5-src)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.rttr.org/releases/rttr-0.9.5-src.zip"
    FILENAME "rttr-0.9.5-src.zip"
    SHA512 49110cb588d2dd40a42de34b21a898fe7e21bd1e57f33b9183292c9e7cb8c8aa9e811e24613854a91e97d5cee2e561b430d89deab9f715081a3c6a1866966258
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/rttr-0.9.5-src
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/fix-directory-output.patch"
        "${CMAKE_CURRENT_LIST_DIR}/disable-unit-tests.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

#Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/rttr)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/rttr/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/rttr/copyright)
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/cmake
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/README.md
    ${CURRENT_PACKAGES_DIR}/debug/LICENSE.txt
    ${CURRENT_PACKAGES_DIR}/LICENSE.txt
    ${CURRENT_PACKAGES_DIR}/README.md
)


