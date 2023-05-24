// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`@ 1.75.3.
// ignore_for_file: non_constant_identifier_names, unused_element, duplicate_ignore, directives_ordering, curly_braces_in_flow_control_structures, unnecessary_lambdas, slash_for_doc_comments, prefer_const_literals_to_create_immutables, implicit_dynamic_list_literal, duplicate_import, unused_import, unnecessary_import, prefer_single_quotes, prefer_const_constructors, use_super_parameters, always_use_package_imports, annotate_overrides, invalid_use_of_protected_member, constant_identifier_names, invalid_use_of_internal_member, prefer_is_empty, unnecessary_const

import "bridge_definitions.dart";
import 'dart:convert';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:uuid/uuid.dart';

import 'dart:convert';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:uuid/uuid.dart';

import 'dart:ffi' as ffi;

class NativeImpl implements Native {
  final NativePlatform _platform;
  factory NativeImpl(ExternalLibrary dylib) =>
      NativeImpl.raw(NativePlatform(dylib));

  /// Only valid on web/WASM platforms.
  factory NativeImpl.wasm(FutureOr<WasmModule> module) =>
      NativeImpl(module as ExternalLibrary);
  NativeImpl.raw(this._platform);
  Future<void> writeData(
      {required String key, required String value, dynamic hint}) {
    var arg0 = _platform.api2wire_String(key);
    var arg1 = _platform.api2wire_String(value);
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) => _platform.inner.wire_write_data(port_, arg0, arg1),
      parseSuccessData: _wire2api_unit,
      constMeta: kWriteDataConstMeta,
      argValues: [key, value],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kWriteDataConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "write_data",
        argNames: ["key", "value"],
      );

  Future<String> getData({required String key, dynamic hint}) {
    var arg0 = _platform.api2wire_String(key);
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) => _platform.inner.wire_get_data(port_, arg0),
      parseSuccessData: _wire2api_String,
      constMeta: kGetDataConstMeta,
      argValues: [key],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kGetDataConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "get_data",
        argNames: ["key"],
      );

  Future<int> countData({dynamic hint}) {
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) => _platform.inner.wire_count_data(port_),
      parseSuccessData: _wire2api_i32,
      constMeta: kCountDataConstMeta,
      argValues: [],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kCountDataConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "count_data",
        argNames: [],
      );

  Stream<Event> registerEventListener({dynamic hint}) {
    return _platform.executeStream(FlutterRustBridgeTask(
      callFfi: (port_) => _platform.inner.wire_register_event_listener(port_),
      parseSuccessData: (d) => _wire2api_event(d),
      constMeta: kRegisterEventListenerConstMeta,
      argValues: [],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kRegisterEventListenerConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "register_event_listener",
        argNames: [],
      );

  Future<void> createEvent(
      {required String address, required String payload, dynamic hint}) {
    var arg0 = _platform.api2wire_String(address);
    var arg1 = _platform.api2wire_String(payload);
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) => _platform.inner.wire_create_event(port_, arg0, arg1),
      parseSuccessData: _wire2api_unit,
      constMeta: kCreateEventConstMeta,
      argValues: [address, payload],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kCreateEventConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "create_event",
        argNames: ["address", "payload"],
      );

  Future<int> getListenerCount({dynamic hint}) {
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) => _platform.inner.wire_get_listener_count(port_),
      parseSuccessData: _wire2api_i32,
      constMeta: kGetListenerCountConstMeta,
      argValues: [],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kGetListenerCountConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "get_listener_count",
        argNames: [],
      );

  Future<String> asStringMethodEvent({required Event that, dynamic hint}) {
    var arg0 = _platform.api2wire_box_autoadd_event(that);
    return _platform.executeNormal(FlutterRustBridgeTask(
      callFfi: (port_) =>
          _platform.inner.wire_as_string__method__Event(port_, arg0),
      parseSuccessData: _wire2api_String,
      constMeta: kAsStringMethodEventConstMeta,
      argValues: [that],
      hint: hint,
    ));
  }

  FlutterRustBridgeTaskConstMeta get kAsStringMethodEventConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "as_string__method__Event",
        argNames: ["that"],
      );

  void dispose() {
    _platform.dispose();
  }
// Section: wire2api

  String _wire2api_String(dynamic raw) {
    return raw as String;
  }

  Event _wire2api_event(dynamic raw) {
    final arr = raw as List<dynamic>;
    if (arr.length != 2)
      throw Exception('unexpected arr length: expect 2 but see ${arr.length}');
    return Event(
      bridge: this,
      address: _wire2api_String(arr[0]),
      payload: _wire2api_String(arr[1]),
    );
  }

  int _wire2api_i32(dynamic raw) {
    return raw as int;
  }

  int _wire2api_u8(dynamic raw) {
    return raw as int;
  }

  Uint8List _wire2api_uint_8_list(dynamic raw) {
    return raw as Uint8List;
  }

  void _wire2api_unit(dynamic raw) {
    return;
  }
}

// Section: api2wire

@protected
int api2wire_u8(int raw) {
  return raw;
}

// Section: finalizer

class NativePlatform extends FlutterRustBridgeBase<NativeWire> {
  NativePlatform(ffi.DynamicLibrary dylib) : super(NativeWire(dylib));

// Section: api2wire

  @protected
  ffi.Pointer<wire_uint_8_list> api2wire_String(String raw) {
    return api2wire_uint_8_list(utf8.encoder.convert(raw));
  }

  @protected
  ffi.Pointer<wire_Event> api2wire_box_autoadd_event(Event raw) {
    final ptr = inner.new_box_autoadd_event_0();
    _api_fill_to_wire_event(raw, ptr.ref);
    return ptr;
  }

  @protected
  ffi.Pointer<wire_uint_8_list> api2wire_uint_8_list(Uint8List raw) {
    final ans = inner.new_uint_8_list_0(raw.length);
    ans.ref.ptr.asTypedList(raw.length).setAll(0, raw);
    return ans;
  }
// Section: finalizer

// Section: api_fill_to_wire

  void _api_fill_to_wire_box_autoadd_event(
      Event apiObj, ffi.Pointer<wire_Event> wireObj) {
    _api_fill_to_wire_event(apiObj, wireObj.ref);
  }

  void _api_fill_to_wire_event(Event apiObj, wire_Event wireObj) {
    wireObj.address = api2wire_String(apiObj.address);
    wireObj.payload = api2wire_String(apiObj.payload);
  }
}

// ignore_for_file: camel_case_types, non_constant_identifier_names, avoid_positional_boolean_parameters, annotate_overrides, constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint

/// generated by flutter_rust_bridge
class NativeWire implements FlutterRustBridgeWireBase {
  @internal
  late final dartApi = DartApiDl(init_frb_dart_api_dl);

  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  NativeWire(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  NativeWire.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  void store_dart_post_cobject(
    DartPostCObjectFnType ptr,
  ) {
    return _store_dart_post_cobject(
      ptr,
    );
  }

  late final _store_dart_post_cobjectPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(DartPostCObjectFnType)>>(
          'store_dart_post_cobject');
  late final _store_dart_post_cobject = _store_dart_post_cobjectPtr
      .asFunction<void Function(DartPostCObjectFnType)>();

  Object get_dart_object(
    int ptr,
  ) {
    return _get_dart_object(
      ptr,
    );
  }

  late final _get_dart_objectPtr =
      _lookup<ffi.NativeFunction<ffi.Handle Function(ffi.UintPtr)>>(
          'get_dart_object');
  late final _get_dart_object =
      _get_dart_objectPtr.asFunction<Object Function(int)>();

  void drop_dart_object(
    int ptr,
  ) {
    return _drop_dart_object(
      ptr,
    );
  }

  late final _drop_dart_objectPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.UintPtr)>>(
          'drop_dart_object');
  late final _drop_dart_object =
      _drop_dart_objectPtr.asFunction<void Function(int)>();

  int new_dart_opaque(
    Object handle,
  ) {
    return _new_dart_opaque(
      handle,
    );
  }

  late final _new_dart_opaquePtr =
      _lookup<ffi.NativeFunction<ffi.UintPtr Function(ffi.Handle)>>(
          'new_dart_opaque');
  late final _new_dart_opaque =
      _new_dart_opaquePtr.asFunction<int Function(Object)>();

  int init_frb_dart_api_dl(
    ffi.Pointer<ffi.Void> obj,
  ) {
    return _init_frb_dart_api_dl(
      obj,
    );
  }

  late final _init_frb_dart_api_dlPtr =
      _lookup<ffi.NativeFunction<ffi.IntPtr Function(ffi.Pointer<ffi.Void>)>>(
          'init_frb_dart_api_dl');
  late final _init_frb_dart_api_dl = _init_frb_dart_api_dlPtr
      .asFunction<int Function(ffi.Pointer<ffi.Void>)>();

  void wire_write_data(
    int port_,
    ffi.Pointer<wire_uint_8_list> key,
    ffi.Pointer<wire_uint_8_list> value,
  ) {
    return _wire_write_data(
      port_,
      key,
      value,
    );
  }

  late final _wire_write_dataPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int64, ffi.Pointer<wire_uint_8_list>,
              ffi.Pointer<wire_uint_8_list>)>>('wire_write_data');
  late final _wire_write_data = _wire_write_dataPtr.asFunction<
      void Function(
          int, ffi.Pointer<wire_uint_8_list>, ffi.Pointer<wire_uint_8_list>)>();

  void wire_get_data(
    int port_,
    ffi.Pointer<wire_uint_8_list> key,
  ) {
    return _wire_get_data(
      port_,
      key,
    );
  }

  late final _wire_get_dataPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Int64, ffi.Pointer<wire_uint_8_list>)>>('wire_get_data');
  late final _wire_get_data = _wire_get_dataPtr
      .asFunction<void Function(int, ffi.Pointer<wire_uint_8_list>)>();

  void wire_count_data(
    int port_,
  ) {
    return _wire_count_data(
      port_,
    );
  }

  late final _wire_count_dataPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64)>>(
          'wire_count_data');
  late final _wire_count_data =
      _wire_count_dataPtr.asFunction<void Function(int)>();

  void wire_register_event_listener(
    int port_,
  ) {
    return _wire_register_event_listener(
      port_,
    );
  }

  late final _wire_register_event_listenerPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64)>>(
          'wire_register_event_listener');
  late final _wire_register_event_listener =
      _wire_register_event_listenerPtr.asFunction<void Function(int)>();

  void wire_create_event(
    int port_,
    ffi.Pointer<wire_uint_8_list> address,
    ffi.Pointer<wire_uint_8_list> payload,
  ) {
    return _wire_create_event(
      port_,
      address,
      payload,
    );
  }

  late final _wire_create_eventPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int64, ffi.Pointer<wire_uint_8_list>,
              ffi.Pointer<wire_uint_8_list>)>>('wire_create_event');
  late final _wire_create_event = _wire_create_eventPtr.asFunction<
      void Function(
          int, ffi.Pointer<wire_uint_8_list>, ffi.Pointer<wire_uint_8_list>)>();

  void wire_get_listener_count(
    int port_,
  ) {
    return _wire_get_listener_count(
      port_,
    );
  }

  late final _wire_get_listener_countPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64)>>(
          'wire_get_listener_count');
  late final _wire_get_listener_count =
      _wire_get_listener_countPtr.asFunction<void Function(int)>();

  void wire_as_string__method__Event(
    int port_,
    ffi.Pointer<wire_Event> that,
  ) {
    return _wire_as_string__method__Event(
      port_,
      that,
    );
  }

  late final _wire_as_string__method__EventPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int64,
              ffi.Pointer<wire_Event>)>>('wire_as_string__method__Event');
  late final _wire_as_string__method__Event = _wire_as_string__method__EventPtr
      .asFunction<void Function(int, ffi.Pointer<wire_Event>)>();

  ffi.Pointer<wire_Event> new_box_autoadd_event_0() {
    return _new_box_autoadd_event_0();
  }

  late final _new_box_autoadd_event_0Ptr =
      _lookup<ffi.NativeFunction<ffi.Pointer<wire_Event> Function()>>(
          'new_box_autoadd_event_0');
  late final _new_box_autoadd_event_0 = _new_box_autoadd_event_0Ptr
      .asFunction<ffi.Pointer<wire_Event> Function()>();

  ffi.Pointer<wire_uint_8_list> new_uint_8_list_0(
    int len,
  ) {
    return _new_uint_8_list_0(
      len,
    );
  }

  late final _new_uint_8_list_0Ptr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<wire_uint_8_list> Function(ffi.Int32)>>(
      'new_uint_8_list_0');
  late final _new_uint_8_list_0 = _new_uint_8_list_0Ptr
      .asFunction<ffi.Pointer<wire_uint_8_list> Function(int)>();

  void free_WireSyncReturn(
    WireSyncReturn ptr,
  ) {
    return _free_WireSyncReturn(
      ptr,
    );
  }

  late final _free_WireSyncReturnPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(WireSyncReturn)>>(
          'free_WireSyncReturn');
  late final _free_WireSyncReturn =
      _free_WireSyncReturnPtr.asFunction<void Function(WireSyncReturn)>();
}

final class _Dart_Handle extends ffi.Opaque {}

final class wire_uint_8_list extends ffi.Struct {
  external ffi.Pointer<ffi.Uint8> ptr;

  @ffi.Int32()
  external int len;
}

final class wire_Event extends ffi.Struct {
  external ffi.Pointer<wire_uint_8_list> address;

  external ffi.Pointer<wire_uint_8_list> payload;
}

typedef DartPostCObjectFnType = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Bool Function(DartPort port_id, ffi.Pointer<ffi.Void> message)>>;
typedef DartPort = ffi.Int64;
