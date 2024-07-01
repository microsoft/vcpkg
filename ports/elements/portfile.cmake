if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cycfi/elements
    REF 83ae36ca102a270c7ebc7ac9d151baba30ccb975
    SHA512 aba29307edaa86cc9f112b6af0c6a74cd1633c875cc9bf4cc7da135459e817519344cf107b90a1314d9073325b04ef4725b0ee4bd830f2bcb7213cf8efac09d9
    HEAD_REF master
    PATCHES
        asio-headers.patch
        fix-linkage.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH INFRA_SOURCE_PATH
    REPO cycfi/infra
    REF 2c9e509fc92bb4931fef19cb625817fa6c7da60b
    SHA512 85fcc273e41ca714d413976578dd0697d7910df75f49249bb4345d7b28ba0f3fe96fabdd7d366f28d862af219fb53eb02751e0dc21f884ebf57cf42ac4d30570
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
        -DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}
)

vcpkg_cmake_build()

file(INSTALL "${SOURCE_PATH}/lib/include/elements.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/lib/include/elements" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/lib/infra/include/infra" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/resources" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(GLOB ELEMENTS_LIBS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/*elements*")
    file(INSTALL ${ELEMENTS_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(GLOB ELEMENTS_LIBS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/*elements*")
    file(INSTALL ${ELEMENTS_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/README.md")
