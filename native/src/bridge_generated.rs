#![allow(
    non_camel_case_types,
    unused,
    clippy::redundant_closure,
    clippy::useless_conversion,
    clippy::unit_arg,
    clippy::double_parens,
    non_snake_case,
    clippy::too_many_arguments
)]
// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`@ 1.82.4.

use crate::api::*;
use core::panic::UnwindSafe;
use flutter_rust_bridge::rust2dart::IntoIntoDart;
use flutter_rust_bridge::*;
use std::ffi::c_void;
use std::sync::Arc;

// Section: imports

// Section: wire functions

fn wire_do_pair_impl(
    port_: MessagePort,
    port: impl Wire2Api<String> + UnwindSafe,
    code: impl Wire2Api<String> + UnwindSafe,
    data_folder: impl Wire2Api<String> + UnwindSafe,
) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap::<_, _, _, bool, _>(
        WrapInfo {
            debug_name: "do_pair",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_port = port.wire2api();
            let api_code = code.wire2api();
            let api_data_folder = data_folder.wire2api();
            move |task_callback| do_pair(api_port, api_code, api_data_folder)
        },
    )
}
fn wire_do_connect_impl(port_: MessagePort, port: impl Wire2Api<String> + UnwindSafe) {
    FLUTTER_RUST_BRIDGE_HANDLER.wrap::<_, _, _, String, _>(
        WrapInfo {
            debug_name: "do_connect",
            port: Some(port_),
            mode: FfiCallMode::Normal,
        },
        move || {
            let api_port = port.wire2api();
            move |task_callback| do_connect(api_port)
        },
    )
}
// Section: wrapper structs

// Section: static checks

// Section: allocate functions

// Section: related functions

// Section: impl Wire2Api

pub trait Wire2Api<T> {
    fn wire2api(self) -> T;
}

impl<T, S> Wire2Api<Option<T>> for *mut S
where
    *mut S: Wire2Api<T>,
{
    fn wire2api(self) -> Option<T> {
        (!self.is_null()).then(|| self.wire2api())
    }
}

impl Wire2Api<u8> for u8 {
    fn wire2api(self) -> u8 {
        self
    }
}

// Section: impl IntoDart

// Section: executor

support::lazy_static! {
    pub static ref FLUTTER_RUST_BRIDGE_HANDLER: support::DefaultHandler = Default::default();
}

#[cfg(not(target_family = "wasm"))]
#[path = "bridge_generated.io.rs"]
mod io;
#[cfg(not(target_family = "wasm"))]
pub use io::*;
