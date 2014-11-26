require 'mimemagic'

module HipChat
  module FileHelper
    BOUNDARY = "sendfileboundary"

    private

    #
    # Builds a multipart file body for the api.
    #
    # message - a message to attach
    # file - a File instance
    def file_body(message, file)
      file_name = File.basename(file.path)
      mime_type = MimeMagic.by_path(file_name)
      file_content = Base64.encode64(file.read)

      body =  ["--#{BOUNDARY}"]
      body << 'Content-Type: application/json; charset=UTF-8'
      body << 'Content-Disposition: attachment; name="metadata"'
      body << ''
      body << message
      body << "--#{BOUNDARY}"
      body << "Content-Type: #{mime_type}; charset=UTF-8"
      body << 'Content-Transfer-Encoding: base64'
      body << %{Content-Disposition: attachment; name="file"; filename="#{file_name}"}
      body << ''
      body << file_content
      body << "--#{BOUNDARY}--"
      body.join("\n")
    end

    #
    # Appends headers require for the multipart body.
    #
    # headers - a base headers hash
    def file_body_headers(headers)
      headers.merge('Content-Type' => "multipart/related; boundary=#{BOUNDARY}")
    end
  end
end
