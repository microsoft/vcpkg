vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VCPKG_TARGET_IS_LINUX)
    message("Warning: cppcoro requires libc++ and Clang on Linux. See https://github.com/microsoft/vcpkg/pull/10693#issuecomment-610394650.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            lewissbaker/cppcoro
    REF             391215262bd40d68ac6534810164131f5f9eb148 #2022-10-25
    SHA512          22372a0385d6628e81d44cb3096186f7f79f53dff7786815546bfe6d8e1f5af4eae769c6b23e7d18aa123105418780d022239ebd48d25237fe6face9b74e42e8
    HEAD_REF        master
)

file(COPY           "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
     DESTINATION    "${SOURCE_PATH}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=False
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(INSTALL     "${SOURCE_PATH}/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME      copyright
)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
