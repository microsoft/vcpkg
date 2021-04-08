vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ultimaker/libArcus
    REF 4.8.0
    SHA512 44db9b48ab6be08c30f2121d68197a7347eaf3ee255649969a773afbe45ec2433e2cc082aa72f6d40dad7ea28345da858471fff9a129365a4e848df8c8c07689
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_PYTHON=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_STATIC=${ENABLE_STATIC}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Arcus TARGET_PATH share/arcus)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/arcus/copyright" COPYONLY)