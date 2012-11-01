module XmlSchemaMapper
  class NamespaceResolver
    class Namespace
      attr_reader :prefix, :href

      def initialize(prefix, href)
        @prefix, @href = prefix, href
      end
    end

    def initialize(fallback)
      @fallback = fallback
    end

    # @return [DuckyTyped with #prefix and #href]
    def find_by_href(href)
      by_href(href) || @fallback.find_by_href(href)
    end

    # @return [DuckyTyped with #prefix and #href]
    def find_by_prefix(prefix)
      by_prefix(prefix) || @fallback.find_by_prefix(prefix)
    end

    # @return [DuckyTyped with #prefix and #href]
    def by_href(href)
    end

    # @return [DuckyTyped with #prefix and #href]
    def by_prefix(prefix)
    end
  end
end
