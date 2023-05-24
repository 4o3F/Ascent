use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_write_data(
    port_: i64,
    key: *mut wire_uint_8_list,
    value: *mut wire_uint_8_list,
) {
    wire_write_data_impl(port_, key, value)
}

#[no_mangle]
pub extern "C" fn wire_get_data(port_: i64, key: *mut wire_uint_8_list) {
    wire_get_data_impl(port_, key)
}

#[no_mangle]
pub extern "C" fn wire_count_data(port_: i64) {
    wire_count_data_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_register_event_listener(port_: i64) {
    wire_register_event_listener_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_close_event_listener(port_: i64) {
    wire_close_event_listener_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_create_event(
    port_: i64,
    address: *mut wire_uint_8_list,
    payload: *mut wire_uint_8_list,
) {
    wire_create_event_impl(port_, address, payload)
}

#[no_mangle]
pub extern "C" fn wire_as_string__method__Event(port_: i64, that: *mut wire_Event) {
    wire_as_string__method__Event_impl(port_, that)
}

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_box_autoadd_event_0() -> *mut wire_Event {
    support::new_leak_box_ptr(wire_Event::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_uint_8_list_0(len: i32) -> *mut wire_uint_8_list {
    let ans = wire_uint_8_list {
        ptr: support::new_leak_vec_ptr(Default::default(), len),
        len,
    };
    support::new_leak_box_ptr(ans)
}

// Section: related functions

// Section: impl Wire2Api

impl Wire2Api<String> for *mut wire_uint_8_list {
    fn wire2api(self) -> String {
        let vec: Vec<u8> = self.wire2api();
        String::from_utf8_lossy(&vec).into_owned()
    }
}
impl Wire2Api<Event> for *mut wire_Event {
    fn wire2api(self) -> Event {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<Event>::wire2api(*wrap).into()
    }
}
impl Wire2Api<Event> for wire_Event {
    fn wire2api(self) -> Event {
        Event {
            address: self.address.wire2api(),
            payload: self.payload.wire2api(),
        }
    }
}

impl Wire2Api<Vec<u8>> for *mut wire_uint_8_list {
    fn wire2api(self) -> Vec<u8> {
        unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        }
    }
}
// Section: wire structs

#[repr(C)]
#[derive(Clone)]
pub struct wire_Event {
    address: *mut wire_uint_8_list,
    payload: *mut wire_uint_8_list,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_uint_8_list {
    ptr: *mut u8,
    len: i32,
}

// Section: impl NewWithNullPtr

pub trait NewWithNullPtr {
    fn new_with_null_ptr() -> Self;
}

impl<T> NewWithNullPtr for *mut T {
    fn new_with_null_ptr() -> Self {
        std::ptr::null_mut()
    }
}

impl NewWithNullPtr for wire_Event {
    fn new_with_null_ptr() -> Self {
        Self {
            address: core::ptr::null_mut(),
            payload: core::ptr::null_mut(),
        }
    }
}

impl Default for wire_Event {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

// Section: sync execution mode utility

#[no_mangle]
pub extern "C" fn free_WireSyncReturn(ptr: support::WireSyncReturn) {
    unsafe {
        let _ = support::box_from_leak_ptr(ptr);
    };
}
