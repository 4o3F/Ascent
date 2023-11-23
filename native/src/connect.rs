use std::io::Read;

use tokio::io::{AsyncReadExt, AsyncWriteExt};

const ADB_HEADER_LENGTH: usize = 24;
const SYSTEM_IDENTITY_STRING_HOST: &str = "host::\u{0}";
const A_CNXN: i32 = 0x4e584e43;
const A_OPEN: i32 = 0x4e45504f;
const A_OKAY: i32 = 0x59414b4f;
const A_WRTE: i32 = 0x45545257;
const A_STLS: i32 = 0x534c5453;
// wireless debug introduced in Android 11, so must use TLS
const A_VERSION: i32 = 0x01000001;
const MAX_PAYLOAD: i32 = 1024 * 1024;
const A_STLS_VERSION: i32 = 0x01000000;


struct Message {
    command: u32,
    _arg0: u32,
    _arg1: u32,
    data_length: u32,
    _data_check: u32,
    _magic: u32,
}

impl Message {
    fn parse(buffer: &mut bytebuffer::ByteBuffer) -> Message {
        Message {
            command: buffer.read_u32().unwrap(),
            _arg0: buffer.read_u32().unwrap(),
            _arg1: buffer.read_u32().unwrap(),
            data_length: buffer.read_u32().unwrap(),
            _data_check: buffer.read_u32().unwrap(),
            _magic: buffer.read_u32().unwrap(),
        }
    }
}

fn get_payload_checksum(data: Vec<u8>, offset: i32, length: i32) -> i32 {
    let mut checksum: i32 = 0;
    for i in offset..(offset + length) {
        checksum += (data[i as usize] & 0xFF) as i32;
    }
    checksum
}

fn generate_message(command: i32, arg0: i32, arg1: i32, data: Vec<u8>) -> bytebuffer::ByteBuffer {
    let mut message = bytebuffer::ByteBuffer::new();
    message.resize(ADB_HEADER_LENGTH + data.len());
    message.set_endian(bytebuffer::Endian::LittleEndian);
    message.write_i32(command);
    message.write_i32(arg0);
    message.write_i32(arg1);
    if data.len() != 0 {
        message.write_i32(data.len() as i32);
        message.write_i32(get_payload_checksum(data.clone(), 0, data.len() as i32));
    } else {
        message.write_i32(0);
        message.write_i32(0);
    }
    message.write_i32(!command);
    if data.len() != 0 {
        message.write_bytes(data.as_slice());
    }
    message
}

pub async fn connect(port: String) -> anyhow::Result<String> {
    let host = String::from("127.0.0.1:") + port.as_str();
    let host = host.as_str();
    let mut stream = tokio::net::TcpStream::connect(host).await.unwrap();
    let link: String;
    // Send CNXN first
    {
        let cnxn_message = generate_message(
            A_CNXN,
            A_VERSION,
            MAX_PAYLOAD,
            Vec::from(SYSTEM_IDENTITY_STRING_HOST.as_bytes()),
        );
        stream.write_all(cnxn_message.as_bytes()).await.unwrap();
    }

    // Read STLS command
    {
        let mut message_raw = vec![0u8; ADB_HEADER_LENGTH];
        stream.read_exact(message_raw.as_mut_slice()).await.unwrap();
        let mut header = bytebuffer::ByteBuffer::from_vec(message_raw); // CNXN header
        header.resize(ADB_HEADER_LENGTH);
        header.set_endian(bytebuffer::Endian::LittleEndian);

        let message = Message::parse(&mut header);
        if message.command != A_STLS as u32 {
            panic!("Not STLS command");
        }
        println!("STLS Received")
    }
    // Send STLS packet
    {
        let stls_message = generate_message(A_STLS, A_STLS_VERSION, 0, Vec::new());
        stream.write_all(stls_message.as_bytes()).await.unwrap();
        println!("STLS Sent")
    }

    println!("TLS Handshake begin");
    let cert_path = std::path::Path::new("cert.pem");
    let pkey_path = std::path::Path::new("pkey.pem");
    // Load cert and pkey from file
    let cert_file = std::fs::File::open(cert_path).unwrap();
    let pkey_file = std::fs::File::open(pkey_path).unwrap();
    let x509_raw: Vec<u8> = cert_file.bytes().map(|x| x.unwrap()).collect();
    let x509_raw = x509_raw.as_slice();
    let pkey_raw: Vec<u8> = pkey_file.bytes().map(|x| x.unwrap()).collect();
    let pkey_raw = pkey_raw.as_slice();

    let x509 = Some(boring::x509::X509::from_pem(x509_raw).unwrap());
    let pkey = Some(boring::pkey::PKey::private_key_from_pem(pkey_raw).unwrap());

    let method = boring::ssl::SslMethod::tls();
    let mut connector = boring::ssl::SslConnector::builder(method).unwrap();
    connector.set_verify(boring::ssl::SslVerifyMode::NONE);
    connector.set_certificate(x509.clone().unwrap().as_ref()).unwrap();
    connector.set_private_key(pkey.clone().unwrap().as_ref()).unwrap();
    connector.set_options(boring::ssl::SslOptions::NO_TLSV1);
    connector.set_options(boring::ssl::SslOptions::NO_TLSV1_2);
    connector.set_options(boring::ssl::SslOptions::NO_TLSV1_1);
    connector.set_keylog_callback(move |_, line| {
        println!("{}", line);
    });
    let mut config = connector.build().configure().unwrap();
    //config.set_verify_hostname(false);
    config.set_use_server_name_indication(false);
    //config.set_verify_callback(boring::ssl::SslVerifyMode::PEER, |_, _| true);
    let mut stream = tokio_boring::connect(config, host, stream).await.unwrap();
    println!("TLS Handshake success");
    // Read CNXN
    {
        let mut message_raw = vec![0u8; ADB_HEADER_LENGTH];
        stream.read_exact(message_raw.as_mut_slice()).await.unwrap();
        let mut header = bytebuffer::ByteBuffer::from_vec(message_raw); // CNXN header
        header.resize(ADB_HEADER_LENGTH);
        header.set_endian(bytebuffer::Endian::LittleEndian);

        let message = Message::parse(&mut header);
        println!("CNXN Received");
        let mut data_raw = vec![0u8; message.data_length as usize];
        stream.read_exact(data_raw.as_mut_slice()).await.unwrap();
        let data = String::from_utf8(data_raw).unwrap();
        println!("CNXN data: {}", data)
    }
    // Send OPEN
    {
        let shell_cmd = "shell:logcat | grep -E 'https://(webstatic|hk4e-api|webstatic-sea|hk4e-api-os|api-takumi|api-os-takumi|gs).(mihoyo\\.com|hoyoverse\\.com)' | grep -i 'gacha'\u{0}";
        let open_message = generate_message(A_OPEN, 233, 0, Vec::from(shell_cmd.as_bytes()));
        stream.write_all(open_message.as_bytes()).await.unwrap();
        println!("OPEN Sent");
    }
    // Read OKAY
    {
        let mut message_raw = vec![0u8; ADB_HEADER_LENGTH];
        stream.read_exact(message_raw.as_mut_slice()).await.unwrap();
        let mut header = bytebuffer::ByteBuffer::from_vec(message_raw); // CNXN header
        header.resize(ADB_HEADER_LENGTH);
        header.set_endian(bytebuffer::Endian::LittleEndian);

        let message = Message::parse(&mut header);
        if message.command != A_OKAY as u32 {
            panic!("Not OKAY command");
        }
        println!("OKAY Received");
    }
    // Read WRTE
    {
        let mut message_raw = vec![0u8; ADB_HEADER_LENGTH];
        stream.read_exact(message_raw.as_mut_slice()).await.unwrap();
        let mut header = bytebuffer::ByteBuffer::from_vec(message_raw); // CNXN header
        header.resize(ADB_HEADER_LENGTH);
        header.set_endian(bytebuffer::Endian::LittleEndian);

        let message = Message::parse(&mut header);
        if message.command != A_WRTE as u32 {
            panic!("Not WRTE command");
        }
        println!("WRTE Received");
        let mut data_raw = vec![0u8; message.data_length as usize];
        stream.read_exact(data_raw.as_mut_slice()).await.unwrap();
        link = String::from_utf8(data_raw).unwrap();
        println!("WRTE data: {}", link)
    }
    // Send OKAY
    {
        let okay_message = generate_message(A_OKAY, 233, 0, Vec::new());
        stream.write_all(okay_message.as_bytes()).await.unwrap();
        println!("OKAY Sent");
    }

    Ok(link)
}