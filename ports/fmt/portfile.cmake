include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fmtlib/fmt
    REF 5.1.0
    SHA512 b759a718353254fa8cd981e483bf01a45af0fc76901216404ace5e47f5d3edf43d42422184e5413c221e49832322fdf60d1860e8ec87349c674511064b31e5d6
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFMT_CMAKE_DIR=share/fmt
        -DFMT_TEST=OFF
        -DFMT_DOC=OFF
        -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON
)

vcpkg_install_cmake()
file(INSTALL ${SOURCE_PATH}/LICENSE.rst DESTINATION ${CURRENT_PACKAGES_DIR}/share/fmt RENAME copyright)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/fmt.dll ${CURRENT_PACKAGES_DIR}/bin/fmt.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/fmtd.dll ${CURRENT_PACKAGES_DIR}/debug/bin/fmtd.dll)

    # Force FMT_SHARED to 1
    file(READ ${CURRENT_PACKAGES_DIR}/include/fmt/core.h FMT_CORE_H)
    string(REPLACE "defined(FMT_SHARED)" "1" FMT_CORE_H "${FMT_CORE_H}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/fmt/core.h "${FMT_CORE_H}")
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets()

file(READ ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-debug.cmake FMT_DEBUG_MODULE)
string(REPLACE "lib/fmtd.dll" "bin/fmtd.dll" FMT_DEBUG_MODULE ${FMT_DEBUG_MODULE})
file(WRITE ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-debug.cmake "${FMT_DEBUG_MODULE}")
file(READ ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-release.cmake FMT_RELEASE_MODULE)
string(REPLACE "lib/fmt.dll" "bin/fmt.dll" FMT_RELEASE_MODULE ${FMT_RELEASE_MODULE})
file(WRITE ${CURRENT_PACKAGES_DIR}/share/fmt/fmt-targets-release.cmake "${FMT_RELEASE_MODULE}")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()
