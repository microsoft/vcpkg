vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MikePopoloski/slang
    REF "v${VERSION}"
    SHA512 f8402e422e8278be363d4630f264885230f11dcf969ffeafefc88c0ac5d0761dd81e7ee5d50bab1d4363d0783600bb974181db78609c021bde4406d8fcf1dbc5
    HEAD_REF master
    PATCHES
        fix-get-target-property.patch
        use-expected-lite.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        mimalloc     SLANG_USE_MIMALLOC
        tools        SLANG_INCLUDE_TOOLS
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DPython_EXECUTABLE=${PYTHON3}"
        -DSLANG_INCLUDE_TESTS=OFF
        -DSLANG_INCLUDE_DOCS=OFF
        -DSLANG_INCLUDE_PYLIB=OFF
        -DSLANG_INCLUDE_INSTALL=ON
        -DSLANG_INCLUDE_COVERAGE=OFF
        -DSLANG_USE_CPPTRACE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/slang")

# Move misplaced pkgconfig files to the correct directory
if(EXISTS "${CURRENT_PACKAGES_DIR}/share/pkgconfig/sv-lang.pc")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
    file(RENAME "${CURRENT_PACKAGES_DIR}/share/pkgconfig/sv-lang.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/sv-lang.pc")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig/sv-lang.pc")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig/sv-lang.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/sv-lang.pc")
endif()

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES slang slang-hier slang-reflect slang-tidy AUTO_CLEAN)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/pkgconfig"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
