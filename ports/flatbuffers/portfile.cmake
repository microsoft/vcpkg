if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message("Building DLLs not supported. Building static instead.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/flatbuffers
    REF v1.9.0
    SHA512 0ba07dbe5b2fde1d0a6e14ee26ee2816062541d934eda204b846a30c019362f2626761b628c900293928b9b546dba8ca477c13182e022c3e0e0a142fd67f0696
    HEAD_REF master
)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    list(APPEND OPTIONS -DFLATBUFFERS_BUILD_FLATC=OFF -DFLATBUFFERS_BUILD_FLATHASH=OFF)
endif()

set(OPTIONS)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND OPTIONS -DFLATBUFFERS_BUILD_SHAREDLIB=ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DFLATBUFFERS_BUILD_TESTS=OFF
        -DFLATBUFFERS_BUILD_GRPCTEST=OFF
        ${OPTIONS}
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/flatbuffers")

if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/bin/flatc.exe)
    make_directory(${CURRENT_PACKAGES_DIR}/tools/flatbuffers)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/flatc.exe ${CURRENT_PACKAGES_DIR}/tools/flatbuffers/flatc.exe)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/flatbuffers.dll)
    make_directory(${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/flatbuffers.dll ${CURRENT_PACKAGES_DIR}/bin/flatbuffers.dll)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/flatbuffers.dll)
    make_directory(${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/flatbuffers.dll ${CURRENT_PACKAGES_DIR}/debug/bin/flatbuffers.dll)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/flatbuffers)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/flatbuffers/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/flatbuffers/copyright)
