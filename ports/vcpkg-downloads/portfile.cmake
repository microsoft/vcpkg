file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-downloads.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${VCPKG_ROOT_DIR}/LICENSE.txt")
set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

block()
  set(other_src_dir "${CURRENT_BUILDTREES_DIR}/src2")
  include("${CMAKE_CURRENT_LIST_DIR}/vcpkg-downloads.cmake")
  vcpkg_download_from_json(JSONS "${CMAKE_CURRENT_LIST_DIR}/download.json")
  message(STATUS "extracted_src_github:${extracted_src_github}")
  message(STATUS "extracted_src_gitlab:${extracted_src_gitlab}")
  message(STATUS "extracted_src_bitbucket:${extracted_src_bitbucket}")
  message(STATUS "extracted_src_sourceforge:${extracted_src_sourceforge}")
  message(STATUS "extracted_src_git:${extracted_src_git}")
endblock()

message(FATAL_ERROR)