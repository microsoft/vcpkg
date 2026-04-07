set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cameron314/readerwriterqueue
    REF "v${VERSION}"
    SHA512 adabc72f94dd9d9fedda9d1123bc1496c19e667c911b17058407718c79337a2532f7510abbcc1b6d69fb4bf54df8765b6ac64925929ef676912a5285eacc07c5
    HEAD_REF master
)

vcpkg_cmake_configure( 
    SOURCE_PATH "${SOURCE_PATH}"
) 

vcpkg_cmake_install() 
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT}) 
vcpkg_fixup_pkgconfig() 

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
