vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO protocolbuffers/upb
    REF  bef53686ec702607971bd3ea4d4fefd80c6cc6e8 # 2022-04-04
    SHA512 3801625827a5511ab28e047d7111e6f43d522872eef929b61d7a64fdb9fff7a058af45fd55bd409610c07c735f50a2f6f45ad611bb5e4ee86cd656b89f0a8278
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

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        codegen VCPKG_UPB_BUILD_CODEGEN
)

if(NOT VCPKG_UPB_BUILD_CODEGEN)
    vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf" "${CURRENT_HOST_INSTALLED_DIR}/tools/upb")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cmake"
    OPTIONS ${FEATURE_OPTIONS}
        "-DVCPKG_UPB_HOST_INCLUDE_DIR=${CURRENT_HOST_INSTALLED_DIR}/include"
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)
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
