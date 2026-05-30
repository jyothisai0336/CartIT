package cartit.security
deny[msg] {
  input.kind == "Pod"
  input.metadata.namespace == "cartit"
  container := input.spec.containers[_]
  not container.securityContext.runAsNonRoot
  msg := sprintf("Container '%v' must set runAsNonRoot: true", [container.name])
}
deny[msg] {
  input.kind == "Pod"
  input.metadata.namespace == "cartit"
  container := input.spec.containers[_]
  not container.securityContext.allowPrivilegeEscalation == false
  msg := sprintf("Container '%v' must set allowPrivilegeEscalation: false", [container.name])
}
deny[msg] {
  input.kind == "Pod"
  input.metadata.namespace == "cartit"
  container := input.spec.containers[_]
  not container.resources.limits
  msg := sprintf("Container '%v' must define resource limits", [container.name])
}
deny[msg] {
  input.kind == "Pod"
  input.metadata.namespace == "cartit"
  container := input.spec.containers[_]
  endswith(container.image, ":latest")
  msg := sprintf("Container '%v' must not use :latest tag", [container.name])
}
