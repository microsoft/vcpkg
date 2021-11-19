vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kafeg/ptyqt
    REF 0.6.3
    SHA512 7a490a6d0cca500d202b0524abf8596d70872c224eea778efd941ad2a995a8a53d295e3ac000ca8fb63e02467f1191ae6bddfd8469fe5df2aca8af972d06fcff
    HEAD_REF master
)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -lrt")
    set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} -lrt")

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        file(READ ${SOURCE_PATH}/core/CMakeLists.txt filedata)
        string(REPLACE "-static-libstdc++" "-static-libstdc++ -lglib-2.0" filedata "${filedata}")
        file(WRITE ${SOURCE_PATH}/core/CMakeLists.txt "${filedata}")
    else()
        file(READ ${SOURCE_PATH}/core/CMakeLists.txt filedata)
        string(REPLACE "-static-libstdc++ -lglib-2.0" "-static-libstdc++" filedata "${filedata}")
        file(WRITE ${SOURCE_PATH}/core/CMakeLists.txt "${filedata}")
    endif()
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(BUILD_TYPE SHARED)
else()
    set(BUILD_TYPE STATIC)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DNO_BUILD_TESTS=1
        -DNO_BUILD_EXAMPLES=1
        -DBUILD_TYPE=${BUILD_TYPE}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
