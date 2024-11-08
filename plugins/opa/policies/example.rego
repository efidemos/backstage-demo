package example
import rego.v1

greeting := msg if {
    info := opa.runtime()
    hostname := info.env["HOSTNAME"] # Docker sets the HOSTNAME environment variable.
    msg := sprintf("hello from container %q!", [hostname])
}