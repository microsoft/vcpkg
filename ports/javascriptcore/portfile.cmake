vcpkg_from_github(
      OUT_SOURCE_PATH SOURCE_PATH
      REPO webkit/webkit
      REF a07d3e4e2067578a818215d89f5742b5e9707389
      SHA512 f7cfe2e1489e4151311811b9d8f5ee1a9850099d5035e646260fd313816d8d3407517d81b8cb851323d08dcb0915b6cfa783636b91130516e5c4942527d10821
      HEAD_REF main
      PATCHES
        remove_webkit_find_package.patch
        tune_jsconly_port_for_windows.patch
        modify_install_rules.patch
)

vcpkg_find_acquire_program(RUBY)
get_filename_component(RUBY_PATH "${RUBY}" DIRECTORY)
vcpkg_add_to_path("${RUBY_PATH}")

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_DIR "${PERL}" DIRECTORY)
vcpkg_add_to_path("${PERL_DIR}")

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  set(ENABLE_STATIC_JSC ON)
else()
  set(ENABLE_STATIC_JSC OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
      -DPORT=JSCOnly
      -DENABLE_STATIC_JSC=${ENABLE_STATIC_JSC}
      -DUSE_APPLE_ICU=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_install_copyright(
  FILE_LIST 
    "${SOURCE_PATH}/Source/WebCore/LICENSE-APPLE"
    "${SOURCE_PATH}/Source/WebCore/LICENSE-LGPL-2.1"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
