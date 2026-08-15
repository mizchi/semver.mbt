///|
test "inc major minor patch" {
  debug_inspect(inc("1.2.3", "major"), content="Some(\"2.0.0\")")
  debug_inspect(inc("1.2.3", "minor"), content="Some(\"1.3.0\")")
  debug_inspect(inc("1.2.3", "patch"), content="Some(\"1.2.4\")")
}

///|
test "inc drops prerelease on major minor patch" {
  debug_inspect(inc("1.0.0-rc.1", "major"), content="Some(\"1.0.0\")")
  debug_inspect(inc("1.2.0-beta.1", "minor"), content="Some(\"1.2.0\")")
  debug_inspect(inc("1.2.3-beta.1", "patch"), content="Some(\"1.2.3\")")
}

///|
test "inc prerelease" {
  debug_inspect(
    inc("1.2.3", "prerelease", identifier="beta"),
    content="Some(\"1.2.4-beta.0\")",
  )
  debug_inspect(
    inc("1.2.3-beta.2", "prerelease"),
    content="Some(\"1.2.3-beta.3\")",
  )
  debug_inspect(
    inc("1.2.3-beta", "prerelease"),
    content="Some(\"1.2.3-beta.0\")",
  )
}

///|
test "inc premajor preminor prepatch" {
  debug_inspect(
    inc("1.2.3", "premajor", identifier="alpha"),
    content="Some(\"2.0.0-alpha.0\")",
  )
  debug_inspect(
    inc("1.2.3", "preminor", identifier="alpha"),
    content="Some(\"1.3.0-alpha.0\")",
  )
  debug_inspect(
    inc("1.2.3", "prepatch", identifier="alpha"),
    content="Some(\"1.2.4-alpha.0\")",
  )
}

///|
test "inc prerelease base" {
  debug_inspect(
    inc("1.2.3", "preminor", identifier="alpha", identifier_base=1),
    content="Some(\"1.3.0-alpha.1\")",
  )
}

///|
test "inc release" {
  debug_inspect(inc("1.2.3-beta.1", "release"), content="Some(\"1.2.3\")")
}
