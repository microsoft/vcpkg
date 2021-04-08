# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaseyCarter/cmcstl2
    REF cca84b9fd362ea37334ccbe09a66be4121768ac9
    SHA512 a528dda26964a8c29f2bf7ddb24a861f337246e9ab2bda19f62d4ca107951aa77e37070623db3b5574973404ccf2f201bc2020654b3d53de36d8a22de521e5b9
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSTL2_BUILD_EXAMPLES=OFF
        -DSTL2_BUILD_TESTING=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
