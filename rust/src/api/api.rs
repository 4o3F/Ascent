use std::{env, fs};

use android_logger::Config;
use anyhow::Result;
use log::{debug, LevelFilter};
use regex::Regex;
use tokio::runtime::Runtime;

use crate::{connect, pair};

pub fn do_pair(port: String, code: String, data_folder: String) -> Result<bool> {
    debug!("Do pair native called");
    let rt = Runtime::new().unwrap();
    rt.block_on(async {
        pair::pair(port, code, data_folder).await
    })
}

pub fn do_connect(port: String, data_folder: String) -> Result<String> {
    debug!("Do connect native called");
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
        let re = Regex::new(r"https://(webstatic|hk4e-api|webstatic-sea|hk4e-api-os|api-takumi|api-os-takumi|gs|public-operation-hk4e).(mihoyo\.com|hoyoverse\.com).*authkey=.*\s*.*game_biz.*(plat_type|#/log)").unwrap();
        let matches = re.find(data.as_str()).unwrap();
        let data = String::from(matches.as_str());
        let mut front_half: String = String::new();
        let mut back_half: String = String::new();

        for (_, c) in data.chars().enumerate() {
            if !c.is_ascii_alphanumeric() && !c.is_ascii_punctuation() {
                break;
            }
            front_half.push(c);
        }

        for (_, c) in data.chars().rev().enumerate() {
            if !c.is_ascii_alphanumeric() && !c.is_ascii_punctuation() {
                break;
            }
            back_half.push(c);
        }
        //reverse back_half
        back_half = back_half.chars().rev().collect();

        let result = front_half + back_half.as_str();
        Ok(result)
    })
}

pub fn init_logger() {
    env::set_var("RUST_BACKTRACE", "1");
    if cfg!(debug_assertions) {
        android_logger::init_once(
            Config::default().with_max_level(LevelFilter::Trace).with_tag("flutter_native"),
        );
    } else {
        android_logger::init_once(
            Config::default().with_max_level(LevelFilter::Error).with_tag("flutter_native"),
        );
    }
}