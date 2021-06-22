module Setup
  class Template < Translator
    include WithSourceOptions

    build_in_data_type.referenced_by(:namespace, :name)

    abstract_class true

    transformation_type :Export

    belongs_to :source_data_type, class_name: Setup::DataType.to_s, inverse_of: nil

    field :mime_type, type: String
    field :file_extension, type: String

    def validates_configuration
      if mime_type.present?
        if (extensions = file_extension_enum).empty?
          remove_attribute(:file_extension)
        elsif file_extension.blank?
          if extensions.length == 1
            self.file_extension = extensions[0]
          else
            errors.add(:file_extension, 'has multiple options')
          end
        else
          errors.add(:file_extension, 'is not valid') unless extensions.include?(file_extension)
        end
      end
      super
    end

    def mime_type_enum
      ::MIME::Types.inject([]) { |types, t| types << t.to_s }
    end

    def file_extension_enum
      extensions = []
      if (types = ::MIME::Types[mime_type])
        types.each { |type| extensions.concat(type.extensions) }
      end
      extensions.uniq
    end

    def ready_to_save?
      persisted? || changed_attributes.key?('mime_type')
    end

    def can_be_restarted?
      ready_to_save?
    end

    def data_type
      source_data_type
    end

    #TODO Remove this method if refactored Conversions does not use it
    def apply_to_source?(data_type)
      source_data_type.blank? || source_data_type == data_type
    end

    class << self

      def mime_type_filter_enum
        Setup::Template.where(:mime_type.ne => nil).distinct(:mime_type).flatten.uniq
      end

      def file_extension_filter_enum
        Setup::Template.where(:file_extension.ne => nil).distinct(:file_extension).flatten.uniq
      end
    end
  end
end
