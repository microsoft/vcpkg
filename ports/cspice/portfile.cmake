if (VCPKG_TARGET_IS_WINDOWS)
    if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(SUBPATH "PC_Windows_VisualC_32bit/packages/cspice.zip")
        set(SHA512 1949fd12b30ca0e42f53311a97d8571e68737f6a667a56946d3415ee715dda0a1adca9bfc985b9b9447084189c50d261f2c00960cbe2ddf6a1d1d92cf8fa17ab)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(SUBPATH "PC_Windows_VisualC_64bit/packages/cspice.zip")
        set(SHA512 5457f24279fb485b0ac92713dab026d1c1ed766a358fcf7d9ce3f70693e75da85a656e72b1ada4dc334e9e68d6c0eb42b2a31f3ad0c83b491dd3afc79e5cda98)
    endif()
elseif(VCPKG_TARGET_IS_OSX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(SUBPATH "MacIntel_OSX_AppleC_64bit/packages/cspice.tar.Z")
        set(SHA512 ea9a32c763cd54303de180b4895a195cd5ef6774051f18a1812f2fff39adc0ca9d5dd7878853af40e766882e79a0f542a45139656fb79fb4b436c4bc5bdecddc)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(SUBPATH "MacM1_OSX_clang_64bit/packages/cspice.tar.Z")
        set(SHA512 a64f028ec1935dbc7f8d03c903fbfa40cfff097ec4aa0ca4aa1d2ee08561833000e7caf99d6550b06d2a0874cbaf1767382e7a9aea6a39228f3eaa89c6c31a6d)
    endif()
else()
    if ((VCPKG_TARGET_ARCHITECTURE STREQUAL "x86") OR (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm"))
        set(SUBPATH "PC_Linux_GCC_32bit/packages/cspice.tar.Z")
        set(SHA512 22a6250376e9f98d75ecc8682c5432a07a89addc9812010ad97059491e2c19cab418d7aa3f591bded9df132fcfb6865686f0ecfe70821ad31061ae2f7b165f2b)
    elseif((VCPKG_TARGET_ARCHITECTURE STREQUAL "x64") OR (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64"))
        set(SUBPATH "PC_Linux_GCC_64bit/packages/cspice.tar.Z")
        set(SHA512 59946f628284cd31c75a23c152d725ae7e01b179f97c52b98518eceeda54bc38875b1dd93dc17574c0bf00e706e0ee35d06ecb5d7871d49633baa8f16eb6c7c8)
    endif()
endif()

set(VERSION 67)
set(URL "https://naif.jpl.nasa.gov/pub/naif/misc/toolkit_N00${VERSION}/C/${SUBPATH}")
get_filename_component(ext "${SUBPATH}" EXT)
string(SUBSTRING "${SHA512}" 0 6 subsha)
vcpkg_download_distfile(ARCHIVE URLS "${URL}" FILENAME "cspice-${subsha}${ext}" SHA512 "${SHA512}")

set(PATCHES isatty.patch)
if (NOT VCPKG_TARGET_IS_WINDOWS)
    set(PATCHES ${PATCHES} mktemp.patch)
endif()

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
    PATCHES ${PATCHES}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(_STATIC_BUILD ON)
endif()

if (VCPKG_TARGET_IS_UWP)
    set(VCPKG_C_FLAGS "/sdl- ${VCPKG_C_FLAGS}")
    set(VCPKG_CXX_FLAGS "/sdl- ${VCPKG_CXX_FLAGS}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -D_STATIC_BUILD=${_STATIC_BUILD}
    OPTIONS_DEBUG -D_SKIP_HEADERS=ON
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(
    INSTALL ${CMAKE_CURRENT_LIST_DIR}/License.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright
)
