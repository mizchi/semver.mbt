///|
/// Semantic Versioning (SemVer 2.0.0).
pub struct SemVer {
  major : Int
  minor : Int
  patch : Int
  pre : Array[PreId]
  build : Array[String]
} derive(Show, Eq, ToJson)

///|
/// Pre-release identifier.
pub enum PreId {
  Num(Int)
  Str(String)
} derive(Show, Eq, ToJson)

///|
/// Errors raised while parsing a SemVer string.
pub suberror SemVerError {
  InvalidFormat(String)
  InvalidNumber(String)
  LeadingZero(String)
  InvalidIdentifier(String)
} derive(Show, Eq)

///|
pub fn SemVer::new(major : Int, minor : Int, patch : Int) -> SemVer {
  SemVer::{ major, minor, patch, pre: [], build: [] }
}

///|
pub fn SemVer::with_prerelease(
  major : Int,
  minor : Int,
  patch : Int,
  label : String,
  number : Int,
) -> SemVer {
  SemVer::{
    major,
    minor,
    patch,
    pre: [PreId::Str(label), PreId::Num(number)],
    build: [],
  }
}

///|
pub fn SemVer::strip_build(self : SemVer) -> SemVer {
  SemVer::{
    major: self.major,
    minor: self.minor,
    patch: self.patch,
    pre: self.pre,
    build: [],
  }
}

///|
pub fn SemVer::to_string(self : SemVer) -> String {
  let base = "\{self.major}.\{self.minor}.\{self.patch}"
  let pre = if self.pre.is_empty() {
    ""
  } else {
    "-" + self.pre.map(pre_id_to_string).join(".")
  }
  let build = if self.build.is_empty() {
    ""
  } else {
    "+" + self.build.join(".")
  }
  base + pre + build
}

///|
pub fn SemVer::is_prerelease(self : SemVer) -> Bool {
  !self.pre.is_empty()
}

///|
/// Compare versions by SemVer precedence rules (build metadata ignored).
pub fn SemVer::compare(self : SemVer, other : SemVer) -> Int {
  let major_cmp = compare_int(self.major, other.major)
  if major_cmp != 0 {
    major_cmp
  } else {
    let minor_cmp = compare_int(self.minor, other.minor)
    if minor_cmp != 0 {
      minor_cmp
    } else {
      let patch_cmp = compare_int(self.patch, other.patch)
      if patch_cmp != 0 {
        patch_cmp
      } else {
        compare_prerelease(self.pre, other.pre)
      }
    }
  }
}

///|
fn compare_int(a : Int, b : Int) -> Int {
  if a < b {
    -1
  } else if a > b {
    1
  } else {
    0
  }
}

///|
fn compare_string(a : String, b : String) -> Int {
  let a_chars = a.iter().to_array()
  let b_chars = b.iter().to_array()
  let len = if a_chars.length() < b_chars.length() {
    a_chars.length()
  } else {
    b_chars.length()
  }
  for i = 0, result = 0; i < len && result == 0; {
    let cmp = compare_char(a_chars[i], b_chars[i])
    continue i + 1, cmp
  } nobreak {
    if result != 0 {
      result
    } else {
      compare_int(a_chars.length(), b_chars.length())
    }
  }
}

///|
fn compare_char(a : Char, b : Char) -> Int {
  if a < b {
    -1
  } else if a > b {
    1
  } else {
    0
  }
}

///|
fn compare_pre_id(a : PreId, b : PreId) -> Int {
  match (a, b) {
    (Num(x), Num(y)) => compare_int(x, y)
    (Num(_), Str(_)) => -1
    (Str(_), Num(_)) => 1
    (Str(x), Str(y)) => compare_string(x, y)
  }
}

///|
fn compare_prerelease(a : Array[PreId], b : Array[PreId]) -> Int {
  if a.is_empty() && b.is_empty() {
    0
  } else if a.is_empty() {
    1
  } else if b.is_empty() {
    -1
  } else {
    let len = if a.length() < b.length() { a.length() } else { b.length() }
    for i = 0, result = 0; i < len && result == 0; {
      let cmp = compare_pre_id(a[i], b[i])
      continue i + 1, cmp
    } nobreak {
      if result != 0 {
        result
      } else {
        compare_int(a.length(), b.length())
      }
    }
  }
}

///|
fn pre_id_to_string(id : PreId) -> String {
  match id {
    Num(value) => value.to_string()
    Str(value) => value
  }
}
