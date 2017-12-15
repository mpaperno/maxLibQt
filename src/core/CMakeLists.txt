set(THIS_BIN_NAME maxLibQtCore)

project(${THIS_BIN_NAME})
cmake_minimum_required(VERSION 2.8)
cmake_policy(SET CMP0020 NEW)
if(POLICY CMP0043)
  cmake_policy(SET CMP0043 NEW)
endif()
set(CMAKE_CXX_STANDARD 11)
find_package(Qt5Core)
add_definitions(-DQT_USE_QSTRINGBUILDER)

set(SRCS
  AppDebugMessageHandler.cpp
)

set(HDRS
  AppDebugMessageHandler.h
)

qt5_wrap_cpp(SRCS ${HDRS})

add_library(${THIS_BIN_NAME} ${SRCS} ${HDRS})
qt5_use_modules(${THIS_BIN_NAME} Core)

set(BUILT_LIBRARIES ${BUILT_LIBRARIES} ${THIS_BIN_NAME} PARENT_SCOPE)
