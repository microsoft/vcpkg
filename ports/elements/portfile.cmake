vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cycfi/elements
    REF "v${VERSION}"
    SHA512 ce47e36a07870bd0851ed1896a5fdf897b2eadcc8d215a4d7042c78062defa58f73c3985b86bfbeb1e76219ccd1cf1bedc0cd5fd2204cb2b74d01cf8b78426a6
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH INFRA_SOURCE_PATH
    REPO cycfi/artist
    REF d64fe8479ba2804cf20f578184bf5bd7550b0f8b
    SHA512 d316883b1ba1b02af789d36292a22db7d1c344b805c437bf98d2650018fd31cb54cf8e2dc697157d9d77c06d77cbdc8d9a5afbaa8957ba453b0561aff1961aec
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

if(VCPKG_TARGET_IS_WINDOWS)
    set(ELEMENTS_HOST_UI_LIBRARY "win32")
elseif(VCPKG_TARGET_IS_OSX)
    set(ELEMENTS_HOST_UI_LIBRARY "cocoa")
else()
    set(ELEMENTS_HOST_UI_LIBRARY "gtk")
endif()

# Prefer native backend over software fallback on OSX/Windows
if(VCPKG_TARGET_IS_WINDOWS)
    set(ARTIST_BACKEND "DIRECT2D")
elseif(VCPKG_TARGET_IS_OSX)
    set(ARTIST_BACKEND "QUARTZ_2D")
else()
    set(ARTIST_BACKEND "CAIRO")
endif()

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DELEMENTS_BUILD_EXAMPLES=OFF
        -DELEMENTS_BUILD_TESTS=OFF
        -DELEMENTS_HOST_UI_LIBRARY=${ELEMENTS_HOST_UI_LIBRARY}
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
    MAYBE_UNUSED_VARIABLES
        PKG_CONFIG_EXECUTABLE
)

vcpkg_cmake_build()

file(INSTALL "${SOURCE_PATH}/lib/include/elements.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/lib/include/elements" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/lib/artist/lib/infra/include/infra" DESTINATION "${CURRENT_PACKAGES_DIR}/include"
    PATTERN "catch.hpp" EXCLUDE
    PATTERN "doctest.hpp" EXCLUDE
)
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
