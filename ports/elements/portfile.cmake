vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cycfi/elements
    REF 663dcdb82dffa9e70cf6643b50ed56a39c8015ed
    SHA512 4fc579df6dd471c69996a991e4b2c4c204e7f02d1d247de7a962fcd97d472cb63b58faa2ab7a0cfb47cc004a03483d4ef9123cbd8f562ba7007d779ba03221ca
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH INFRA_SOURCE_PATH
    REPO cycfi/infra
    REF 965ecdb953c8c1187b327cff12655f9a92352acc
    SHA512 37d990ec70aa37dded3d464cadc28cedd320986ea5816669698de43376bb77d0f32951f0f8a03af65a472a46886ddf628e7acfd0314dd5ebfa49a3e98984054f
    HEAD_REF master
)
if(NOT EXISTS "${SOURCE_PATH}/lib/infra/CMakeLists.txt")
    file(REMOVE_RECURSE "${SOURCE_PATH}/lib/infra")
    file(RENAME "${INFRA_SOURCE_PATH}" "${SOURCE_PATH}/lib/infra")
endif()


if(VCPKG_TARGET_IS_WINDOWS)
    set(ELEMENTS_HOST_UI_LIBRARY "win32")
elseif(VCPKG_TARGET_IS_OSX)
    set(ELEMENTS_HOST_UI_LIBRARY "cocoa")
else()
    set(ELEMENTS_HOST_UI_LIBRARY "gtk")
endif()

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DELEMENTS_BUILD_EXAMPLES=OFF
        -DELEMENTS_HOST_UI_LIBRARY=${ELEMENTS_HOST_UI_LIBRARY}
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)

vcpkg_cmake_build()

file(INSTALL "${SOURCE_PATH}/lib/include/elements.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/lib/include/elements" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/lib/infra/include/infra" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(GLOB ELEMENTS_LIBS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/*elements*")
    file(INSTALL ${ELEMENTS_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(GLOB ELEMENTS_LIBS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/*elements*")
    file(INSTALL ${ELEMENTS_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/README.md")
