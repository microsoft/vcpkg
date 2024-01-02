vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
      OUT_SOURCE_PATH SOURCE_PATH
      REPO webkit/webkit
      REF WebKit-7616.1.27.211.1
      SHA512 aea5feb085f9adaa6efbbb840b2bdbc677c69c82c53c611ef9b527ae4ea2490a983dfdc55eb8aa471ab9975b748ea51d2cf9f2c853454904018ab8bb0ec77ad0
      HEAD_REF main
      PATCHES
        remove_webkit_find_package.patch
        tune_jsconly_port_for_windows.patch
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

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
      -DPORT=JSCOnly
)
vcpkg_cmake_build(
  TARGET JavaScriptCore
)

vcpkg_install_copyright(
  FILE_LIST 
    "${SOURCE_PATH}/Source/WebCore/LICENSE-APPLE"
    "${SOURCE_PATH}/Source/WebCore/LICENSE-LGPL-2.1"
)

file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib64/JavaScriptCore.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin64/JavaScriptCore.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin64/JavaScriptCore.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin64/WTF.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin64/WTF.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")

file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib64/JavaScriptCore.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bin64/JavaScriptCore.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bin64/JavaScriptCore.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bin64/WTF.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bin64/WTF.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")

file(INSTALL "${SOURCE_PATH}/Source/JavaScriptCore/API/JavaScript.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/JavaScriptCore")
file(INSTALL "${SOURCE_PATH}/Source/JavaScriptCore/API/JavaScriptCore.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/JavaScriptCore")
file(INSTALL "${SOURCE_PATH}/Source/JavaScriptCore/API/JSBase.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/JavaScriptCore")
file(INSTALL "${SOURCE_PATH}/Source/JavaScriptCore/API/JSContextRef.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/JavaScriptCore")
file(INSTALL "${SOURCE_PATH}/Source/JavaScriptCore/API/JSObjectRef.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/JavaScriptCore")
file(INSTALL "${SOURCE_PATH}/Source/JavaScriptCore/API/JSStringRef.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/JavaScriptCore")
file(INSTALL "${SOURCE_PATH}/Source/JavaScriptCore/API/JSStringRefBSTR.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/JavaScriptCore")
file(INSTALL "${SOURCE_PATH}/Source/JavaScriptCore/API/JSTypedArray.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/JavaScriptCore")
file(INSTALL "${SOURCE_PATH}/Source/JavaScriptCore/API/JSValueRef.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/JavaScriptCore")
file(INSTALL "${SOURCE_PATH}/Source/JavaScriptCore/API/WebKitAvailability.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/JavaScriptCore")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
