
find_program(GIT git)

set(GIT_URL "https://github.com/DragonJoker/ShaderWriter.git")
set(GIT_BRANCH "master")
set(GIT_REV "e978c96c959e8aa41eedaef322dcc6a0ec00ad49")
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/${PORT}-${GIT_REV})

if(NOT EXISTS "${SOURCE_PATH}/.git")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone ${GIT_URL} ${SOURCE_PATH}/ -b ${GIT_BRANCH}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
        LOGNAME clone
    )
    vcpkg_execute_required_process(
        COMMAND ${GIT} checkout ${GIT_REV}
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME checkout
    )
    vcpkg_execute_required_process(
        COMMAND ${GIT} submodule update --init CMake
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME submodule
    )
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS
            -DCMAKE_INSTALL_PREFIX=${CURRENT_INSTALLED_DIR}
            -DPROJECTS_USE_PRECOMPILED_HEADERS=OFF
            -DSDW_GENERATE_SOURCE=OFF
            -DSDW_BUILD_TESTS=OFF
            -DSDW_BUILD_STATIC_SDW=OFF
            -DSDW_BUILD_EXPORTER_GLSL_STATIC=OFF
            -DSDW_BUILD_EXPORTER_HLSL_STATIC=OFF
            -DSDW_BUILD_EXPORTER_SPIRV_STATIC=OFF
    )
else ()
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS
            -DCMAKE_INSTALL_PREFIX=${CURRENT_INSTALLED_DIR}
            -DPROJECTS_USE_PRECOMPILED_HEADERS=OFF
            -DSDW_GENERATE_SOURCE=OFF
            -DSDW_BUILD_TESTS=OFF
            -DSDW_BUILD_STATIC_SDW=ON
            -DSDW_BUILD_EXPORTER_GLSL_STATIC=ON
            -DSDW_BUILD_EXPORTER_HLSL_STATIC=ON
            -DSDW_BUILD_EXPORTER_SPIRV_STATIC=ON
    )
endif ()
vcpkg_install_cmake()
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/shaderwriter RENAME copyright)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/shaderwriter)
