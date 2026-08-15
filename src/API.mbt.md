# API Documentation

Executable doc tests for SemVer parsing and comparison.

## parse

```mbt check
///|
test {
  inspect(parse("1.2.3").to_string(), content="1.2.3")
  inspect(
    parse("1.2.3-alpha.1+build.5").to_string(),
    content="1.2.3-alpha.1+build.5",
  )
}
```

## compare

```mbt check
///|
test {
  let a = parse("1.0.0-rc.1")
  let b = parse("1.0.0")
  assert_true(a.compare(b) < 0)
}
```

## inc

```mbt check
///|
test {
  debug_inspect(inc("1.2.3", "patch"), content="Some(\"1.2.4\")")
  debug_inspect(
    inc("1.2.3", "prerelease", identifier="beta"),
    content="Some(\"1.2.4-beta.0\")",
  )
}
```
