use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use flutter_rust_bridge::support::lazy_static;

use anyhow::{Result};
use flutter_rust_bridge::*;

lazy_static!(
    static ref GLOBAL_DATA: Mutex<HashMap<String, String>> = Mutex::new(HashMap::<String, String>::new());
);


pub fn write_data(key: String, value: String) {
    GLOBAL_DATA.lock().unwrap().insert(key, value);
}

pub fn get_data(key: String) -> String {
    GLOBAL_DATA.lock().unwrap().get(key.as_str()).unwrap().clone()
}

pub fn count_data() -> i32 {
    GLOBAL_DATA.lock().unwrap().keys().len() as i32
}

lazy_static! {
    static ref EVENTS: Arc<Mutex<Vec<StreamSink<Event>>>> = Arc::new(Mutex::new(Vec::new()));
}

#[frb(dart_metadata = ("freezed"))]
#[derive(Clone)]
pub struct Event {
    pub address: String,
    pub payload: String,
}

impl Event {
    pub fn as_string(&self) -> String {
        format!("{}: {}", self.address, self.payload)
    }
}

pub fn register_event_listener(listener: StreamSink<Event>) -> Result<()> {
    println!("Event listener registered!");
    EVENTS.lock().unwrap().push(listener);
    Ok(())
}

pub fn create_event(address: String, payload: String) {
    println!("Event created!");
    let events = EVENTS.lock().unwrap();
    for sink in events.iter() {
        sink.add(Event { address: address.clone(), payload: payload.clone() });
    }
}

pub fn get_listener_count() -> i32 {
    return EVENTS.lock().unwrap().len() as i32
}
