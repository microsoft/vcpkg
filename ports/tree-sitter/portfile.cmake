vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO tree-sitter/tree-sitter
  REF "v${VERSION}"
  SHA512 9861b18c7209e3c37d180a399bcae181cea46c4e58eff743ff6044ed0f2923ee838fa88993f1266272e07163748d5df1bef7d7dc6d8800e004e8af1227e489af
  HEAD_REF master
)

# Handle parsers
list(APPEND PARSERS
  "bash|tree-sitter/tree-sitter-bash||0.23.3|4882f12aed6dc73f15c0452af38ad400ab0fe386eb33aa61b3c7133fc86d48fff4f0a29302cb5c3ced55eddb2fd65d39414585833cad59a02e98417ef5aac1ba"
  "c|tree-sitter/tree-sitter-c||0.23.5|76022e55c613901e6c58d08e425aa0d527027d0130ce6bed2c5f83cd9056a8bdfef7af73ccd5df056b03515a9a733d64759b37766ccaa994f757c8e5c51b9a74"
  "cpp|tree-sitter/tree-sitter-cpp||0.23.4|baebacf06ea1527132c641b4e2a2e997c501a63708d7afdb5d9456de519dbd652f25aee03a7b4112ef9a683fa176aaaf96d272de286223773a5d6cdf01605a2e"
  "csharp|tree-sitter/tree-sitter-c-sharp||0.23.1|8b4467d13f7947b38b13ed1b81f09dd6754155d2a0090d557e7252cd103f80de23d6890cc6de7142f39332cd88395b9976b89833232f16582646c96f1d28a31a"
  "css|tree-sitter/tree-sitter-css||0.23.2|b013d8c14a64c1383563915976b1f5e9ec16a531c83ec35c8be36193fe50f5546b95bf1871e4abf631af5815b655e9c40c99db586cab8c156110eb33fa61ec18"
  "go|tree-sitter/tree-sitter-go||0.23.4|94a930b848003604dfb0e947f37b622fea31dc14bc72bc87948c67adfb7857261d0c7701592d59a5d2475e2c8bed6c7ed363981f9f45f6868b7c20ae10368485"
  "html|tree-sitter/tree-sitter-html||0.23.2|71b8eb2907d372c55a3a28f1d4323fe86b7fcdc028e89ba471bbe49b3b3ca77cb84c9ef41543db44d24dc824625ec2da9767894267104c4386071334023b0f72"
  "java|tree-sitter/tree-sitter-java||0.23.5|b71b1749ccab3a30e179274ad482f7d40760296cd50be8a6d86b1f6e4633ca335f3c0bbe8fbf96a6a0ab95faedb271b751aee15bf9f465500f0bc2078218e914"
  "javascript|tree-sitter/tree-sitter-javascript||0.23.1|85bf8850f6f9cd13e907b1536691c4e34ed7d4410460d6d848f211ebe3900ef589616bd4d4e04825b1c9f091eb6daa4dcb8772cff78aedd3b97c8251d2b9ceee"
  "json|tree-sitter/tree-sitter-json||0.24.8|0027c5d85498575bb10cfe739023b27b19e730be1921c52ef141948ad0d003e5318c8fa3a3440af86c53affa236834fa200cbf09790f0b85e5cdc264ad3e2f3e"
  "php|tree-sitter/tree-sitter-php|/php|0.23.12|d505b6b626ec7d18752278587c92f1478641aa366ab88daeb847d1f1551940600363445dc60b9b17afa7c638467a7aec94bc8c67a6f3c11b3ffdd5b54d6741cd"
  "python|tree-sitter/tree-sitter-python||0.23.6|a29213758ebb9b603a1e989c85abe81aae2d69fcaa3dc8d4d373d5e82e1948a201a58981f2100ded46123ad5f7354277db5bbf3718af691d85b51fa81b724db3"
  "ruby|tree-sitter/tree-sitter-ruby||0.23.1|c8e538e138a5f0802f43b1114e39a90b4a3087b05e3e77e2d5d5ea8ccaf9d0226771a7d81b200f15a954960309e812b790e275b3216c3512ed1342eefc55a0f0"
  "rust|tree-sitter/tree-sitter-rust||0.23.2|0b1d65e417738d1199345314013ab886befd5680e4e83c2332fb50d713254f9a9a45c1ebe42bbf38305fd6121cfa755c18ad8e6e9498be306e90e80567b9d64d"
  "typescript|tree-sitter/tree-sitter-typescript|/typescript|0.23.2|f91d49e9af3f714fe3c8c442f6d1abd12a7b8d65b5e13f536e95132127b7a4840e1d7578780e537929be18c9472f87bd2f9ec2e9f7a41cf739231134965aeb02"
  "toml|tree-sitter-grammars/tree-sitter-toml||0.7.0|95807c9b0a8a1055b59fa031278ad425e73c9349e1dad9d810e706ee1c9fee13781359fae6c42c6974b62a6ba6ad3b943c1f6e00cdfd1df3ddc7b3aa1dc8ce18"
  "yaml|tree-sitter-grammars/tree-sitter-yaml||0.7.0|cc3981ae9e41984107dc45e04cd870950bb49ba84f1ac57e968fb6a8ea4e37c34f4ae70a5caacf4b86e14a04ae86d6545aee44840df6b01492bebf07892c3f57"  
)
set(PROTO_PARSERS "")

foreach(PARSER_STRING IN LISTS PARSERS)
  string(REPLACE "|" ";" PARSER "${PARSER_STRING}")
  list(GET PARSER 0 PARSER_FEATURE_NAME)
  list(GET PARSER 1 PARSER_REPO)
  list(GET PARSER 2 PARSER_DIRECTORY)
  list(GET PARSER 3 PARSER_VERSION)
  list(GET PARSER 4 PARSER_SHA)

  set(PARSER_NAME "tree-sitter-${PARSER_FEATURE_NAME}")

  # Check if the feature is enabled
  if(PARSER_FEATURE_NAME IN_LIST FEATURES)
    message(STATUS "Processing parser: ${PARSER_NAME}")
    vcpkg_from_github(
      OUT_SOURCE_PATH PARSER_SOURCE_PATH
      REPO ${PARSER_REPO}
      REF "v${PARSER_VERSION}"
      SHA512 ${PARSER_SHA}
      HEAD_REF master
    )

    list(APPEND PROTO_PARSERS "${PARSER_NAME}|${PARSER_SOURCE_PATH}${PARSER_DIRECTORY}|${PARSER_VERSION}")
  endif()
endforeach()

# currently not supported upstream
if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

configure_file(
  "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
  "${SOURCE_PATH}/lib/CMakeLists.txt"
  @ONLY
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}/lib"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-tree-sitter")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
