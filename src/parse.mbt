///|
/// Parse a SemVer string.
pub fn parse(input : String) -> SemVer raise SemVerError {
  let (core, build_part) = split_once(input, "+")
  let (base, pre_part) = split_once(core, "-")
  let (major, minor, patch) = parse_core(base)
  let pre = match pre_part {
    None => []
    Some(value) => parse_prerelease(value)
  }
  let build = match build_part {
    None => []
    Some(value) => parse_build(value)
  }
  { major, minor, patch, pre, build }
}

///|
pub fn try_parse(input : String) -> Result[SemVer, SemVerError] {
  try parse(input) |> Ok catch {
    error => Err(error)
  }
}

///|
fn parse_core(value : String) -> (Int, Int, Int) raise SemVerError {
  let parts = split_to_strings(value, ".")
  if parts.length() != 3 {
    raise SemVerError::InvalidFormat("expected MAJOR.MINOR.PATCH")
  }
  let major = parse_numeric_id(parts[0], label="major")
  let minor = parse_numeric_id(parts[1], label="minor")
  let patch = parse_numeric_id(parts[2], label="patch")
  (major, minor, patch)
}

///|
fn parse_prerelease(value : String) -> Array[PreId] raise SemVerError {
  let parts = split_to_strings(value, ".")
  parts.map(parse_prerelease_ident)
}

///|
fn parse_build(value : String) -> Array[String] raise SemVerError {
  let parts = split_to_strings(value, ".")
  parts.map(parse_build_ident)
}

///|
fn parse_prerelease_ident(value : String) -> PreId raise SemVerError {
  ensure_identifier(value, label="prerelease")
  if all_digits(value) {
    if has_leading_zero(value) {
      raise SemVerError::LeadingZero(value)
    }
    PreId::Num(parse_int(value, label="prerelease"))
  } else {
    PreId::Str(value)
  }
}

///|
fn parse_build_ident(value : String) -> String raise SemVerError {
  ensure_identifier(value, label="build")
  value
}

///|
fn parse_numeric_id(value : String, label~ : String) -> Int raise SemVerError {
  if value is "" {
    raise SemVerError::InvalidNumber("\{label}: empty")
  }
  if !all_digits(value) {
    raise SemVerError::InvalidNumber(label)
  }
  if has_leading_zero(value) {
    raise SemVerError::LeadingZero(value)
  }
  parse_int(value, label~)
}

///|
fn parse_int(value : String, label~ : String) -> Int raise SemVerError {
  @string.parse_int(value) catch {
    _ => raise SemVerError::InvalidNumber(label)
  }
}

///|
fn ensure_identifier(value : String, label~ : String) -> Unit raise SemVerError {
  if value is "" {
    raise SemVerError::InvalidIdentifier("\{label}: empty")
  }
  for c in value {
    if !is_identifier_char(c) {
      raise SemVerError::InvalidIdentifier("\{label}: \{value}")
    }
  }
}

///|
fn is_identifier_char(c : Char) -> Bool {
  c is ('0'..='9') || c is ('a'..='z') || c is ('A'..='Z') || c == '-'
}

///|
fn all_digits(value : String) -> Bool {
  for c in value {
    if !(c is ('0'..='9')) {
      return false
    }
  }
  true
}

///|
fn has_leading_zero(value : String) -> Bool {
  value.length() > 1 && value[0] == '0'
}

///|
fn split_to_strings(value : String, sep : String) -> Array[String] {
  value.split(sep).map(part => part.to_owned()).to_array()
}

///|
fn split_once(value : String, sep : String) -> (String, String?) {
  match value.find(sep) {
    None => (value, None)
    Some(idx) => {
      let left = value[:idx]
      let right = value[idx + sep.length():]
      (left.to_owned(), Some(right.to_owned()))
    }
  }
}
