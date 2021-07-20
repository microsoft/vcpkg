vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CedricGuillemet/ImGuizmo
    REF 7daa4b24ffe08b906040079bf297e8b920f86f47
    SHA512 dd4d5ee47753f7f70519f94dd63ab19badc962d02f05e847bc1b9fc9798a5fa617daf9d801dcc9856ffbb989c3070defe71f6d3706eefa72c165327a0d577d22
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")



vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"

    OPTIONS_DEBUG
        -DIMGUIZMO_SKIP_HEADERS=ON
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
