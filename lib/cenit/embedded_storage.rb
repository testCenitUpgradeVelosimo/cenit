module Cenit
  class EmbeddedStorage < CarrierWave::Storage::Abstract

    def store!(file)
      record = uploader.model
      self.class.store_on(record, file, uploader.file_attributes)
      unless record.instance_variable_get(:"@embedding_#{uploader.mounted_as}_files")
        record.save
      end
    end

    def retrieve!(identifier)
      file = (uploader.model.files || []).detect { |f| f[:filename] == identifier }
      file && File.new(
        tempfile: StringIO.new(file[:data].data),
        filename: identifier,
        content_type: file[:content_type],
        uploader: uploader,
        metadata: file[:metadata]
      )
    end

    class File < ::CarrierWave::SanitizedFile

      attr_reader :metadata

      def initialize(attrs)
        @uploader = attrs.delete(:uploader)
        @metadata = attrs[:metadata]
        super
      end

      def path
        "#{@uploader.store_dir}/#{filename}"
      end
    end

    class << self
      def store_on(record, file, opts = {})
        unless (files = record.files)
          files = record.files = []
        end
        unless (index = files.find_index { |f| f['filename'] == file.identifier })
          index = files.length
          files << {}
        end
        content_type = opts[:content_type] || opts[:contentType] || file.content_type.presence
        content_type = nil if content_type && content_type['invalid']
        filename = file.filename || opts[:filename]
        files[index].merge!(
          filename: filename,
          content_type: content_type ||
            ::MIME::Types.type_for(filename)[0].to_s.presence ||
            'application/octet-stream',
          data: BSON::Binary.new(file.read),
          metadata: opts[:metadata]
        )
        record.files = files
      end
    end
  end
end