///|
test "parse basic" {
  let v = parse("1.2.3")
  inspect(v.to_string(), content="1.2.3")
  assert_true(!v.is_prerelease())
}

///|
test "parse prerelease build" {
  let v = parse("1.2.3-alpha.1+build.5")
  inspect(v.to_string(), content="1.2.3-alpha.1+build.5")
  assert_true(v.is_prerelease())
}

///|
test "invalid leading zero" {
  let result = try_parse("01.2.3")
  debug_inspect(result, content="Err(LeadingZero(\"01\"))")
}

///|
test "compare prerelease precedence" {
  let a = parse("1.0.0-alpha")
  let b = parse("1.0.0-alpha.1")
  let c = parse("1.0.0-alpha.beta")
  let d = parse("1.0.0-beta")
  let e = parse("1.0.0-beta.2")
  let f = parse("1.0.0-beta.11")
  let g = parse("1.0.0-rc.1")
  let h = parse("1.0.0")
  assert_true(a.compare(b) < 0)
  assert_true(b.compare(c) < 0)
  assert_true(c.compare(d) < 0)
  assert_true(d.compare(e) < 0)
  assert_true(e.compare(f) < 0)
  assert_true(f.compare(g) < 0)
  assert_true(g.compare(h) < 0)
}

///|
test "compare numeric vs string prerelease" {
  let a = parse("1.0.0-1")
  let b = parse("1.0.0-alpha")
  assert_true(a.compare(b) < 0)
}
