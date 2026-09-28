use rustler::{Binary, NifTaggedEnum};

/// Mirrors the two shapes produced by `Dumbo.Decoder.fail/2`, minus `source`.
#[derive(NifTaggedEnum)]
pub enum DecodeError {
    /// Offending text and its first byte.
    UnexpectedSequence { position: usize, token: String },

    /// Input ended before a complete value; `position` is `byte_size(source)`.
    UnexpectedEnd { position: usize },
}

/// Reimplementation of `Dumbo.Decoder.numeric_float/2`.
///
/// Returns the decoded value and the offset just past the terminating `;`.
#[rustler::nif]
fn decode_numeric_float(source: Binary) -> Result<(f64, usize), DecodeError> {
    let bytes = source.as_slice();
    let mut index = 0;

    while let Some(&byte) = bytes.get(index) {
        match byte {
            b';' => {
                let token = &bytes[..index];

                return parse_numeric_float(token)
                    .map(|value| (value, index + 1))
                    .ok_or_else(|| DecodeError::UnexpectedSequence {
                        position: 0,
                        token: String::from_utf8_lossy(token).into_owned(),
                    });
            }
            b'0'..=b'9' | b'+' | b'-' | b'.' | b'e' | b'E' => index += 1,
            _ => {
                return Err(DecodeError::UnexpectedSequence {
                    position: index,
                    token: String::from_utf8_lossy(&bytes[index..=index]).into_owned(),
                })
            }
        }
    }

    Err(DecodeError::UnexpectedEnd {
        position: bytes.len(),
    })
}

/// Validates a `;`-terminated token and decodes it to a float.
fn parse_numeric_float(token: &[u8]) -> Option<f64> {
    let token = std::str::from_utf8(token).ok()?;

    if !valid_float(token) {
        return None;
    }

    let token = token.to_ascii_lowercase();
    let (mantissa, exponent) = match token.split_once('e') {
        Some((mantissa, exponent)) => (mantissa, format!("e{exponent}")),
        None => (token.as_str(), String::new()),
    };

    format!("{}{exponent}", normalize_mantissa(mantissa))
        .parse::<f64>()
        .ok()
}

/// Matches `Dumbo.Decoder`'s `^-?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?$`.
fn valid_float(token: &str) -> bool {
    let bytes = token.as_bytes();
    let mut index = 0;

    if bytes.get(index) == Some(&b'-') {
        index += 1;
    }

    let digits_start = index;
    if bytes.get(index) == Some(&b'.') {
        index += 1;
        let digits_start = index;
        skip_digits(bytes, &mut index);

        if index == digits_start {
            return false;
        }
    } else {
        skip_digits(bytes, &mut index);

        if index == digits_start {
            return false;
        }

        if bytes.get(index) == Some(&b'.') {
            index += 1;
            skip_digits(bytes, &mut index);
        }
    }

    if matches!(bytes.get(index), Some(&b'e') | Some(&b'E')) {
        index += 1;

        if matches!(bytes.get(index), Some(&b'+') | Some(&b'-')) {
            index += 1;
        }

        let digits_start = index;
        skip_digits(bytes, &mut index);

        if index == digits_start {
            return false;
        }
    }

    index == bytes.len()
}

fn skip_digits(bytes: &[u8], index: &mut usize) {
    while matches!(bytes.get(*index), Some(b'0'..=b'9')) {
        *index += 1;
    }
}

/// Mirrors `Dumbo.Decoder.normalize_mantissa/1`.
fn normalize_mantissa(mantissa: &str) -> String {
    match mantissa.strip_prefix('-') {
        Some(rest) => format!("-{}", normalize_mantissa(rest)),
        None if mantissa.starts_with('.') => format!("0{mantissa}"),
        None if !mantissa.contains('.') => format!("{mantissa}.0"),
        None if mantissa.ends_with('.') => format!("{mantissa}0"),
        None => mantissa.to_string(),
    }
}

rustler::init!("Elixir.Dumbo.Nif");
