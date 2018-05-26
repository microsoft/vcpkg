if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cnjinhao/nana
    REF v1.5.5
    SHA512 d28348b807e131f5868a162cf5b914523246ab5c4d4395186377f54dff9ad91199b13f640e05b5d959347ebfb570df79d5de39abfd690d8831034063422e3587
    HEAD_REF develop
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DMSVC_USE_STATIC_RUNTIME=OFF # dont override our settings
        -DNANA_CMAKE_ENABLE_PNG=ON
        -DNANA_CMAKE_ENABLE_JPEG=ON
    OPTIONS_DEBUG
        -DNANA_CMAKE_INSTALL_INCLUDES=OFF)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/nana)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/nana/LICENSE ${CURRENT_PACKAGES_DIR}/share/nana/copyright)
