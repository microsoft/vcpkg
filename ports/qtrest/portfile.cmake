vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qtrest/qtrest
    REF prepare_for_vcpkg
    SHA512 c6ab46e3967951bf8ff0baa52145984a2c4ad675c8fff423b3a0758df5a07809de4f2dbad16879fe00e75e484937633a7ed9035715055393d54c247a10912d73	
    HEAD_REF master
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(BUILD_TYPE SHARED)
else()
    set(BUILD_TYPE STATIC)
endif()

list(APPEND CORE_OPTIONS
    -DBUILD_TYPE=${BUILD_TYPE}
    -DBUILD_EXAMPLE=0
)

if("qml" IN_LIST FEATURES)
    list(APPEND CORE_OPTIONS -DWITH_QML_SUPPORT=1)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${CORE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
