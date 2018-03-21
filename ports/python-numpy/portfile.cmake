include(vcpkg_common_functions)
set(PYTHON_EXECUTABLE ${CURRENT_INSTALLED_DIR}/python/python.exe)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO numpy/numpy
    REF v1.14.2
    SHA512 65b10462011e033669b700f0688df2e8630a097323fc7d72e71549fdfc2258546fe6f1317e0d51e1a0c9ab86451e0998ccbc7daa9af690652a96034571d5b76b 
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/python-setuptools/python-pip-install.cmake)
python_pip_install(SOURCE_PATH ${SOURCE_PATH})
