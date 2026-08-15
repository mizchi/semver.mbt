// User implementation - edit this file
// This file will not be overwritten on regeneration

///|
pub(all) struct SemverImpl {}

///|
pub impl Exports for SemverImpl with compare_versions(self, version_a : String, version_b : String) -> Int {
  let _ = self
  let a = @lib.try_parse(version_a)
  let b = @lib.try_parse(version_b)
  match (a, b) {
    (Ok(va), Ok(vb)) => va.compare(vb)
    _ => 0
  }
}

///|
pub impl Exports for SemverImpl with increment_version(self, version_str : String, release_type : String) -> String {
  let _ = self
  match @lib.inc(version_str, release_type) {
    Some(result) => result
    None => ""
  }
}

///|
pub impl Exports for SemverImpl with is_prerelease(self, version_str : String) -> Bool {
  let _ = self
  match @lib.try_parse(version_str) {
    Ok(v) => v.is_prerelease()
    Err(_) => false
  }
}

///|
pub impl Exports for SemverImpl with parse_version(self, version_str : String) -> String {
  let _ = self
  match @lib.try_parse(version_str) {
    Ok(v) => v.to_string()
    Err(_) => ""
  }
}

///|
fn init {
  register(SemverImpl::{})
}
