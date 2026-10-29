vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tucher/JsonFusion
    REF "v${VERSION}"
    SHA512 7b131bb92b067378eef81b454303393b83019e0a04bc06c91ab0c9646d7d5bb0b6eaef49a7f77d2f1886107b58ccb581de5eac5a81da3fc1801903dd38cdaf57
    HEAD_REF master
)

# Header-only. Install everything except the experimental 3party directory
# (only used with JSONFUSION_FP_BACKEND=1).
file(INSTALL "${SOURCE_PATH}/include/JsonFusion"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include"
     PATTERN "3party" EXCLUDE)

# The optional backend headers guard their dependency with "#if __has_include(<...>)"
# upstream. Per the vcpkg maintainer guide, a port's dependencies must be controlled
# by its features, not by whatever headers happen to be on the include path, so we
# rewrite those guards to a fixed value rather than leaving them ambient.

# rapidyaml is not provided by this port: disable the YAML backend outright.
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/JsonFusion/yaml.hpp"
    "#if __has_include(<rapidyaml.hpp>)"
    "#if 0 // rapidyaml is not provided by the vcpkg port")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/JsonFusion/yaml.hpp"
    "#endif // __has_include(<rapidyaml.hpp>)" "#endif")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/JsonFusion/yyjson.hpp"
    "#endif // __has_include(<yyjson.h>)" "#endif")

# yyjson backend: enabled strictly by the "yyjson" feature.
if("yyjson" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/JsonFusion/yyjson.hpp"
        "#if __has_include(<yyjson.h>)"
        "#if 1 // provided by the 'yyjson' feature")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/JsonFusion/yyjson.hpp"
        "#if __has_include(<yyjson.h>)"
        "#if 0 // enable the 'yyjson' feature to use this backend")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
