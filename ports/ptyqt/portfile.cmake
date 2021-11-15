vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kafeg/ptyqt
    REF 0.6.0
    SHA512 03c7bc7491861129fc0b7832c95bd33b6eb4e669069955d3b40e0622762fe8fdde9f2ef4a28af939ea5abbf736224b4ee60e95de7a78250e94d5fdbd2fa1b88a
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
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Windows")
    list(APPEND OPTIONS -DWINPTY_LIBS=${CURRENT_INSTALLED_DIR}/lib/winpty.lib)
    list(APPEND OPTIONS -DWINPTY_DBGLIBS=${CURRENT_INSTALLED_DIR}/debug/lib/winpty.lib)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
		-DNO_BUILD_TESTS=1
		-DNO_BUILD_EXAMPLES=1
		)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# cleanup
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
	file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
endif()

#license
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ptyqt)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ptyqt/LICENSE ${CURRENT_PACKAGES_DIR}/share/ptyqt/copyright)
