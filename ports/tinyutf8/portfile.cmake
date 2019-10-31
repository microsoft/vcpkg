include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DuffsDevice/tinyutf8
    REF 8f94649c9f285a9c2e58f2726133177dc1f6188a # v3.1
    SHA512 c7fa311e693e80e1ab7a27d560a768193204d65b9ff39f568db553970c69ef9f782d5286c1a77aff8f627345629be7f866a628c896cd98c791d7cbb1347bc8e6
    HEAD_REF master
    PATCHES fixbuild.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" TINYUTF8_BUILD_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DTINYUTF8_BUILD_STATIC=${TINYUTF8_BUILD_STATIC}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENCE ${CURRENT_PACKAGES_DIR}/share/tinyutf8/copyright COPYONLY)

# remove unneeded files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
