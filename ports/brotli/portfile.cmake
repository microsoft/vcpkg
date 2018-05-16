include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/brotli
    REF v1.0.2
    SHA512 b3ec98159e63b4169dea3e958d60d89247dc1c0f78aab27bfffb2ece659fa024df990d410aa15c12b2082d42e3785e32ec248dce2b116c7f34e98bb6337f9fc9
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBROTLI_DISABLE_TESTS=ON
)

vcpkg_install_cmake()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/brotli)
file(GLOB EXES ${CURRENT_PACKAGES_DIR}/bin/brotli ${CURRENT_PACKAGES_DIR}/bin/brotli.exe)
file(GLOB DEBUG_EXES ${CURRENT_PACKAGES_DIR}/debug/bin/brotli ${CURRENT_PACKAGES_DIR}/debug/bin/brotli.exe)
file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/brotli)
file(REMOVE ${EXES} ${DEBUG_EXES})

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/brotli)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(GLOB STATIC_LIBS "${CURRENT_PACKAGES_DIR}/lib/*-static.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/*-static.lib")
    file(REMOVE ${STATIC_LIBS})
else()
    file(GLOB LIBS
        "${CURRENT_PACKAGES_DIR}/lib/*.lib"
        "${CURRENT_PACKAGES_DIR}/debug/lib/*.lib"
        "${CURRENT_PACKAGES_DIR}/lib/*.a"
        "${CURRENT_PACKAGES_DIR}/debug/lib/*.a"
    )
    list(FILTER LIBS EXCLUDE REGEX "-static\\.lib\$")
    list(FILTER LIBS EXCLUDE REGEX "-static\\.a\$")
    file(REMOVE_RECURSE ${LIBS} ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/brotli RENAME copyright)

vcpkg_copy_pdbs()
