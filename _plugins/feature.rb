# author:: Greg Boone boone.greg@gmail.com
# license:: CC0
module Jekyll
	class FeaturedPostTag < Liquid::Tag
		def initialize(tag_name, value, tokens)
			super
			@count = value.to_i
		end
		def render(context)
			site = context.registers[:site]
			posts = site.posts
			series = context.registers[:site].data['series']
			feature = context.registers[:page]['feature']
			slugs = series[feature]['posts']
			featured_posts = Array.new()
			posts.each { |x| featured_posts.push(x) if slugs.include?(x.slug) }
			post = featured_posts[@count]
			"<h3>#{post.title}</h3><p>#{post.excerpt}</p>"
		end
	end

	module TruncateWordsFilter
		def truncatewords(input, words)
			array = input.scan(/\w+/)
			output = ""
			array.each_with_index { |w, i| output += "#{w} " unless i >= words.to_i }
		end
	end
end
Liquid::Template.register_tag('feature_post', Jekyll::FeaturedPostTag)
