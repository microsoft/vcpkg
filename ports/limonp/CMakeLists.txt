cmake_minimum_required(VERSION 3.20)

project(cppjieba
        LANGUAGES CXX
        VERSION 2.0.0)

####################
# config for cmake #
####################

set(CMAKE_CXX_STANDARD 17 CACHE STRING "C++ Standard")
set(CMAKE_CXX_STANDARD_REQUIRED ON CACHE BOOL "")
set(CMAKE_CXX_EXTENSIONS OFF CACHE BOOL "")

option(BUILD_TESTING "Build Testing" OFF)

set(CONFIGURED_FILES_ROOT ${PROJECT_BINARY_DIR}/configured_files)

################
# dependencies #
################

find_package(RapidJSON REQUIRED)

include(GNUInstallDirs)

##########
# target #
##########

add_library(${PROJECT_NAME} INTERFACE)
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
                           INTERFACE
                               ${RapidJSON_INCLUDE_DIRS}
                               $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/source/include>
                               $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/source/3rd-party>
                               $<BUILD_INTERFACE:${CONFIGURED_FILES_ROOT}/source/include>
                               $<INSTALL_INTERFACE:${CMAKE_INSTALL_FULL_INCLUDEDIR}>
                               $<INSTALL_INTERFACE:${CMAKE_INSTALL_FULL_INCLUDEDIR}/${PROJECT_NAME}/3rd-party>)

##################
# config for lib #
##################

set(DICT_ROOT ${PROJECT_SOURCE_DIR}/dict)
set(JIEBA_DICT_PATH ${DICT_ROOT}/jieba.dict.utf8)
set(HMM_MODEL_PATH ${DICT_ROOT}/hmm_model.utf8)
set(IDF_PATH ${DICT_ROOT}/idf.utf8)
set(STOP_WORDS_PATH ${DICT_ROOT}/stop_words.utf8)
set(USER_DICT_PATH ${DICT_ROOT}/user.dict.utf8)
configure_file(config/config.json.in
               ${CONFIGURED_FILES_ROOT}/config/config.json
               @ONLY)

set(DEFAULT_CONFIG_FILE_PATH ${CONFIGURED_FILES_ROOT}/config/config.json)
configure_file(source/include/cppjieba/config.hpp.in
               ${CONFIGURED_FILES_ROOT}/source/include/cppjieba/config.hpp
               @ONLY)

########
# test #
########

if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)    
    if(BUILD_TESTING)
        include(CTest)
        enable_testing()
        add_subdirectory(test)
    endif()
endif()

###########
# install #
###########

install(TARGETS ${PROJECT_NAME}
        EXPORT ${PROJECT_NAME})

install(EXPORT ${PROJECT_NAME}
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
        NAMESPACE ${PROJECT_NAME}::
        FILE ${PROJECT_NAME}-config.cmake)

install(DIRECTORY source/include/cppjieba/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
        FILES_MATCHING
        PATTERN *.hpp)

install(DIRECTORY source/3rd-party
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME})

set(DICT_ROOT ${CMAKE_INSTALL_FULL_DATADIR}/${PROJECT_NAME}/dict)

install(DIRECTORY "dict/"
        DESTINATION ${DICT_ROOT})

set(DICT_ROOT ${CMAKE_INSTALL_FULL_DATADIR}/${PROJECT_NAME}/dict)
set(JIEBA_DICT_PATH ${DICT_ROOT}/jieba.dict.utf8)
set(HMM_MODEL_PATH ${DICT_ROOT}/hmm_model.utf8)
set(IDF_PATH ${DICT_ROOT}/idf.utf8)
set(STOP_WORDS_PATH ${DICT_ROOT}/stop_words.utf8)
set(USER_DICT_PATH ${DICT_ROOT}/user.dict.utf8)
configure_file(config/config.json.in
               ${CONFIGURED_FILES_ROOT}/config/config.json.for_install
               @ONLY)
install(FILES ${CONFIGURED_FILES_ROOT}/config/config.json.for_install
        DESTINATION ${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME}/config
        RENAME config.json)

set(DEFAULT_CONFIG_FILE_PATH  ${CMAKE_INSTALL_FULL_DATADIR}/${PROJECT_NAME}/config/config.json)
configure_file(source/include/cppjieba/config.hpp.in
               ${CONFIGURED_FILES_ROOT}/source/include/cppjieba/config.hpp.for_install
               @ONLY)
install(FILES ${CONFIGURED_FILES_ROOT}/source/include/cppjieba/config.hpp.for_install
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
        RENAME config.hpp)
