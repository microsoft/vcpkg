vcpkg_fail_port_install(
    ON_TARGET "OSX" "iOS" "Linux" "Android" "UWP"
)

set(VERSION 2.5.24)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lexxmark/winflexbison
    REF v${VERSION}
    SHA512 a681f15dce23a39d1daea287f1c451fdc06d37bee27ac8329f44e254cffa7a435439d2b25401f70efe6d3d59bb49ebfc59a1355c4c0b8ae5fd81d6b4d39f971f
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    WINDOWS_USE_MSBUILD
)

vcpkg_cmake_build()

if(NOT DEFINED VCPKG_BUILD_TYPE)
    set(VCPKG_BUILD_TYPE release)
endif()

foreach(buildtype IN ITEMS debug release)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL buildtype)
        if(buildtype STREQUAL "debug")
            set(src_path ${SOURCE_PATH}/bin/Debug)
        else()
            set(src_path ${SOURCE_PATH}/bin/Release)
        endif()

        set(pack_path ${CURRENT_PACKAGES_DIR}/tools/${PORT})

        file(GLOB TO_INSTALL ${src_path}/*)

        foreach(file IN LISTS TO_INSTALL)
            file(COPY ${file} DESTINATION ${pack_path})
        endforeach()
    endif()
endforeach()

file(INSTALL ${SOURCE_PATH}/flex/src/FlexLexer.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/winflexbison RENAME copyright)
