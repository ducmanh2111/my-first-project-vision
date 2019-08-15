class Image < ApplicationRecord

  require "rubygems"

  require "rest_client"

  require "rexml/document"
  require 'json'

  APPLICATION_ID = CGI.escape("CR_Regulation")
  PASSWORD = CGI.escape("4GSlgxh/Nctzb5tyLa3Ll81z")
  BASE_URL = "http://#{APPLICATION_ID}:#{PASSWORD}@cloud-eu.ocrsdk.com"
  FILE_NAME = "/home/manh/environment/my_first_project_vision/public/picture_samples/English/Handprint/Test3.png"
  LANGUAGE = "English"

  result = Hash.new
  def self.begin_scan
    def output_response_error(response)
      xml_data = REXML::Document.new(response)
      error_message = xml_data.elements["error/message"]
      puts "Error: #{error_message.text}" if error_message
    end
    puts "Image will be recognized with #{LANGUAGE} language."
    puts "Uploading file.."
    begin
      response = RestClient.post("#{BASE_URL}/processImage?profile=textExtraction&exportFormat=xml&xml:writeFormatting=true&language=#{LANGUAGE}", :upload => {
        :file => File.new(FILE_NAME, 'rb')
      })
    rescue RestClient::ExceptionWithResponse => e
      output_response_error(e.response)
      raise
    else
      # binding.pry
      xml_data = REXML::Document.new(response)
      task_element = xml_data.elements["response/task"]
      task_id = task_element.attributes["id"]
      task_status = task_element.attributes["status"]
    end
    puts "Waiting till image is processed.."
    while task_status == "InProgress" or task_status == "Queued" do
      begin
        raise "Invalid task id used when preparing getTaskStatus request"\
        if ((!(defined? task_id)) || task_id.nil? ||task_id.empty?|| (task_id.include? "00000000-0"))
          response = RestClient.get("#{BASE_URL}/getTaskStatus?taskid=#{task_id}")
        rescue RestClient::ExceptionWithResponse => e
          output_response_error(e.response)
          raise
        else
          xml_data = REXML::Document.new(response)
          task_element = xml_data.elements["response/task"]
          task_status = task_element.attributes["status"]
        end
      end
      raise "The task hasn't been processed because an error occurred" if task_status == "ProcessingFailed"
      raise "You don't have enough money on your account to process the task" if task_status == "NotEnoughCredits"
      download_url = xml_data.elements["response/task"].attributes["resultUrl"]
      puts "Downloading result.."
      recognized_text = RestClient.get(download_url)
      puts recognized_text
    end

  FILE_PATH = "/home/manh/environment/my_first_project_vision/app/views/scans/whatfontis.json"

  def self.begin_font
    response = RestClient.get("https://www.whatfontis.com/api/?file=#{FILE_PATH}&limit=2")
  end
end
