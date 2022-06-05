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

if(NOT TARGET_TRIPLET STREQUAL HOST_TRIPLET)
    vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/upb")
endif()

vcpkg_find_acquire_program(PYTHON3)

vcpkg_execute_required_process(
    COMMAND "${PYTHON3}" "${SOURCE_PATH}/cmake/make_cmakelists.py" "cmake/CMakeLists.txt"
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME make_cmakelists)

vcpkg_replace_string("${SOURCE_PATH}/cmake/CMakeLists.txt" "/third_party/utf8_range)" "utf8_range)")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        codegen VCPKG_UPB_BUILD_CODEGEN
)

if(NOT VCPKG_UPB_BUILD_CODEGEN)
    set(VCPKG_UPB_HOST_INSTALLED_DIR_ARG "-DVCPKG_UPB_HOST_INSTALLED_DIR=${CURRENT_HOST_INSTALLED_DIR}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cmake"
    OPTIONS ${FEATURE_OPTIONS}
        "${VCPKG_UPB_HOST_INSTALLED_DIR_ARG}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

if (VCPKG_UPB_BUILD_CODEGEN)
    vcpkg_copy_tools(
        AUTO_CLEAN
        TOOL_NAMES
            protoc-gen-upbdefs
            protoc-gen-upb
    )
else()
    configure_file("${CMAKE_CURRENT_LIST_DIR}/upb-config-vcpkg-tools.cmake" "${CURRENT_PACKAGES_DIR}/share/upb/upb-config-vcpkg-tools.cmake" @ONLY)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/upb/fuzz" "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
