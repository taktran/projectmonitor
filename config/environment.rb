# Load the rails application
require File.expand_path('../application', __FILE__)

::RED_NOTIFICATION_EMAILS = ["notify@example.com"]
::SYSTEM_ADMIN_EMAIL = "Pivotal CiMonitor <pivotal-cimonitor@example.com>"


CiMonitor::Application.initialize!
