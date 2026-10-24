vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cycfi/elements
    REF "v${VERSION}"
    SHA512 96db07185bed504890ff4b4d5e7de8be70b1179239e0f493784e184264da77892c337adeb488276f3c842ac7baaee84ee5086f082f30163c3a86de6c96536b56
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH INFRA_SOURCE_PATH
    REPO cycfi/artist
    REF 528ad5fd7500a7f4206669674d9211250acbebd5
    SHA512 f99f0c038cbffdf7314311be6d23880271a1b62207f046f58c911ba32dde608f8609e0350f8b532d64b548fa0241c85d8c5d8a2ab50e3836d69e7610a05dbf4b
    HEAD_REF master
    PATCHES
        libunibreak.patch
)
if(NOT EXISTS "${SOURCE_PATH}/lib/artist/CMakeLists.txt")
    file(REMOVE_RECURSE "${SOURCE_PATH}/lib/artist")
    file(RENAME "${INFRA_SOURCE_PATH}" "${SOURCE_PATH}/lib/artist")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH INFRA_SOURCE_PATH
    REPO cycfi/infra
    REF f78bd0815c4d4e852bdd89711217d7cef0e8575f
    SHA512 d018c7a18aa530194085fe3e202ea55005f35518dfd89f52187f9e7d89157468b647ffe8e310390491f9abe445a9ed0345d9de2a5744161c7881c0f8948be541
    HEAD_REF master
)
if(NOT EXISTS "${SOURCE_PATH}/lib/artist/lib/infra/CMakeLists.txt")
    file(REMOVE_RECURSE "${SOURCE_PATH}/lib/artist/lib/infra")
    file(RENAME "${INFRA_SOURCE_PATH}" "${SOURCE_PATH}/lib/artist/lib/infra")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cairo      ELEMENTS_CAIRO
)

if(VCPKG_TARGET_IS_WINDOWS)
    set(ELEMENTS_HOST_UI_LIBRARY "win32")
elseif(VCPKG_TARGET_IS_OSX)
    set(ELEMENTS_HOST_UI_LIBRARY "cocoa")
else()
    set(ELEMENTS_HOST_UI_LIBRARY "gtk")
endif()

if("cairo" IN_LIST FEATURES)
    set(ARTIST_BACKEND "CAIRO")
else()
    if(VCPKG_TARGET_IS_WINDOWS)
        set(ARTIST_BACKEND "DIRECT2D")
    elseif(VCPKG_TARGET_IS_OSX)
        set(ARTIST_BACKEND "QUARTZ_2D")
    else()
        message(FATAL_ERROR "On Linux, the project defaults to the backend Cairo. The 'cairo' feature must be enabled. Please install elements[cairo].")
    endif()
endif()

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DELEMENTS_BUILD_EXAMPLES=OFF
        -DELEMENTS_HOST_UI_LIBRARY=${ELEMENTS_HOST_UI_LIBRARY}
        ${FEATURE_OPTIONS}
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
    MAYBE_UNUSED_VARIABLES
        PKG_CONFIG_EXECUTABLE
)

vcpkg_cmake_build()

file(INSTALL "${SOURCE_PATH}/lib/include/elements.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/lib/include/elements" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/lib/artist/lib/infra/include/infra" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/lib/artist/lib/include/artist" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(GLOB_RECURSE HPP_FILES "${CURRENT_PACKAGES_DIR}/include/artist/*.hpp")
foreach(FILE_PATH IN LISTS HPP_FILES)
    vcpkg_replace_string("${FILE_PATH}" "defined(ARTIST_${ARTIST_BACKEND})" "1" IGNORE_UNCHANGED)
endforeach()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(GLOB ELEMENTS_LIBS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/*elements*")
    file(GLOB ARTIST_LIBS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/artist/lib/*artist*")
    file(INSTALL ${ELEMENTS_LIBS} ${ARTIST_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(GLOB ELEMENTS_LIBS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/*elements*")
    file(GLOB ARTIST_LIBS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/artist/lib/*artist*")
    file(INSTALL ${ELEMENTS_LIBS} ${ARTIST_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/README.md")
