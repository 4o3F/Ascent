use std::collections::HashMap;
use std::sync::Mutex;
use flutter_rust_bridge::support::lazy_static;
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