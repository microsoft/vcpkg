vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qtrest/qtrest
    REF 0.3.0
    SHA512 380b724e8dff1dda7a337dc37654b6c11f4f8816f43f5316168f16e8c97ae546b9e4b553b0064380b50c1a823b62a60a9c02fbbcddfb0adda7e9e33613989f3c	
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
