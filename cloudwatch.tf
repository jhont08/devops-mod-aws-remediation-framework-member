# Setup CloudWatch Event monitor
resource "aws_cloudwatch_event_rule" "event_forwarder" {
  name        = "${var.tags.stack}-remediation-event-forwarder"
  description = "Forwards events to the master account"

  # List of events that should be translated so the remediator can check the resource that was changed
  event_pattern = file("${path.module}/events_to_watch.json")

  tags = merge(
    var.tags,
    {
      app    = "event-forwarder"
      team   = "devops-security"
      system = "aws-remediation"
    },
  )
}

resource "aws_cloudwatch_event_target" "event_forwarder" {
  # Don't create this target if the account this is run is, is the remediation master, because an event bus can't send events to itself.
  count = var.master == data.aws_caller_identity.this.account_id ? 0 : 1

  target_id = "event_forwarder"
  rule      = aws_cloudwatch_event_rule.event_forwarder.name
  arn       = "arn:aws:events:${var.region}:${var.master}:event-bus/default"
  role_arn  = aws_iam_role.event_forward.arn
}
