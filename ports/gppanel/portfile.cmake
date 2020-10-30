vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO woollybah/gppanel
    REF f58a9028f7c9a8e9b4324ff2165951f558365f90
    SHA512 4ec5fbef4c487d351c60f48b0c0e41c5d077989ab96f827b9fd5ef01c167d50f39a313bd82db1b5df19d14025983e83db4d19cc4048c1c50fc8ef9128de15575
    HEAD_REF master
    PATCHES 00001-fix-build.patch
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
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/gpPanel)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/gpPanel/copyright COPYONLY)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/gpPanel)
