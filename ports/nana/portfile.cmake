if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cnjinhao/nana
    REF v1.5.3
    SHA512 92f2a5023da180616420c411d4ebe0abf5043493688ada82aa5fa15a9331a8842f7def219a1d9edf476b40d311caac1354a5042c87b377af88117fdfae2daced
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
