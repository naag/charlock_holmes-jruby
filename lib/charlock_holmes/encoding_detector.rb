require_relative 'version'
require_relative "../#{CharlockHolmes::ICU_JAR_FILENAME}"
require_relative 'charset_match_ext'

java_import 'com.ibm.icu.text.CharsetDetector'
java_import 'java.io.ByteArrayInputStream'

module CharlockHolmes
  class EncodingDetector
    def initialize
      @detector = CharsetDetector.new
      @detector
    end

    def detect(string, hint = nil)
      return unless valid_input(string)
      @detector.setText(ByteArrayInputStream.new(string.to_java_bytes))
      @detector.setDeclaredEncoding(hint)

      begin
        match = @detector.detect
        match ? match.to_hash : nil
      rescue
        nil
      end
    end

    def detect_all(string, hint = nil)
      return unless valid_input(string)
      @detector.setText(ByteArrayInputStream.new(string.to_java_bytes))
      @detector.setDeclaredEncoding(hint)

      begin
        matches = @detector.detectAll
        matches.map(&:to_hash)
      rescue
        nil
      end
    end

    def strip_tags=(value)
      @detector.enableInputFilter(value)
    end

    def strip_tags
      @detector.inputFilterEnabled
    end

    private

    def valid_input(string)
      string.is_a?(String)
    end

    class << self
      def detect(string, hint = nil)
        new.detect(string, hint)
      end

      def detect_all(string, hint = nil)
        new.detect_all(string, hint)
      end

      def all_detectable_charsets
        CharsetDetector.getAllDetectableCharsets.to_a
      end
    end
  end
end
