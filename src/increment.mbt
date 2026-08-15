///|
priv enum ReleaseType {
  Major
  Minor
  Patch
  Premajor
  Preminor
  Prepatch
  Prerelease
  Release
  Pre
}

///|
fn parse_release_type(release : String) -> ReleaseType? {
  match release {
    "major" => Some(ReleaseType::Major)
    "minor" => Some(ReleaseType::Minor)
    "patch" => Some(ReleaseType::Patch)
    "premajor" => Some(ReleaseType::Premajor)
    "preminor" => Some(ReleaseType::Preminor)
    "prepatch" => Some(ReleaseType::Prepatch)
    "prerelease" => Some(ReleaseType::Prerelease)
    "release" => Some(ReleaseType::Release)
    "pre" => Some(ReleaseType::Pre)
    _ => None
  }
}

///|
fn normalize_identifier_base(base : Int) -> Int {
  if base < 0 {
    0
  } else {
    base
  }
}

///|
fn parse_identifier_opt(identifier : String?) -> PreId? {
  match identifier {
    None => None
    Some(value) => Some(parse_prerelease_ident(value)) catch { _ => None }
  }
}

///|
fn inc_pre_ids(
  current : Array[PreId],
  identifier : PreId?,
  base : Int,
) -> Array[PreId] {
  let next = current.copy()
  let mut last_numeric : Int? = None
  for i, id in next {
    if id is Num(_) {
      last_numeric = Some(i)
    }
  }
  match last_numeric {
    Some(i) =>
      match next[i] {
        Num(value) => next[i] = Num(value + 1)
        _ => ()
      }
    None => next.push(Num(base))
  }
  match identifier {
    None => next
    Some(id) => {
      let reset = [id, Num(base)]
      match next.get(0) {
        Some(first) if first == id =>
          if next.length() < 2 {
            reset
          } else {
            match next[1] {
              Num(_) => next
              _ => reset
            }
          }
        _ => reset
      }
    }
  }
}

///|
fn inc_semver(
  version : SemVer,
  release : ReleaseType,
  identifier : PreId?,
  identifier_base : Int,
) -> SemVer {
  let base = normalize_identifier_base(identifier_base)
  let mut major = version.major
  let mut minor = version.minor
  let mut patch = version.patch
  let mut pre : Array[PreId] = []
  match release {
    ReleaseType::Major => {
      if version.minor != 0 || version.patch != 0 || version.pre.is_empty() {
        major = major + 1
      }
      minor = 0
      patch = 0
      pre = []
    }
    ReleaseType::Minor => {
      if version.patch != 0 || version.pre.is_empty() {
        minor = minor + 1
      }
      patch = 0
      pre = []
    }
    ReleaseType::Patch => {
      if version.pre.is_empty() {
        patch = patch + 1
      }
      pre = []
    }
    ReleaseType::Premajor => {
      major = major + 1
      minor = 0
      patch = 0
      pre = inc_pre_ids([], identifier, base)
    }
    ReleaseType::Preminor => {
      minor = minor + 1
      patch = 0
      pre = inc_pre_ids([], identifier, base)
    }
    ReleaseType::Prepatch => {
      patch = patch + 1
      pre = inc_pre_ids([], identifier, base)
    }
    ReleaseType::Prerelease =>
      if version.pre.is_empty() {
        patch = patch + 1
        pre = inc_pre_ids([], identifier, base)
      } else {
        pre = inc_pre_ids(version.pre, identifier, base)
      }
    ReleaseType::Release => pre = []
    ReleaseType::Pre => pre = inc_pre_ids(version.pre, identifier, base)
  }
  SemVer::{ major, minor, patch, pre, build: [] }
}

///|
pub fn SemVer::inc(
  self : SemVer,
  release : String,
  identifier? : String,
  identifier_base? : Int = 0,
) -> SemVer? {
  inc_semver_option(self, release, identifier, identifier_base)
}

///|
pub fn inc(
  version : String,
  release : String,
  identifier? : String,
  identifier_base? : Int = 0,
) -> String? {
  match try_parse(version) {
    Ok(value) =>
      match inc_semver_option(value, release, identifier, identifier_base) {
        Some(next) => Some(next.to_string())
        None => None
      }
    Err(_) => None
  }
}

///|
fn inc_semver_option(
  version : SemVer,
  release : String,
  identifier : String?,
  identifier_base : Int,
) -> SemVer? {
  match parse_release_type(release) {
    None => None
    Some(release_type) =>
      match parse_identifier_opt(identifier) {
        None =>
          if identifier is None {
            Some(inc_semver(version, release_type, None, identifier_base))
          } else {
            None
          }
        Some(id) =>
          Some(inc_semver(version, release_type, Some(id), identifier_base))
      }
  }
}
