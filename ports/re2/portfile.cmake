include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/re2
    REF 89528a380a7e9722dbf7b5a817251049eab355fb
    SHA512 7654a41ea42e816e7ecd80e554e6e5ab11e7d2f4d2c547a3083f990500668c74ae74870fe5a6390521b44edc2be8ce11d86a187600229e3d8b9d8b3114cfa4e8
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DRE2_BUILD_TESTING=OFF
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/re2 RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
