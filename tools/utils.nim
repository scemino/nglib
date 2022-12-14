# Written by Leonardo Mariscal <leo@ldmd.mx>, 2019

const srcHeader* = """
# Written by Leonardo Mariscal <leo@ldmd.mx>, 2019

## ImGUI Bindings
## ====
## WARNING: This is a generated file. Do not edit
## Any edits will be overwritten by the generator.
##
## The aim is to achieve as much compatibility with C as possible.
## Optional helper functions have been created as a submodule
## ``imgui/imgui_helpers`` to better bind this library to Nim.
##
## You can check the original documentation `here <https://github.com/ocornut/imgui/blob/master/imgui.cpp>`_.
##
## Source language of ImGui is C++, since Nim is able to compile both to C
## and C++ you can select which compile target you wish to use. Note that to use
## the C backend you must supply a `cimgui <https://github.com/cimgui/cimgui>`_
## dynamic library file.
##
## HACK: If you are targeting Windows, be sure to compile the cimgui dll with
## visual studio and not with mingw.

import strutils

proc currentSourceDir(): string {.compileTime.} =
  result = currentSourcePath().replace("\\", "/")
  result = result[0 ..< result.rfind("/")]

{.passC: "-I" & currentSourceDir() & "../private" & " -I" & currentSourceDir() & "../private/cimgui" & " -DIMGUI_DISABLE_OBSOLETE_FUNCTIONS=1".}
when defined(linux):
  {.passL: "-Xlinker -rpath .".}

when not defined(cpp) or defined(cimguiDLL):
  when defined(windows):
    const imgui_dll* = "cimgui.dll"
  elif defined(macosx):
    const imgui_dll* = "cimgui.dylib"
  else:
    const imgui_dll* = "cimgui.so"
  {.passC: "-DCIMGUI_DEFINE_ENUMS_AND_STRUCTS".}
  {.pragma: imgui_header, header: "cimgui.h".}
else:
  {.compile: "private/cimgui/cimgui.cpp",
    compile: "private/cimgui/imgui/imgui.cpp",
    compile: "private/cimgui/imgui/imgui_draw.cpp",
    compile: "private/cimgui/imgui/imgui_tables.cpp",
    compile: "private/cimgui/imgui/imgui_widgets.cpp",
    compile: "private/cimgui/imgui/imgui_demo.cpp".}
  {.pragma: imgui_header, header: currentSourceDir() & "/private/ncimgui.h".}
"""

const notDefinedStructs* = """
  ImVector*[T] = object # Should I importc a generic?
    size* {.importc: "Size".}: int32
    capacity* {.importc: "Capacity".}: int32
    data* {.importc: "Data".}: UncheckedArray[T]
  ImGuiStyleModBackup* {.union.} = object
    backup_int* {.importc: "BackupInt".}: int32 # Breaking naming convetion to denote "low level"
    backup_float* {.importc: "BackupFloat".}: float32
  ImGuiStyleMod* {.importc: "ImGuiStyleMod", imgui_header.} = object
    varIdx* {.importc: "VarIdx".}: ImGuiStyleVar
    backup*: ImGuiStyleModBackup
  ImGuiStoragePairData* {.union.} = object
    val_i* {.importc: "val_i".}: int32 # Breaking naming convetion to denote "low level"
    val_f* {.importc: "val_f".}: float32
    val_p* {.importc: "val_p".}: pointer
  ImGuiStoragePair* {.importc: "ImGuiStoragePair", imgui_header.} = object
    key* {.importc: "key".}: ImGuiID
    data*: ImGuiStoragePairData
  ImPairData* {.union.} = object
    val_i* {.importc: "val_i".}: int32 # Breaking naming convetion to denote "low level"
    val_f* {.importc: "val_f".}: float32
    val_p* {.importc: "val_p".}: pointer
  ImPair* {.importc: "Pair", imgui_header.} = object
    key* {.importc: "key".}: ImGuiID
    data*: ImPairData

  # Undefined data types in cimgui

  ImDrawListPtr* = object
  ImChunkStream* = ptr object
  ImPool* = object
  ImSpanAllocator* = object # A little lost here. It is referenced in imgui_internal.h
  ImSpan* = object # ^^
  ImVectorImGuiColumns* {.importc: "ImVector_ImGuiColumns".} = object

  #
"""

const preProcs* = """
# Procs
{.push warning[HoleEnumConv]: off.}
when not defined(cpp) or defined(cimguiDLL):
  {.push dynlib: imgui_dll, cdecl, discardable.}
else:
  {.push nodecl, discardable.}
"""

const postProcs* = """
{.pop.} # push dynlib / nodecl, etc...
{.pop.} # push warning[HoleEnumConv]: off
"""

let reservedWordsDictionary* = [
"end", "type", "out", "in", "ptr", "ref"
]

let blackListProc* = [ "" ]
