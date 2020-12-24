vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(CAF_TOOL_PATH )
if (VCPKG_TARGET_IS_WINDOWS AND (TRIPLET_SYSTEM_ARCH STREQUAL arm OR TRIPLET_SYSTEM_ARCH STREQUAL arm64))
    if (EXISTS ${CURRENT_INSTALLED_DIR}/../x86-windows/tools/caf-generate-enum-strings.exe)
        set(CAF_TOOL_PATH ${CURRENT_INSTALLED_DIR}/../x86-windows/tools/)
    elseif (EXISTS ${CURRENT_INSTALLED_DIR}/../x86-windows-static/tools/caf-generate-enum-strings.exe)
        set(CAF_TOOL_PATH ${CURRENT_INSTALLED_DIR}/../x86-windows-static/tools/)
    elseif (EXISTS ${CURRENT_INSTALLED_DIR}/../x64-windows/tools/caf-generate-enum-strings.exe AND CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86_64")
        set(CAF_TOOL_PATH ${CURRENT_INSTALLED_DIR}/../x64-windows/tools/)
    elseif (EXISTS ${CURRENT_INSTALLED_DIR}/../x64-windows-static/tools/caf-generate-enum-strings.exe AND CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86_64")
        set(CAF_TOOL_PATH ${CURRENT_INSTALLED_DIR}/../x64-windows-static/tools/)
    else()
        message(FATAL_ERROR "Since caf needs to run the built-in executable, please install caf:x86-windows or caf:x64-windows first.")
    endif()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO actor-framework/actor-framework
    REF f7d4fc7ac679e18ba385f64434f8015c3cea9cb5 # 0.17.6
    SHA512 8b4719c26dfad68eed6f2528263702e42f9865bb7a9f2d40909dc6c3fc20bb7259fe44a5f89390ba714c7f9359db2d171ff44685641962c24a70f4e2aa3f3f65
    HEAD_REF master
	PATCHES
		openssl-version-override.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        -DCAF_BUILD_STATIC=ON
        -DCAF_BUILD_STATIC_ONLY=ON
        -DCAF_NO_TOOLS=ON
        -DCAF_NO_EXAMPLES=ON
        -DCAF_NO_BENCHMARKS=ON
        -DCAF_NO_UNIT_TESTS=ON
        -DCAF_NO_PROTOBUF_EXAMPLES=ON
        -DCAF_NO_QT_EXAMPLES=ON
        -DCAF_NO_OPENCL=ON
        -DCAF_NO_OPENSSL=OFF
        -DCAF_NO_CURL_EXAMPLES=ON
        -DCAF_OPENSSL_VERSION_OVERRIDE=ON
        -DCAF_TOOL_PATH=${CAF_TOOL_PATH}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
    
file(COPY ${SOURCE_PATH}/cmake/FindCAF.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

vcpkg_copy_pdbs()
