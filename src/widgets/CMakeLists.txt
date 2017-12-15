set(THIS_BIN_NAME maxLibQtWidgets)

project(${THIS_BIN_NAME})
cmake_minimum_required(VERSION 2.8)
cmake_policy(SET CMP0020 NEW)
if(POLICY CMP0043)
  cmake_policy(SET CMP0043 NEW)
endif()
set(CMAKE_CXX_STANDARD 11)
find_package(Qt5Core)
find_package(Qt5Widgets)
add_definitions(-DQT_USE_QSTRINGBUILDER)

set(SRCS
	ExportableTableView.cpp
  ScrollableMessageBox.cpp
  TimerEdit.cpp
  TreeComboBox.cpp
)

set(HDRS
	ExportableTableView.h
  ScrollableMessageBox.h
  TimerEdit.h
  TreeComboBox.h
)

qt5_wrap_cpp(SRCS ${HDRS})

add_library(${THIS_BIN_NAME} ${SRCS} ${HDRS})
qt5_use_modules(${THIS_BIN_NAME} Core Widgets)

set(BUILT_LIBRARIES ${BUILT_LIBRARIES} ${THIS_BIN_NAME} PARENT_SCOPE)
