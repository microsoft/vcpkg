if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cnjinhao/nana
    REF v1.5.4
    SHA512 54d8d06a7792c7c626793f0c5f769884d7af78950a1df7d543f13bbb6de5ae35b51130a150438faa1c3c53dfea29fad6d12b94c535c264aac893325b244c6e0a
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
