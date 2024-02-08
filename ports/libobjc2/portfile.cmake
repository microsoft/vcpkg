vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gnustep/libobjc2
    REF "v${VERSION}"
    SHA512 4e49dc00be5a9282678b7cd4793ef1c4202e4a7f26dba2a170f0ff77b0f311c0f44eb72093a01367be34f12156ffd07fec40067162b9c0e4f561ec0784ab0643
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_cmake_get_vars(cmake_vars_file)
    include("${cmake_vars_file}")

    if(VCPKG_DETECTED_CMAKE_C_COMPILER_ID STREQUAL "MSVC")
        vcpkg_find_acquire_program(CLANG)
        cmake_path(GET CLANG PARENT_PATH CLANG_PARENT_PATH)
        set(CLANG_CL "${CLANG_PARENT_PATH}/clang-cl.exe")

        list(APPEND OPTIONS -DCMAKE_C_COMPILER=${CLANG_CL})
        list(APPEND OPTIONS -DCMAKE_CXX_COMPILER=${CLANG_CL})
        list(APPEND OPTIONS "-DCMAKE_OBJC_FLAGS=-Xclang -fobjc-exceptions")
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

# Temporary workaround; this will be fixed in a future version, see https://github.com/gnustep/libobjc2/pull/275
if(VCPKG_TARGET_IS_WINDOWS)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/objc.dll" "${CURRENT_PACKAGES_DIR}/bin/objc.dll")
    
    if(NOT VCPKG_BUILD_TYPE)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/objc.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/objc.dll")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
