include(vcpkg_common_functions)

set(GSL_LITE_VERSION v0.34.0)

vcpkg_download_distfile(HEADER
    URLS "https://github.com/martinmoene/gsl-lite/raw/${GSL_LITE_VERSION}/include/gsl/gsl-lite.hpp"
    FILENAME "gsl-lite-${GSL_LITE_VERSION}.hpp"
    SHA512 e8463ced48fb4c5aae9bab4e9bdf3deb8a6f17d6f712fd9e3855788f6f43c70ad689738f099735071e2e411b285d9b60312bbfc4f99fc0250bdc2ca0f38493d8
)

vcpkg_download_distfile(LICENSE
    URLS "https://github.com/martinmoene/gsl-lite/raw/${GSL_LITE_VERSION}/LICENSE"
    FILENAME "gsl-lite-LICENSE-${GSL_LITE_VERSION}.txt"
    SHA512 1feff12bda27a5ec52440a7624de54d841faf3e254fff04ab169b7f312e685f4bfe71236de8b8ef759111ae95bdb69e05f2e8318773b0aff4ba24ea9568749bb
)

file(INSTALL ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include RENAME gsl-lite.hpp)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/gsl-lite RENAME copyright)
