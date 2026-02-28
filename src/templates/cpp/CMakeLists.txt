cmake_minimum_required(VERSION 3.20)
project(cpp LANGUAGES NONE)

include("${PROJECT_ROOT}/.build/zip.cmake")

templates_add_payload_zip(TEMPLATE_SOURCE_DIR  "console/project")
templates_add_payload_zip(TEMPLATE_SOURCE_DIR  "console/linux/project")
templates_add_payload_zip(TEMPLATE_SOURCE_DIR  "module/project")
templates_add_payload_zip(TEMPLATE_SOURCE_DIR  "module/linux/project")
templates_add_payload_zip(TEMPLATE_SOURCE_DIR  "library/project")
templates_add_payload_zip(TEMPLATE_SOURCE_DIR  "library/linux/project")
templates_add_payload_zip(TEMPLATE_SOURCE_DIR  "gui/win32/project")
templates_add_payload_zip(TEMPLATE_SOURCE_DIR  "gui/qt/project")
templates_add_payload_zip(TEMPLATE_SOURCE_DIR  "gui/gtk/project")
