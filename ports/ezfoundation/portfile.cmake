vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ezEngine/ezEngine
    REF "release-${VERSION}"
    SHA512 c27f8241969c5c257123b789a964e102331a98f1803e038fa0521794ebdc7500f733bd987e1c53111a6220bd403f4ceffdbc2eb183aec7a178a2ffaf9a129afe
    HEAD_REF dev
    PATCHES
        ezengine-da345.patch # Backport of https://github.com/ezEngine/ezEngine/commit/da345c931aa000c80ee5904a19416fb4eed7b00d.diff?full_index=1
        disable-warnings-as-errors.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DEZ_3RDPARTY_ENET_SUPPORT=OFF
        -DEZ_3RDPARTY_ZSTD_SUPPORT=OFF
        -DEZ_3RDPARTY_ZLIB_SUPPORT=OFF
        -DEZ_BUILD_FILTER=FoundationOnly
        -DEZ_BUILD_UNITTESTS=OFF
        -DEZ_CMAKE_NO_BUILD_INFO=ON
        -DEZ_COMPILE_ENGINE_AS_DLL=OFF
        -DEZ_ENABLE_FOLDER_UNITY_FILES=OFF
        -DEZ_ENABLE_QT_SUPPORT=OFF
        -DEZ_USE_PCH=OFF
    OPTIONS_DEBUG
        -DEZ_OUTPUT_DIRECTORY_LIB=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Output/Lib
        -DEZ_OUTPUT_DIRECTORY_DLL=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Output/Bin
    OPTIONS_RELEASE
        -DCMAKE_BUILD_TYPE=Shipping
        -DEZ_OUTPUT_DIRECTORY_LIB=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Output/Lib
        -DEZ_OUTPUT_DIRECTORY_DLL=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Output/Bin
)

vcpkg_cmake_build(TARGET Foundation)

# EzEngine does not support CMake-based install; copy headers and libraries manually.
file(GLOB_RECURSE FOUNDATION_INCLUDE_FILES RELATIVE "${SOURCE_PATH}/Code/Engine/Foundation" "${SOURCE_PATH}/Code/Engine/Foundation/*.h")
foreach(SOURCE_FILE ${FOUNDATION_INCLUDE_FILES})
    get_filename_component(SOURCE_FILE_DIR "${SOURCE_FILE}" DIRECTORY)
    if(SOURCE_FILE_DIR STREQUAL "")
        set(TARGET_DIR "${CURRENT_PACKAGES_DIR}/include/Foundation")
    else()
        set(TARGET_DIR "${CURRENT_PACKAGES_DIR}/include/Foundation/${SOURCE_FILE_DIR}")
    endif()
    file(COPY "${SOURCE_PATH}/Code/Engine/Foundation/${SOURCE_FILE}" DESTINATION "${TARGET_DIR}")
endforeach()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug) 
    set(LIB_SOURCE_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Output/Lib")
    set(LIB_TARGET_DIR "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(GLOB_RECURSE LIB_FILES "${LIB_SOURCE_DIR}/*.lib")
    foreach(LIB_FILE ${LIB_FILES})
        file(COPY "${LIB_FILE}" DESTINATION "${LIB_TARGET_DIR}")
    endforeach()
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL release) 
    set(LIB_SOURCE_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Output/Lib")
    set(LIB_TARGET_DIR "${CURRENT_PACKAGES_DIR}/lib")
    file(GLOB_RECURSE LIB_FILES "${LIB_SOURCE_DIR}/*.lib")
    foreach(LIB_FILE ${LIB_FILES})
        file(COPY "${LIB_FILE}" DESTINATION "${LIB_TARGET_DIR}")
    endforeach()
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
