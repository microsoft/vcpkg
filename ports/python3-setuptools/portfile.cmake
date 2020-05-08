## bug debug version python

# https://github.com/marshmallow-code/marshmallow/issues/1027
# https://stackoverflow.com/questions/53978542/how-to-use-collections-abc-from-both-python-3-8-and-python-2-7

# debug\python3\lib\site-packages\pip\_vendor\html5lib\_trie\_base.py:3: DeprecationWarning: Using or importing the ABCs from 'collections' instead of from 'collections.abc' is deprecated, and in 3.8 it will stop working

# edit and replace collections to collections.abc
# https://github.com/python/cpython/commit/c66f9f8d3909f588c251957d499599a1680e2320

# pip install --upgrade pip -vvv
# python_d.exe -mpip install --trusted-host=pypi.python.org --index-url=http://pypi.python.org --trusted-host=files.pythonhosted.org pip --force

# python_d.exe -mpip install --force requests
# Successfully installed certifi-2019.3.9 chardet-3.0.4 idna-2.8 requests-2.22.0 urllib3-1.25.3

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR ${PYTHON3} PATH)
vcpkg_add_to_path(PREPEND ${PYTHON3_DIR})
set(PYTHON_EXECUTABLE ${PYTHON3})

#set(PYTHON_DEBUG_EXECUTABLE ${CURRENT_INSTALLED_DIR}/debug/python3/python_d.exe)

# install default pip
message(STATUS "Installing built-in pip wheel..")
#vcpkg_execute_required_process(
#    COMMAND ${PYTHON_DEBUG_EXECUTABLE} -m ensurepip --default-pip
#    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
#    LOGNAME install-pip-${TARGET_TRIPLET}-dbg
#)
vcpkg_execute_required_process(
    COMMAND ${PYTHON_EXECUTABLE} -m ensurepip --default-pip
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME install-pip-${TARGET_TRIPLET}-rel
)
#vcpkg_apply_patches(
#    SOURCE_PATH ${PYTHON3_DIR}/Lib/site-packages/pip
#    PATCHES ${CMAKE_CURRENT_LIST_DIR}/fix-pip-install.patch
#)
message(STATUS "Installing built-in pip wheel.. done")

# upgrade pip: need 9.0.2 to workaround https://github.com/pypa/pip/issues/373
message(STATUS "Upgrading pip..")
#vcpkg_execute_required_process(
#    COMMAND ${PYTHON_DEBUG_EXECUTABLE} -m pip install --upgrade pip
#    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
#    LOGNAME upgrade-pip-${TARGET_TRIPLET}-dbg
#)
vcpkg_execute_required_process(
    COMMAND ${PYTHON_EXECUTABLE} -m pip install --upgrade pip
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME upgrade-pip-${TARGET_TRIPLET}-rel
)
#vcpkg_apply_patches(
#    SOURCE_PATH ${PYTHON3_DIR}/Lib/site-packages/pip
#    PATCHES ${CMAKE_CURRENT_LIST_DIR}/fix-pip-install.patch
#)
message(STATUS "Upgrading pip.. done")

file(COPY ${CMAKE_CURRENT_LIST_DIR}/distutils-rel.cfg.in DESTINATION ${SCRIPTS}/templates)#${VCPKG_ROOT_DIR}

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
