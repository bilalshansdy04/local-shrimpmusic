//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import audiotags
import file_picker_darwin
import screen_retriever_macos
import shared_preferences_foundation
import window_manager

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AudiotagsPlugin.register(with: registry.registrar(forPlugin: "AudiotagsPlugin"))
  FilePickerPlugin.register(with: registry.registrar(forPlugin: "FilePickerPlugin"))
  ScreenRetrieverMacosPlugin.register(with: registry.registrar(forPlugin: "ScreenRetrieverMacosPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  WindowManagerPlugin.register(with: registry.registrar(forPlugin: "WindowManagerPlugin"))
}
