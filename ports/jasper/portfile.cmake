include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mdadams/jasper
    REF version-2.0.13
    SHA512 8c09a7b773e739a2594cd1002fe66f79ea4336f7de7c97267ab976c06ba075468a7f3c8731dff13a98221cd11d3f2bf8dcddb3fc2c2fc7d7c5ba402bcd3f9fd8
    HEAD_REF master)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(JASPER_LINKAGE -DJAS_ENABLE_SHARED=OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DJAS_ENABLE_AUTOMATIC_DEPENDENCIES=OFF
        -DJAS_ENABLE_LIBJPEG=ON
        -DJAS_ENABLE_OPENGL=OFF # not needed for the library
        -DJAS_ENABLE_DOC=OFF
        ${JASPER_LINKAGE})

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    file(GLOB EXECS ${CURRENT_PACKAGES_DIR}/bin/*.exe ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
    file(REMOVE ${EXECS})
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/jasper)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/jasper/LICENSE ${CURRENT_PACKAGES_DIR}/share/jasper/copyright)
