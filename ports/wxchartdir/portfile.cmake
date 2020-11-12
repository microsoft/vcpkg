vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO utelle/wxchartdir
    REF v1.0.0
    SHA512 018e588a4bcff594e0049c64597d55b680e58ae239822fcc20d415a1efd8a6b3c0c7c6c836969f01a378209307b9720b938e3826a31e18c843d52897b44b4818
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_from_github(
    OUT_SOURCE_PATH VCPKG_WX_FIND_SOURCE_PATH
    REPO CaeruleusAqua/vcpkg-wx-find
    REF 17993e942f677799b488a06ca659a8e46ff272c9
    SHA512 0fe07d3669f115c9b6a761abd7743f87e67f24d1eae3f3abee4715fa4d6b76af0d1ea3a4bd82dbdbed430ae50295e1722615ce0ee7d46182125f5048185ee153
    HEAD_REF master
)

file(COPY ${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake DESTINATION ${VCPKG_WX_FIND_SOURCE_PATH})
file(COPY ${CMAKE_ROOT}/Modules/FindPackageMessage.cmake DESTINATION ${VCPKG_WX_FIND_SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_MODULE_PATH=${VCPKG_WX_FIND_SOURCE_PATH}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/wxchartdir)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/COPYING.txt ${CURRENT_PACKAGES_DIR}/share/wxchartdir/copyright COPYONLY)

file(COPY ${SOURCE_PATH}/CHARTDIRECTOR-LICENSE.TXT   DESTINATION ${CURRENT_PACKAGES_DIR}/share/wxchartdir)
file(COPY ${SOURCE_PATH}/CHARTDIRECTOR-README.TXT    DESTINATION ${CURRENT_PACKAGES_DIR}/share/wxchartdir)
file(COPY ${SOURCE_PATH}/GPL-3.0.txt                 DESTINATION ${CURRENT_PACKAGES_DIR}/share/wxchartdir)
file(COPY ${SOURCE_PATH}/LGPL-3.0.txt                DESTINATION ${CURRENT_PACKAGES_DIR}/share/wxchartdir)
file(COPY ${SOURCE_PATH}/LICENSE                     DESTINATION ${CURRENT_PACKAGES_DIR}/share/wxchartdir)
file(COPY ${SOURCE_PATH}/LICENSE.spdx                DESTINATION ${CURRENT_PACKAGES_DIR}/share/wxchartdir)
file(COPY ${SOURCE_PATH}/WxWindows-exception-3.1.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/wxchartdir)
