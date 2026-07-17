
# Empty Secrets Manager entries. ARNs exist so IRSA policies and ESO can
# reference them, but values are pasted in by hand via console after apply.

resource "aws_secretsmanager_secret" "this" {
  for_each = toset(var.secret_names)

  name = "${var.name_prefix}/${each.value}"

  # Dev: delete immediately on destroy so the name is instantly reusable.
  # (Default is a 7–30 day recovery window that "reserves" the name.)
  recovery_window_in_days = var.recovery_window_in_days

  tags = local.tags
}
