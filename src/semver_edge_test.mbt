///|
test "invalid core formats" {
  let cases = ["", "1", "1.0", "1.0.0.0"]
  for s in cases {
    let result = try_parse(s)
    match result {
      Err(SemVerError::InvalidFormat(msg)) =>
        assert_eq(msg, "expected MAJOR.MINOR.PATCH")
      _ => fail("expected InvalidFormat")
    }
  }
}

///|
test "invalid prerelease/build empty segments" {
  let cases = [
    ("1.0.0-", "prerelease: empty"),
    ("1.0.0-alpha..1", "prerelease: empty"),
    ("1.0.0-alpha.", "prerelease: empty"),
    ("1.0.0+", "build: empty"),
    ("1.0.0+build..1", "build: empty"),
    ("1.0.0+build.", "build: empty"),
  ]
  for item in cases {
    let (s, expected) = item
    let result = try_parse(s)
    match result {
      Err(SemVerError::InvalidIdentifier(msg)) => assert_eq(msg, expected)
      _ => fail("expected InvalidIdentifier")
    }
  }
}

///|
test "invalid identifier characters" {
  let cases = [
    ("1.0.0-alpha_", "prerelease: alpha_"),
    ("1.0.0-α", "prerelease: α"),
    ("1.0.0+build!", "build: build!"),
    ("1.0.0+α", "build: α"),
  ]
  for item in cases {
    let (s, expected) = item
    let result = try_parse(s)
    match result {
      Err(SemVerError::InvalidIdentifier(msg)) => assert_eq(msg, expected)
      _ => fail("expected InvalidIdentifier")
    }
  }
}

///|
test "leading zeros" {
  let cases = [
    ("01.0.0", "01"),
    ("1.01.0", "01"),
    ("1.0.01", "01"),
    ("1.0.0-01", "01"),
  ]
  for item in cases {
    let (s, expected) = item
    let result = try_parse(s)
    match result {
      Err(SemVerError::LeadingZero(value)) => assert_eq(value, expected)
      _ => fail("expected LeadingZero")
    }
  }
}

///|
test "build metadata ignored in compare" {
  let a = parse("1.0.0+1")
  let b = parse("1.0.0+2")
  let c = parse("1.0.0-alpha+1")
  let d = parse("1.0.0-alpha+2")
  assert_eq(a.compare(b), 0)
  assert_eq(c.compare(d), 0)
}

///|
test "prerelease lexicographic and numeric ordering" {
  let a = parse("1.0.0-alpha")
  let b = parse("1.0.0-alpha.0")
  let c = parse("1.0.0-alpha-1")
  let d = parse("1.0.0-alpha.9")
  let e = parse("1.0.0-alpha.10")
  let f = parse("1.0.0-alpha.9a")
  let g = parse("1.0.0-beta")
  assert_true(a.compare(b) < 0)
  assert_true(a.compare(c) < 0)
  assert_true(d.compare(e) < 0)
  assert_true(d.compare(f) < 0)
  assert_true(a.compare(g) < 0)
}
