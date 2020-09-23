if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "UWP builds not supported")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rhash/RHash
    REF 75716b45c21416c98c0ab2e3c2735b150e7afb03 # v1.3.9
    SHA512 dfadd7878aa88959f058b677ef96c9837e7efd851f45f2fbc93198c7ae1beadccbe1112b0e6c5822565eba102948d762b65b9cc46e43eeae97a9cd1f362c1554
    HEAD_REF master)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/librhash)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/librhash
    PREFER_NINJA
    OPTIONS_DEBUG
        -DRHASH_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/rhash)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/rhash/COPYING ${CURRENT_PACKAGES_DIR}/share/rhash/copyright)
