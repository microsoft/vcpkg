vcpkg_from_github(
      OUT_SOURCE_PATH SOURCE_PATH
      REPO webkit/webkit
      REF WebKit-7616.1.27.211.1
      SHA512 aea5feb085f9adaa6efbbb840b2bdbc677c69c82c53c611ef9b527ae4ea2490a983dfdc55eb8aa471ab9975b748ea51d2cf9f2c853454904018ab8bb0ec77ad0
      HEAD_REF main
      PATCHES
        remove_webkit_find_package.patch
        tune_jsconly_port_for_windows.patch
        tune_wtf.patch
        modify_install_rules.patch
        disable_api_tests.patch
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
