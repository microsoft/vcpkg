include(vcpkg_common_functions)

# the repo is fork of https://github.com/lewissbaker/cppcoro to support CMake / VcPkg
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            luncliff/cppcoro
    REF             20b4217a65165d0ec7849fbe7970310cdf31b6a5
    SHA512          ab1545da09bb7053d95afd4ea9d5ec17cc42824d047e6887632c1d14c1b02a77cb8b99b73b7e51293a252e13ef615eaa89a31cdb6aa88148f9f8f6a450fa0599
    HEAD_REF        master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=False
)
vcpkg_install_cmake()

file(INSTALL     ${SOURCE_PATH}/LICENSE.txt
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/cppcoro
     RENAME      copyright
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
