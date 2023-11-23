use anyhow::Result;
use tokio::runtime::Runtime;

use crate::{connect, pair};

pub fn do_pair(port: String, code: String, data_folder: String) -> Result<bool> {
    let rt = Runtime::new().unwrap();
    rt.block_on(async {
        pair::pair(port, code, data_folder.clone()).await
    })
}

pub fn do_connect(port: String) -> Result<String> {
    let rt = Runtime::new().unwrap();
    rt.block_on(async {
        connect::connect(port).await
    })
}