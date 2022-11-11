vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lloyd/yajl
    REF a0ecdde0c042b9256170f2f8890dd9451a4240aa #2.1.0
    SHA512 cf0279fdbdc21d07bc0f2d409f1dddb39fd2ad62ab9872e620f46de4753958f8c59e44ef2ee734547f0f25f9490bada8c9e97dcc1a4b14b25d3e7a7254f8e1f3
    HEAD_REF master
    PATCHES cmake.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if (EXISTS "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig/yajl.pc")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig/yajl.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/yajl.pc")
endif()
if (EXISTS "${CURRENT_PACKAGES_DIR}/share/pkgconfig/yajl.pc")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
    file(RENAME "${CURRENT_PACKAGES_DIR}/share/pkgconfig/yajl.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/yajl.pc")
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/share/pkgconfig")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(GLOB SHAREDOBJECTS "${CURRENT_PACKAGES_DIR}/lib/libyajl.so*" "${CURRENT_PACKAGES_DIR}/debug/lib/libyajl.so*")
    file(REMOVE_RECURSE "${SHAREDOBJECTS}" "${CURRENT_PACKAGES_DIR}/lib/yajl.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/yajl.lib")
else()
    file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*.exe" "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
    file(REMOVE_RECURSE
        ${EXES}
        "${CURRENT_PACKAGES_DIR}/lib/yajl_s.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/yajl_s.lib"
        "${CURRENT_PACKAGES_DIR}/lib/libyajl_s.a" "${CURRENT_PACKAGES_DIR}/debug/lib/libyajl_s.a"
    )
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/yajl" RENAME copyright)
