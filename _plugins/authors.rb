module Jekyll
	class AuthorsTag < Liquid::Tag
    def initialize(tag_name, value, tokens)
      @tag_name = tag_name
      @value = value
      @tokens = tokens
    end

    def render(context)
      page = context.registers[:page]
      site = context.registers[:site]
      pageauthors = page['author']
      siteauthors = site.data['authors']
      authors = []
      unless pageauthors.nil?
        for author in pageauthors
          authors << siteauthors.find { |a| a['name'] == author }
        end
        return authors
      end
    end
	end

  module LookupFilter
    def lookup(input, args)
      args = args.split(',')
      dataset = args[0].strip
      key = args[1].strip unless args[1].nil?
      data = Jekyll.sites[0].data[dataset]
      lookup = data.find { |d| d['name'] == input }
      return input if lookup.nil?
      return lookup if lookup[key].nil?
      return lookup[key]
    end
  end
end

Liquid::Template.register_tag('page_authors', Jekyll::AuthorsTag)
Liquid::Template.register_filter(Jekyll::LookupFilter)