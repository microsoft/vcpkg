vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO albertodemichelis/squirrel
    HEAD_REF master
    REF cf0516720e1fa15c8cbd649aebd1924f6e7084cc
    SHA512 6127d25e40217188abe14e30943f131f0e03923cf095f3df276a9c36b48495cf5d84bb1e30b39fa23bd630d905b6a6b4c70685dfb7a999b8b0c12e28c2e3b902
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_DYNAMIC)

# TODO: currently, squirrel builds samples (see the `sq/` dir) no matter what; it should be an optional build, but there is no option for it and it fails if either DISABLE_STATIC or DISABLE_DYNAMIC option is provided

# if(BUILD_STATIC)
#     set(DISABLE_DYNAMIC ON)
#     set(DISABLE_STATIC OFF)
# elseif(BUILD_DYNAMIC)
#     set(DISABLE_DYNAMIC OFF)
#     set(DISABLE_STATIC ON)
# endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    # OPTIONS
    #     -DDISABLE_DYNAMIC=${DISABLE_DYNAMIC}
    #     -DDISABLE_STATIC=${DISABLE_STATIC}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/squirrel)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(BUILD_STATIC)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
elseif(BUILD_DYNAMIC)
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/bin/sq.exe"
        "${CURRENT_PACKAGES_DIR}/debug/bin/sq_static.exe")

    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin/sq.exe"
        "${CURRENT_PACKAGES_DIR}/bin/sq_static.exe")
endif()

file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
