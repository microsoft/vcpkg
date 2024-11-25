set(OATPP_VERSION "1.3.0-latest")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp-swagger
    REF ${OATPP_VERSION}
    SHA512 a6b3fce21bef57a055c498e80afefacf7b8219fc03381c468b8555c003566bc3e1ce0672670b46e99c51e090cd7000195c7dfeb0258851c4e05bec9ee4c652b3
    HEAD_REF master
)

if (VCPKG_CRT_LINKAGE STREQUAL "static")
    set(OATPP_MSVC_LINK_STATIC_RUNTIME TRUE)
else()
    set(OATPP_MSVC_LINK_STATIC_RUNTIME FALSE)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DOATPP_BUILD_TESTS:BOOL=OFF"
        "-DOATPP_MSVC_LINK_STATIC_RUNTIME=${OATPP_MSVC_LINK_STATIC_RUNTIME}"
)

function(strip_version version output_var)
    string(REGEX REPLACE "([0-9]+\\.[0-9]+\\.[0-9]+).*" "\\1" stripped_version "${version}")
    set(${output_var} "${stripped_version}" PARENT_SCOPE)
endfunction()
 
strip_version("${OATPP_VERSION}" OATPP_VERSION_STRIPPED)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME oatpp-swagger CONFIG_PATH lib/cmake/oatpp-swagger-${OATPP_VERSION_STRIPPED})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
