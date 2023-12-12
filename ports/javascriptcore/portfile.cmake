# vcpkg_from_github(
#     OUT_SOURCE_PATH SOURCE_PATH
#     REPO webkit/webkit
#     REF WebKit-7616.1.27.211.1
#     SHA512 aea5feb085f9adaa6efbbb840b2bdbc677c69c82c53c611ef9b527ae4ea2490a983dfdc55eb8aa471ab9975b748ea51d2cf9f2c853454904018ab8bb0ec77ad0
#     HEAD_REF main
#     PATCHES
#       remove_webkit_find_package.patch
# )
#
# vcpkg_find_acquire_program(RUBY)
# get_filename_component(RUBY_PATH "${RUBY}" DIRECTORY)
# vcpkg_add_to_path("${RUBY_PATH}")
# message(STATUS "RUBY_PATH: ${RUBY_PATH}")
#
# vcpkg_find_acquire_program(PYTHON3)
# get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
# vcpkg_add_to_path("${PYTHON3_DIR}")
# message(STATUS "PYTHON3_DIR: ${PYTHON3_DIR}")
#
# vcpkg_find_acquire_program(PERL)
# get_filename_component(PERL_DIR "${PERL}" DIRECTORY)
# vcpkg_add_to_path("${PERL_DIR}")
# message(STATUS "PERL_DIR: ${PERL_DIR}")
#
# vcpkg_find_acquire_program(GPERF)
# get_filename_component(GPERF_DIR "${GPERF}" DIRECTORY)
# vcpkg_add_to_path("${GPERF_DIR}")
# message(STATUS "GPERF_DIR: ${GPERF_DIR}")
#
# vcpkg_execute_required_process(
#   COMMAND "${PYTHON3}" "${SOURCE_PATH}/Tools/Scripts/update-webkit-wincairo-libs.py"
#         WORKING_DIRECTORY ${SOURCE_PATH}
#         LOGNAME updatewincairolibs-${TARGET_TRIPLET}
# )
#
# vcpkg_cmake_configure(
#   SOURCE_PATH ${SOURCE_PATH}
#   DISABLE_PARALLEL_CONFIGURE
#   OPTIONS
#     -DPORT=WinCairo
#     -DWEBKIT_LIBRARIES_DIR=${SOURCE_PATH}/WebKitLibraries/win
# )
#
# vcpkg_cmake_build(
#   TARGET JavaScriptCore
# )
# vcpkg_cmake_install()
# file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libogg" RENAME copyright)
vcpkg_install_copyright(FILE_LIST "ports/javascriptcore/LICENSE-APPLE")

file(INSTALL "ports/javascriptcore/Headers/JavaScriptCore" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "ports/javascriptcore/lib/JavaScriptCore.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "ports/javascriptcore/bin/JavaScriptCore.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "ports/javascriptcore/bin/JavaScriptCore.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "ports/javascriptcore/bin/WTF.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "ports/javascriptcore/bin/WTF.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "ports/javascriptcore/bin/icudt74.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "ports/javascriptcore/bin/icudt74.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "ports/javascriptcore/bin/icuin74.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "ports/javascriptcore/bin/icuin74.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "ports/javascriptcore/bin/icuuc74.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "ports/javascriptcore/bin/icuuc74.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")

file(INSTALL "ports/javascriptcore/debug/lib/JavaScriptCore.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
file(INSTALL "ports/javascriptcore/debug/bin/JavaScriptCore.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
file(INSTALL "ports/javascriptcore/debug/bin/JavaScriptCore.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
file(INSTALL "ports/javascriptcore/debug/bin/WTF.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
file(INSTALL "ports/javascriptcore/debug/bin/WTF.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
file(INSTALL "ports/javascriptcore/bin/icudt74.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
file(INSTALL "ports/javascriptcore/bin/icudt74.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
file(INSTALL "ports/javascriptcore/bin/icuin74.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
file(INSTALL "ports/javascriptcore/bin/icuin74.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
file(INSTALL "ports/javascriptcore/bin/icuuc74.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
file(INSTALL "ports/javascriptcore/bin/icuuc74.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
