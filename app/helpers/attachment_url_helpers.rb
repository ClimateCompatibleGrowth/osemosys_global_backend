module AttachmentUrlHelpers
  def attachment_url_or_nil_for(attachment)
    rails_blob_url(attachment) if attachment.attached?
  end
end
