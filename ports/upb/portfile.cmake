vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO protocolbuffers/upb
    REF  e5f26018368b11aab672e8e8bb76513f3620c579 # 2022-06-01
    SHA512 37c22ab7718a323971449a495fe7386c37c9c0ad2cbc72c17621b5c18ac433c79f0f34cbde4339805aacc47cad84c3ae6b029931fa9a1639d8644f4caf0e5528
    HEAD_REF master
    PATCHES
        0001-make-cmakelists-py.patch
        0002-fix-uwp.patch
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_execute_required_process(
    COMMAND "${PYTHON3}" "${SOURCE_PATH}/cmake/make_cmakelists.py" "cmake/CMakeLists.txt"
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME make_cmakelists)

vcpkg_replace_string("${SOURCE_PATH}/cmake/CMakeLists.txt" "/third_party/utf8_range)" "utf8_range)")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cmake"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/upb/fuzz" "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
