include(vcpkg_common_functions)

set(GSL_LITE_VERSION v0.28.0)

vcpkg_download_distfile(HEADER
    URLS "https://github.com/martinmoene/gsl-lite/releases/download/${GSL_LITE_VERSION}/gsl-lite.hpp"
    FILENAME "gsl-lite-${GSL_LITE_VERSION}.hpp"
    SHA512 2c9705c9d17b5acbd7eb2f4a93a6fd07f9ce31e81a41d2ca6a961ed484d771742d7960305bbb20b82d810013c7473c9afa58c71468a15466e00c879449d38ba5
)

vcpkg_download_distfile(LICENSE
    URLS "https://github.com/martinmoene/gsl-lite/raw/${GSL_LITE_VERSION}/LICENSE"
    FILENAME "gsl-lite-LICENSE-${GSL_LITE_VERSION}.txt"
    SHA512 1feff12bda27a5ec52440a7624de54d841faf3e254fff04ab169b7f312e685f4bfe71236de8b8ef759111ae95bdb69e05f2e8318773b0aff4ba24ea9568749bb
)

file(INSTALL ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include RENAME gsl-lite.hpp)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/gsl-lite RENAME copyright)
