vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fmtlib/fmt
    REF 6.0.0
    SHA512 7deb5bd843ae6b9d4b58dca9c68c1cfe7b55a41040f358247f5309655188d1ae194ff414437c068f74367f078faa214b5883e8c9e634c7623dcda50850e24766
    HEAD_REF master
    PATCHES fix-warning4189.patch
)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFMT_CMAKE_DIR=share/fmt
        -DFMT_TEST=OFF
        -DFMT_DOC=OFF
)

vcpkg_install_cmake()
file(INSTALL ${SOURCE_PATH}/LICENSE.rst DESTINATION ${CURRENT_PACKAGES_DIR}/share/fmt RENAME copyright)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR NOT VCPKG_CMAKE_SYSTEM_NAME)
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
            file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/fmtd.dll ${CURRENT_PACKAGES_DIR}/debug/bin/fmtd.dll)
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
            file(RENAME ${CURRENT_PACKAGES_DIR}/lib/fmt.dll ${CURRENT_PACKAGES_DIR}/bin/fmt.dll)
        endif()
    endif()

    # Force FMT_SHARED to 1
    file(READ ${CURRENT_PACKAGES_DIR}/include/fmt/core.h FMT_CORE_H)
    string(REPLACE "defined(FMT_SHARED)" "1" FMT_CORE_H "${FMT_CORE_H}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/fmt/core.h "${FMT_CORE_H}")
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR NOT VCPKG_CMAKE_SYSTEM_NAME)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(READ ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-debug.cmake FMT_DEBUG_MODULE)
        string(REPLACE "lib/fmtd.dll" "bin/fmtd.dll" FMT_DEBUG_MODULE ${FMT_DEBUG_MODULE})
        file(WRITE ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-debug.cmake "${FMT_DEBUG_MODULE}")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(READ ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-release.cmake FMT_RELEASE_MODULE)
        string(REPLACE "lib/fmt.dll" "bin/fmt.dll" FMT_RELEASE_MODULE ${FMT_RELEASE_MODULE})
        file(WRITE ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-release.cmake "${FMT_RELEASE_MODULE}")
    endif()
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()
