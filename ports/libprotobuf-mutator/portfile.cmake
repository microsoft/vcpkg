if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/libprotobuf-mutator
    REF v1.0
    SHA512 75e423289f938d4332d98033062cd9608b71141b7ca1df4e8f28c927c51a16e7ff2f5bf08867308d2a291fc2422e4456f8928ab2c11d545eeb982ea732baf2e9
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_RUNTIME)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DLIB_PROTO_MUTATOR_TESTING=OFF
        -DLIB_PROTO_MUTATOR_MSVC_STATIC_RUNTIME=${STATIC_RUNTIME}
        -DPKG_CONFIG_PATH=lib/pkgconfig
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
