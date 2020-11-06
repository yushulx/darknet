include(${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)
include(${CMAKE_ROOT}/Modules/SelectLibraryConfigurations.cmake)

if(NOT Dbr_INCLUDE_DIR)
  find_path(Dbr_INCLUDE_DIR NAMES DynamsoftBarcodeReader.h PATHS ${Dbr_DIR} PATH_SUFFIXES include)
endif()

if(NOT Dbr_LIBRARY)
  find_library(Dbr_LIBRARY_RELEASE NAMES DBRx64 PATHS ${Dbr_DIR} PATH_SUFFIXES lib)
  select_library_configurations(Dbr)
endif()

find_package_handle_standard_args(Dbr DEFAULT_MSG Dbr_INCLUDE_DIR)
mark_as_advanced(Dbr_INCLUDE_DIR)

set(Dbr_DLL_DIR ${Dbr_INCLUDE_DIR})
list(TRANSFORM Dbr_DLL_DIR APPEND "/../bin")

find_file(Dbr_LIBRARY_RELEASE_DLL NAMES DynamsoftBarcodeReaderx64.dll PATHS ${Dbr_DLL_DIR})

if( EXISTS "${Dbr_LIBRARY_RELEASE_DLL}" )
    add_library( DynamsoftBarcodeReader      SHARED IMPORTED )
    set_target_properties( DynamsoftBarcodeReader PROPERTIES
      IMPORTED_LOCATION_RELEASE         "${Dbr_LIBRARY_RELEASE_DLL}"
      IMPORTED_IMPLIB                   "${Dbr_LIBRARY_RELEASE}"
      INTERFACE_INCLUDE_DIRECTORIES     "${Dbr_INCLUDE_DIR}"
      IMPORTED_CONFIGURATIONS           Release
      IMPORTED_LINK_INTERFACE_LANGUAGES "C" )
endif()