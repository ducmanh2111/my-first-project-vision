class ImageScanner
  @queue = :scanner

  def self.perform()
    # attachment = Attachment.find_by(id: attachment_id)
    client = Abbyy::Client.new
      binding.pry
    client.process_document '/home/manh/environment/my_first_project_vision/public/picture_samples/English/Handprint/label.jpg', exportFormat: 'xml', imageSource: 'photo'
    while %w(Queued InProgress).include?(client.task[:status])
      sleep(client.task[:estimatedProcessingTime].to_i)
      client.get_task_status
    end
    if client.task[:status] == 'Completed'
      xml_data = REXML::Document.new(client.get)
    else
    end
  end
end
