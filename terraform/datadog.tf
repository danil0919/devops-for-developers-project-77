resource "datadog_monitor" "focalboard_http_check" {
  name    = "Focalboard HTTP local healthcheck"
  type    = "service check"
  message = "Focalboard local HTTP check is failing on {{host.name}}"

  query = "\"http.can_connect\".over(\"instance:focalboard-local\").by(\"host\").last(2).count_by_status()"

  monitor_thresholds {
    critical = 1
  }

  notify_no_data    = false
  renotify_interval = 0

  tags = [
    "service:focalboard",
    "env:dev"
  ]
}