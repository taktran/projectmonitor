class PayloadLogEntry < ActiveRecord::Base
  belongs_to :project

  default_scope order: "created_at DESC"
  scope :reverse_chronological, order: "created_at DESC"

  after_save :send_notifications

  def self.latest
    reverse_chronological.limit(1).first
  end

  def to_s
    "#{method} #{status}"
  end

  def send_notifications
    if status == "successful"
      unless project.notification_email.present? || project.send_build_notifications
        ProjectMailer.build_notification(project).deliver
      end
    else
    end
  end
end
