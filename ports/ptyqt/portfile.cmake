vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kafeg/ptyqt
    REF 0.6.5
    SHA512 0deb12be6c0e7bb44775daef3d4361c5d22143bc32cbf251ef99f10784b8996c4aa8e2806f1e08c3b39749ada6e85be91d721830ceee5d6ff86eaf714ef4c928
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
