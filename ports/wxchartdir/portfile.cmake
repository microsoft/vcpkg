vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO utelle/wxchartdir
    REF v2.0.0
    SHA512 dd255af1031465c635df7ea7eee2dd15f0dcce30f91cae1eff6527b8b78ea872fa22fa05da5363f57817dc8844c0bc171a2c68f54c38f2519c7bfe0256605622
    HEAD_REF main
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/wxchartdir)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

configure_file("${SOURCE_PATH}/COPYING.txt" "${CURRENT_PACKAGES_DIR}/share/wxchartdir/copyright" COPYONLY)

file(COPY "${SOURCE_PATH}/CHARTDIRECTOR-LICENSE.TXT"   DESTINATION "${CURRENT_PACKAGES_DIR}/share/wxchartdir")
file(COPY "${SOURCE_PATH}/CHARTDIRECTOR-README.TXT"    DESTINATION "${CURRENT_PACKAGES_DIR}/share/wxchartdir")
file(COPY "${SOURCE_PATH}/GPL-3.0.txt"                 DESTINATION "${CURRENT_PACKAGES_DIR}/share/wxchartdir")
file(COPY "${SOURCE_PATH}/LGPL-3.0.txt"                DESTINATION "${CURRENT_PACKAGES_DIR}/share/wxchartdir")
file(COPY "${SOURCE_PATH}/LICENSE"                     DESTINATION "${CURRENT_PACKAGES_DIR}/share/wxchartdir")
file(COPY "${SOURCE_PATH}/LICENSE.spdx"                DESTINATION "${CURRENT_PACKAGES_DIR}/share/wxchartdir")
file(COPY "${SOURCE_PATH}/WxWindows-exception-3.1.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/wxchartdir")
