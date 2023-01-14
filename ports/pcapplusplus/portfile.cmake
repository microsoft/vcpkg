if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO seladb/PcapPlusPlus
    REF v22.11
    SHA512 41a507ce385d8549186eeec1a1ae138070ab2021d9ffd907829551b3b865ecb526fa05a0ff9ca01b41a2a2807a60a3cba016f62063d30d849282c83e17a2b6e1
    HEAD_REF master
)
file(COPY "${CURRENT_PORT_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(APPEND ${CURRENT_PACKAGES_DIR}/share/unofficial-pcapplusplus/unofficial-pcapplusplus-config.cmake "
include(CMakeFindDependencyMacro)
find_dependency(Threads)")

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-pcapplusplus)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
