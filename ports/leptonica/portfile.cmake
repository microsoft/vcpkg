include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DanBloomberg/leptonica
    REF 1ac72c93fef1a5eb76b76d6723d2aee843dd6e51 # 1.80.0
    SHA512 d6d1af744691b70601b9f3d292d4593c36d392bcfd9e4c190fd533c2df40fcedfc226868429c25fad9b54c8ed68b61750832c9984c47ff72fc702dd3c3f438d6
    HEAD_REF master
    PATCHES
        fix-cmakelists.patch
        use-tiff-libraries.patch
        find-dependency.patch
        fix-find-libwebp.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSTATIC=${STATIC}
        -DCMAKE_REQUIRED_INCLUDES=${CURRENT_INSTALLED_DIR}/include # for check_include_file()
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/leptonica-license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/leptonica-license.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
