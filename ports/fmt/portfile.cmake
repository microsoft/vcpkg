include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fmtlib/fmt
    REF 4.0.0
    SHA512 8b9f7ce4720c3caef6de4a75b8d4b0fd7db4f1638edca98d5ea95f4a5157aef8faefbac68438236691bd373111ca089b4d3864f7352f3fba1fe44392e9644f8b
    HEAD_REF master
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
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/fmt.dll ${CURRENT_PACKAGES_DIR}/bin/fmt.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/fmt.dll ${CURRENT_PACKAGES_DIR}/debug/bin/fmt.dll)

    # Force FMT_SHARED to 1
    file(READ ${CURRENT_PACKAGES_DIR}/include/fmt/format.h FMT_FORMAT_H)
    string(REPLACE "defined(FMT_SHARED)" "1" FMT_FORMAT_H "${FMT_FORMAT_H}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/fmt/format.h "${FMT_FORMAT_H}")
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets()

file(READ ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-debug.cmake FMT_DEBUG_MODULE)
string(REPLACE "lib/fmt.dll" "bin/fmt.dll" FMT_DEBUG_MODULE ${FMT_DEBUG_MODULE})
file(WRITE ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-debug.cmake "${FMT_DEBUG_MODULE}")
file(READ ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-release.cmake FMT_RELEASE_MODULE)
string(REPLACE "lib/fmt.dll" "bin/fmt.dll" FMT_RELEASE_MODULE ${FMT_RELEASE_MODULE})
file(WRITE ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-release.cmake "${FMT_RELEASE_MODULE}")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()
