vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO witwall/mman-win32
    REF f5ff813c53935c3078f48e1f03a6944c4e7b459c
    SHA512 49c9a63a0a3c6fa585a76e65425f6fb1fdaa23cc87e53d5afb7a1298bcd4956298c076ee78f24dd5df5f5a0c5f6244c6abb63b40818e4d2546185fa37a73bf0d
    HEAD_REF master
    PATCHES
        mman-static.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include/mman)
file(RENAME ${CURRENT_PACKAGES_DIR}/include/sys ${CURRENT_PACKAGES_DIR}/include/mman/sys)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/mman)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/mman RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mman/sys/mman.h" "__declspec(dllimport)" "")
endif()

vcpkg_copy_pdbs()
