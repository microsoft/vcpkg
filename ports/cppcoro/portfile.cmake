vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VCPKG_TARGET_IS_LINUX)
    message("Warning: cppcoro requires libc++ and Clang on Linux. See https://github.com/microsoft/vcpkg/pull/10693#issuecomment-610394650.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            lewissbaker/cppcoro
    REF             92892f31d0c41b8e34e6292d7c9d99228da5c501
    SHA512          d1997b7449f1c5c0790575d0755ffbb5f9eef13a7610f3ec666a585bdbb93bb1553f79214c1023a1ef23aaeef64078ca6ee3784107645d7a75c7bba943c10b84
    HEAD_REF        master
)

file(COPY           ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
     DESTINATION    ${SOURCE_PATH}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=False
)
vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

file(INSTALL     ${SOURCE_PATH}/LICENSE.txt
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
     RENAME      copyright
)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
