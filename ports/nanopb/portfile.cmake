include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanopb/nanopb
    REF ae9901f2a31500e8fdc93fa9804d24851c58bb1e
    SHA512 2173096e8fc0191e348f79e73662ebc1b1ffeeae96f22344b098fc19603459f78abadab5f6ea8dbbb54e9c237502f114214f9870daa2971c3fef4c2fa999e732
    HEAD_REF master
)

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "static" BUILD_STATIC_LIBS)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dnanopb_BUILD_RUNTIME=ON
        -Dnanopb_BUILD_GENERATOR=OFF
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
