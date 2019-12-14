
vcpkg_download_distfile(ARCHIVE
    URLS "https://netix.dl.sourceforge.net/project/wxmathplot/wxmathplot/0.1.2/wxMathPlot-0.1.2.tar.gz"
    FILENAME "wxMathPlot-0.1.2.tar.gz"
    SHA512 528354345544f2553e09cd0d6f4c6e69aa1e2e938a7ae2615c5546e1a2718fbdc1b9f325e4e11368825ae54b185bc5f8aec6a1a9796abce57fec052f14ee1607
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES 0001-wxmathplot-svn-r95-trunk.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH VCPKG_WX_FIND_SOURCE_PATH
    REPO CaeruleusAqua/vcpkg-wx-find
    REF 17993e942f677799b488a06ca659a8e46ff272c9
    SHA512 0fe07d3669f115c9b6a761abd7743f87e67f24d1eae3f3abee4715fa4d6b76af0d1ea3a4bd82dbdbed430ae50295e1722615ce0ee7d46182125f5048185ee153
    HEAD_REF master
)

file(COPY ${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake DESTINATION ${VCPKG_WX_FIND_SOURCE_PATH})
file(COPY ${CMAKE_ROOT}/Modules/FindPackageMessage.cmake DESTINATION ${VCPKG_WX_FIND_SOURCE_PATH})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_MODULE_PATH=${VCPKG_WX_FIND_SOURCE_PATH}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/wxmathplot)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/debian/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
