if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO seladb/PcapPlusPlus
    REF v22.05
    SHA512 8ffe33406b903fe104f7bf0cf7254028bb3a9997bb5f4b226276af3b2a310e1ed1621558b9fd96ed09c75fa05dfcbfbd7111fe4b19a9288eb214ebcf1254cf6b
    HEAD_REF master
)
file(COPY "${CURRENT_PORT_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")