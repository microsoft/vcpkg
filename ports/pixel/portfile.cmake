include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dascandy/pixel
    REF v0.3
    SHA512 d7d622679195d0eb30c8ed411333711369b108e2171d1e4b0a93c7ae3bd1fb36a25fbe1f5771c858615c07ee139412e5353b8cb5489cb409dd94829253c18a7b
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()
