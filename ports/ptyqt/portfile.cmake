vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kafeg/ptyqt
    REF 0.6.2
    SHA512 75e69af5d8f3633e11ef9726f9673a628ac67bb1bda0a1dca921c64a6d22421a6fe51d08b267d3f461a6a68d27a1eadb7e8dacf07fe1b82737575c4150bfe5ed
    HEAD_REF master)

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

set(OPTIONS "")

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(BUILD_TYPE SHARED)
    list(APPEND OPTIONS -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=TRUE)
else()
    set(BUILD_TYPE STATIC)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DNO_BUILD_TESTS=1
        -DNO_BUILD_EXAMPLES=1
        -DBUILD_TYPE=${BUILD_TYPE}
        ${OPTIONS}
        )

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# cleanup
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
endif()

#license
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ptyqt)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ptyqt/LICENSE ${CURRENT_PACKAGES_DIR}/share/ptyqt/copyright)
