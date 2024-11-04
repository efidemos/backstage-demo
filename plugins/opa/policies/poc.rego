package poc

greeting := msg {
    info := opa.runtime()
    hostname := info.env["HOSTNAME"] # Docker sets the HOSTNAME environment variable.
    msg := sprintf("poc endpoint says - hello from container %q!", [hostname])
}

greeting02 := msg {
    msg := sprintf("poc endpoint says - hello from greeting2", [])
}