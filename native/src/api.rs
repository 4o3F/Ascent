use std::fs;
use anyhow::Result;
use tokio::runtime::Runtime;
use regex::Regex;

use crate::{connect, pair};

pub fn do_pair(port: String, code: String, data_folder: String) -> Result<bool> {
    let rt = Runtime::new().unwrap();
    rt.block_on(async {
        pair::pair(port, code, data_folder).await
    })
}

pub fn do_connect(port: String, data_folder: String) -> Result<String> {
    let rt = Runtime::new().unwrap();
    rt.block_on(async {
        connect::connect(port, data_folder).await
    })
}

pub fn do_filter(file_path: String) -> Result<String> {
    let rt = Runtime::new().unwrap();
    rt.block_on(async {
        let bytes = fs::read(file_path).unwrap();
        let data = String::from_utf8_lossy(bytes.as_slice()).to_string();
        let re = Regex::new(r"https://(webstatic|hk4e-api|webstatic-sea|hk4e-api-os|api-takumi|api-os-takumi|gs).(mihoyo\.com|hoyoverse\.com)(.*)authkey=(.*)").unwrap();
        let matches = re.find(data.as_str()).unwrap();
        Ok(String::from(matches.as_str()))
    })
}