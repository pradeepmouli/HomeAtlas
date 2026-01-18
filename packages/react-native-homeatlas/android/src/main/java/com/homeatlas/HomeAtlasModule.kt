package com.homeatlas

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

/**
 * Android stub module for react-native-homeatlas
 * 
 * HomeKit is iOS-only, so this module throws a platform unsupported error
 * when any method is called on Android.
 */
class HomeAtlasModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("HomeAtlas")

    // All methods throw platform unsupported error
    AsyncFunction("initialize") {
      throw PlatformUnavailableException()
    }

    Function("isReady") {
      throw PlatformUnavailableException()
    }

    Function("getState") {
      throw PlatformUnavailableException()
    }

    AsyncFunction("getHomes") {
      throw PlatformUnavailableException()
    }

    AsyncFunction("getHome") { _: String ->
      throw PlatformUnavailableException()
    }

    AsyncFunction("getAllAccessories") {
      throw PlatformUnavailableException()
    }

    AsyncFunction("getAccessory") { _: String ->
      throw PlatformUnavailableException()
    }

    AsyncFunction("findAccessoryByName") { _: String ->
      throw PlatformUnavailableException()
    }

    AsyncFunction("refresh") {
      throw PlatformUnavailableException()
    }

    AsyncFunction("readCharacteristic") { _: String, _: String, _: String ->
      throw PlatformUnavailableException()
    }

    AsyncFunction("writeCharacteristic") { _: String, _: String, _: String, _: Any, _: String? ->
      throw PlatformUnavailableException()
    }

    AsyncFunction("identify") { _: String ->
      throw PlatformUnavailableException()
    }

    Function("subscribe") { _: String, _: String, _: String? ->
      throw PlatformUnavailableException()
    }

    Function("unsubscribe") { _: String ->
      throw PlatformUnavailableException()
    }

    Function("unsubscribeAll") {
      throw PlatformUnavailableException()
    }

    Function("setDebugLoggingEnabled") { _: Boolean ->
      throw PlatformUnavailableException()
    }
  }

  private class PlatformUnavailableException : Exception(
    "HomeKit is only available on iOS. Android is not supported."
  )
}
